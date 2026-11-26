-- RS-A.3 PROPOSAL ONLY. Not approved for merge, application, or deployment.
-- Additive migration 099; migration 098 must remain byte-for-byte unchanged.
-- This single DO statement checks, changes, and rechecks the publication atomically.
-- External/hosted subscriber clearance and an approved 098/099 deployment sequence
-- are mandatory operator release gates; SQL cannot prove either.
DO $rsa3$
DECLARE
  publication_state record;
  published_count integer;
BEGIN
  IF to_regclass('supabase_migrations.schema_migrations') IS NULL OR
     NOT EXISTS (
       SELECT 1 FROM supabase_migrations.schema_migrations
       WHERE version = '20260101009800'
     ) THEN
    RAISE EXCEPTION 'RS-A3_REFUSE: verified migration 098 is absent';
  END IF;

  SELECT p.oid, p.puballtables, p.pubinsert, p.pubupdate,
         p.pubdelete, p.pubtruncate, p.pubviaroot
  INTO publication_state
  FROM pg_catalog.pg_publication AS p
  WHERE p.pubname = 'supabase_realtime';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'RS-A3_REFUSE: supabase_realtime does not exist';
  END IF;
  IF publication_state.puballtables IS DISTINCT FROM false OR
     publication_state.pubviaroot IS DISTINCT FROM false THEN
    RAISE EXCEPTION 'RS-A3_REFUSE: publication-wide or partition-root settings';
  END IF;
  IF publication_state.pubinsert IS DISTINCT FROM true OR
     publication_state.pubupdate IS DISTINCT FROM true THEN
    RAISE EXCEPTION 'RS-A3_REFUSE: INSERT and UPDATE must already be enabled';
  END IF;
  IF EXISTS (
    SELECT 1 FROM pg_catalog.pg_publication_namespace AS n
    WHERE n.pnpubid = publication_state.oid
  ) THEN
    RAISE EXCEPTION 'RS-A3_REFUSE: schema-wide publication membership';
  END IF;

  SELECT count(*) INTO published_count
  FROM pg_catalog.pg_publication_tables AS t
  WHERE t.pubname = 'supabase_realtime';
  IF published_count <> 3 OR EXISTS (
    SELECT 1 FROM pg_catalog.pg_publication_tables AS t
    WHERE t.pubname = 'supabase_realtime'
      AND (t.schemaname <> 'public' OR t.tablename NOT IN
           ('event_sales', 'bazaar_losses', 'bazaar_stock_adds'))
  ) THEN
    RAISE EXCEPTION 'RS-A3_REFUSE: publication membership differs from three approved tables';
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_catalog.pg_publication_tables AS t
    WHERE t.pubname = 'supabase_realtime'
      AND (
        t.rowfilter IS NOT NULL OR
        ARRAY(SELECT a.attname FROM unnest(t.attnames) AS a(attname)
              ORDER BY a.attname)
        IS DISTINCT FROM
        ARRAY(SELECT a.attname FROM pg_catalog.pg_attribute AS a
              WHERE a.attrelid = to_regclass(format('%I.%I', t.schemaname, t.tablename))
                AND a.attnum > 0 AND NOT a.attisdropped
              ORDER BY a.attname)
      )
  ) THEN
    RAISE EXCEPTION 'RS-A3_REFUSE: row filters or published column restrictions';
  END IF;

  SELECT count(*) INTO published_count
  FROM pg_catalog.pg_class AS c
  JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relname IN ('event_sales', 'bazaar_losses', 'bazaar_stock_adds')
    AND c.relkind = 'r' AND c.relrowsecurity = true
    AND pg_catalog.pg_get_userbyid(c.relowner) = 'postgres';
  IF published_count <> 3 THEN
    RAISE EXCEPTION 'RS-A3_REFUSE: published table RLS, relation kind, or owner';
  END IF;

  IF NOT has_table_privilege('authenticated', 'public.event_sales', 'SELECT') OR
     NOT has_table_privilege('authenticated', 'public.bazaar_losses', 'SELECT') OR
     NOT has_table_privilege('authenticated', 'public.bazaar_stock_adds', 'SELECT') OR
     has_table_privilege('anon', 'public.bazaar_losses', 'SELECT') OR
     has_table_privilege('anon', 'public.bazaar_stock_adds', 'SELECT') OR
     has_table_privilege('authenticated', 'public.bazaar_losses', 'INSERT, UPDATE, DELETE') OR
     has_table_privilege('authenticated', 'public.bazaar_stock_adds', 'INSERT, UPDATE, DELETE') THEN
    RAISE EXCEPTION 'RS-A3_REFUSE: Bazaar grants differ from 098 contract';
  END IF;
  SELECT count(*) INTO published_count
  FROM pg_catalog.pg_policies AS p
  WHERE p.schemaname = 'public' AND p.cmd = 'SELECT'
    AND p.roles = ARRAY['authenticated']::name[]
    AND (p.tablename, p.policyname) IN (
      ('event_sales', 'sales staff read'),
      ('bazaar_losses', 'bazaar losses read'),
      ('bazaar_stock_adds', 'bazaar stock adds read')
    );
  IF published_count <> 3 THEN
    RAISE EXCEPTION 'RS-A3_REFUSE: Bazaar SELECT policy inventory differs from 098';
  END IF;

  -- Changes exactly one publication option; does not add/drop tables or change RLS,
  -- grants, SQL functions, business rows, or replica identity.
  EXECUTE 'ALTER PUBLICATION supabase_realtime SET (publish = ''insert, update'')';

  IF NOT EXISTS (
    SELECT 1 FROM pg_catalog.pg_publication AS p
    WHERE p.pubname = 'supabase_realtime'
      AND p.puballtables = false
      AND p.pubinsert = true AND p.pubupdate = true
      AND p.pubdelete = false AND p.pubtruncate = false
      AND p.pubviaroot = false
  ) THEN
    RAISE EXCEPTION 'RS-A3_REFUSE: publication postcondition failed; statement rolled back';
  END IF;
END;
$rsa3$;

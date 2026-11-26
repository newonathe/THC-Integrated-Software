-- Seed for local development.
--
-- GENERATED from the engine's own constants (src/store/engine/ops-engine.js: PRODUCTS,
-- INVENTORY, SUPPLIERS, PACK_SIZE, RECIPES, USE_BY_DAYS), so `pnpm db:reset` gives you
-- exactly the numbers the design shows. Do not hand-edit: change the engine, then
-- regenerate with `node scripts/gen-seed.mjs`.
--
-- Money is centavos. Quantities are the item's own unit (g, ml, pcs), never rounded.

-- suppliers -----------------------------------------------------------------
insert into suppliers (id, name, place) values
  ('bulk-club-membership', 'Bulk Club Membership', 'North Branch'),
  ('metro-grocer', 'Metro Grocer', 'West Branch'),
  ('cocoa-supply', 'Cocoa Supply', 'Online · ships in 2 days'),
  ('city-packaging', 'City Packaging', 'Market Street'),
  ('label-studio', 'Label Studio', 'Online · Shopee'),
  ('corner-mart', 'Corner Mart', 'South Branch'),
  ('wet-market', 'Wet market', 'East Market'),
  ('baking-supply', 'Baking supply', 'Shopee · Baking Depot'),
  ('japanese-grocery', 'Japanese grocery', ''),
  ('natural-pantry', 'Natural Pantry', '')
on conflict (id) do nothing;

-- catalogue -----------------------------------------------------------------
insert into products (id, name, short_name, price_cents, kind, tag, description, image_path, sort_order) values
  ('dcf', 'double chocolate fudge', 'Double Chocolate Fudge', 13000, 'Permanent', '', 'golden-brown edges and soft, pillowy center studded with pools of molten chocolate.', '/assets/double-chocolate-fudge.png', 1),
  ('hc', 'happy camper', 'Happy Camper', 14000, 'Permanent', '', 'browned butter, toasted marshmallow pockets, melted milk chocolate, graham cracker crunch.', '/assets/happy-camper.png', 2),
  ('wcb', 'white chocolate biscoff', 'White Chocolate Biscoff', 14500, 'Permanent', 'Best seller', 'crunchy, caramelized biscuit, biscoff cookie butter. white chocolate chips that melts in your mouth.', '/assets/white-chocolate-biscoff.png', 3),
  ('pbm', 'pb & miso', 'PB & Miso', 8000, 'Permanent', 'Best seller', 'white shiro miso infused with chunky peanut butter. sugar-crusted outside, soft center.', '/assets/pb-miso.png', 4),
  ('rvc', 'red velvet cheesecake', 'Red Velvet Cheesecake', 15000, 'Rotating', 'New', 'rich red velvet packed with melted white chocolate and a tangy cream cheese center.', '/assets/red-velvet-cheesecake.png', 5),
  ('nch', 'nutella churro', 'Nutella Churro', 20000, 'Rotating', 'New', 'churro-inspired cinnamon sugar base, soft cookie center filled with rich molten nutella.', '/assets/nutella-churro.png', 6)
on conflict (id) do nothing;

-- stock ---------------------------------------------------------------------
insert into inventory_items (id, category, name, unit, on_hand, par_level, pack_size, supplier_id, use_by_days, last_counted) values
  ('unsalted-butter', 'Ingredients', 'Unsalted butter', 'g', 931, 2068, 1000, 'bulk-club-membership', 9, now() - interval '3 days'),
  ('bread-flour', 'Ingredients', 'Bread flour', 'g', 4106, 2933, 1000, 'metro-grocer', null, now() - interval '3 days'),
  ('all-purpose-flour', 'Ingredients', 'All-purpose flour', 'g', 3894, 2562, 1000, 'metro-grocer', null, now() - interval '3 days'),
  ('brown-sugar', 'Ingredients', 'Brown sugar', 'g', 2842, 2186, 1000, 'corner-mart', null, now() - interval '3 days'),
  ('white-sugar', 'Ingredients', 'White sugar', 'g', 1509, 1191, 1000, 'corner-mart', null, now() - interval '3 days'),
  ('eggs', 'Ingredients', 'Eggs', 'pcs', 27, 20, 30, 'wet-market', 13, now() - interval '2 days'),
  ('dark-chocolate-55', 'Ingredients', 'Dark chocolate 55%', 'g', 1383, 954, 1000, 'cocoa-supply', 128, now() - interval '5 days'),
  ('milk-chocolate', 'Ingredients', 'Milk chocolate', 'g', 657, 481, 1000, 'cocoa-supply', 96, now() - interval '5 days'),
  ('white-chocolate-chips', 'Ingredients', 'White chocolate chips', 'g', 1396, 1016, 1000, 'cocoa-supply', 110, now() - interval '5 days'),
  ('cocoa-powder', 'Ingredients', 'Cocoa powder', 'g', 450, 281, 500, 'metro-grocer', null, now() - interval '5 days'),
  ('biscoff-spread', 'Ingredients', 'Biscoff spread', 'g', 97, 539, 400, 'metro-grocer', 60, now() - interval '3 days'),
  ('biscoff-biscuits', 'Ingredients', 'Biscoff biscuits', 'g', 610, 382, 250, 'metro-grocer', null, now() - interval '3 days'),
  ('chunky-peanut-butter', 'Ingredients', 'Chunky peanut butter', 'g', 956, 637, 1000, 'bulk-club-membership', null, now() - interval '3 days'),
  ('shiro-miso', 'Ingredients', 'Shiro miso', 'g', 252, 172, 500, 'japanese-grocery', null, now() - interval '17 days'),
  ('cream-cheese', 'Ingredients', 'Cream cheese', 'g', 691, 494, 900, 'bulk-club-membership', 5, now() - interval '3 days'),
  ('nutella', 'Ingredients', 'Nutella', 'g', 920, 581, 750, 'metro-grocer', 74, now() - interval '3 days'),
  ('mini-marshmallows', 'Ingredients', 'Mini marshmallows', 'g', 438, 346, 500, 'corner-mart', null, now() - interval '5 days'),
  ('graham-crackers', 'Ingredients', 'Graham crackers', 'g', 522, 311, 500, 'corner-mart', null, now() - interval '5 days'),
  ('cinnamon', 'Ingredients', 'Cinnamon', 'g', 184, 92, 250, 'metro-grocer', null, now() - interval '17 days'),
  ('baking-soda', 'Ingredients', 'Baking soda', 'g', 310, 129, 500, 'corner-mart', null, now() - interval '17 days'),
  ('fine-salt', 'Ingredients', 'Fine salt', 'g', 584, 234, 500, 'corner-mart', null, now() - interval '17 days'),
  ('maldon-sea-salt', 'Ingredients', 'Maldon sea salt', 'g', 174, 97, 250, 'natural-pantry', null, now() - interval '17 days'),
  ('vanilla-extract', 'Ingredients', 'Vanilla extract', 'ml', 151, 76, 250, 'metro-grocer', null, now() - interval '17 days'),
  ('red-velvet-gel-colour', 'Ingredients', 'Red velvet gel colour', 'ml', 33, 15, 100, 'baking-supply', null, now() - interval '17 days'),
  ('box-of-6', 'Packaging', 'Box of 6', 'pcs', 6, 14, 25, 'city-packaging', null, now() - interval '3 days'),
  ('single-cookie-pouch', 'Packaging', 'Single cookie pouch', 'pcs', 60, 37, 100, 'city-packaging', null, now() - interval '3 days'),
  ('brand-sticker', 'Packaging', 'Brand sticker', 'pcs', 3, 19, 100, 'label-studio', null, now() - interval '3 days'),
  ('thank-you-card', 'Packaging', 'Thank-you card', 'pcs', 51, 30, 50, 'label-studio', null, now() - interval '17 days'),
  ('paper-bag', 'Packaging', 'Paper bag', 'pcs', 34, 22, 25, 'city-packaging', null, now() - interval '17 days'),
  ('bubble-wrap-sheet', 'Packaging', 'Bubble wrap sheet', 'pcs', 52, 28, 50, 'city-packaging', null, now() - interval '17 days')
on conflict (id) do nothing;

-- supplier price book ------------------------------------------------------
insert into supplier_prices (supplier_id, item_name, pack_label, price_cents, previous_cents, last_bought, preferred) values
  ('bulk-club-membership', 'Unsalted butter', '1 kg block', 43000, '{47000,46500}', '2 Aug', true),
  ('bulk-club-membership', 'Cream cheese', '900 g tub', 44000, '{47500}', '2 Aug', true),
  ('bulk-club-membership', 'Chunky peanut butter', '1 kg jar', 51000, '{53500}', '11 Aug', true),
  ('metro-grocer', 'Biscoff spread', '400 g jar', 25000, '{28000,26500}', '11 Aug', true),
  ('metro-grocer', 'Nutella', '750 g jar', 53000, '{56000}', '5 Aug', true),
  ('metro-grocer', 'Bread flour', '1 kg', 8000, '{8500}', '5 Aug', true),
  ('metro-grocer', 'Unsalted butter', '1 kg block', 56000, '{61500}', '19 Jul', false),
  ('cocoa-supply', 'Dark chocolate 55%', '1 kg', 49000, '{50500,52000}', '9 Aug', true),
  ('cocoa-supply', 'White chocolate chips', '1 kg', 58000, '{61000}', '9 Aug', true),
  ('cocoa-supply', 'Milk chocolate', '1 kg', 44000, '{46000}', '9 Aug', true),
  ('city-packaging', 'Box of 6', 'Pack of 25', 41000, '{42000,46000}', '1 Aug', true),
  ('city-packaging', 'Single cookie pouch', 'Pack of 100', 25000, '{26500}', '1 Aug', true),
  ('label-studio', 'Brand sticker', 'Roll of 100', 14000, '{14500}', '4 Aug', true),
  ('label-studio', 'Thank-you card', 'Pack of 50', 23500, '{26000}', '4 Aug', true),
  ('corner-mart', 'Brown sugar', '1 kg', 7500, '{8500}', '11 Aug', true),
  ('corner-mart', 'White sugar', '1 kg', 6500, '{7500}', '11 Aug', true),
  ('corner-mart', 'Unsalted butter', '1 kg block', 43000, '{45500}', '5 Jul', false),
  ('wet-market', 'Eggs', 'Tray of 30', 21000, '{22000,22500}', '12 Aug', true),
  ('baking-supply', 'All-purpose flour', '1 kg', 8500, '{9000}', '5 Aug', true),
  ('baking-supply', 'Cocoa powder', '500 g', 44000, '{46500}', '9 Aug', true),
  ('baking-supply', 'Biscoff biscuits', '250 g', 21000, '{22500}', '11 Aug', true),
  ('baking-supply', 'Baking soda', '500 g', 10000, '{10500}', '28 Jul', true),
  ('baking-supply', 'Fine salt', '500 g', 3000, '{3500}', '28 Jul', true),
  ('baking-supply', 'Vanilla extract', '250 ml', 21000, '{22500}', '28 Jul', true),
  ('baking-supply', 'Red velvet gel colour', '100 ml', 24500, '{27000}', '28 Jul', true),
  ('baking-supply', 'Mini marshmallows', '500 g', 18500, '{20000}', '9 Aug', true),
  ('baking-supply', 'Graham crackers', '500 g', 15500, '{16000}', '9 Aug', true),
  ('baking-supply', 'Cinnamon', '250 g', 14000, '{15500}', '28 Jul', true),
  ('baking-supply', 'Shiro miso', '500 g', 43000, '{47500}', '28 Jul', true),
  ('baking-supply', 'Maldon sea salt', '250 g', 44000, '{48000}', '28 Jul', true)
on conflict (supplier_id, item_name) do nothing;

-- recipes -------------------------------------------------------------------
insert into recipes (product_id, yield_count) values
  ('wcb', 24),
  ('hc', 14),
  ('dcf', 24),
  ('pbm', 24),
  ('rvc', 24),
  ('nch', 13)
on conflict (product_id) do nothing;

insert into recipe_ingredients (product_id, item_name, qty, unit) values
  ('wcb', 'Unsalted butter', 360, 'g'),
  ('wcb', 'Brown sugar', 310, 'g'),
  ('wcb', 'White sugar', 145, 'g'),
  ('wcb', 'Eggs', 3, 'pcs'),
  ('wcb', 'Bread flour', 440, 'g'),
  ('wcb', 'Baking soda', 8, 'g'),
  ('wcb', 'Fine salt', 7, 'g'),
  ('wcb', 'Biscoff spread', 300, 'g'),
  ('wcb', 'Biscoff biscuits', 105, 'g'),
  ('wcb', 'White chocolate chips', 250, 'g'),
  ('hc', 'Unsalted butter', 360, 'g'),
  ('hc', 'Brown sugar', 380, 'g'),
  ('hc', 'Eggs', 3, 'pcs'),
  ('hc', 'Bread flour', 340, 'g'),
  ('hc', 'Baking soda', 4, 'g'),
  ('hc', 'Fine salt', 7, 'g'),
  ('hc', 'Milk chocolate', 370, 'g'),
  ('hc', 'Mini marshmallows', 130, 'g'),
  ('hc', 'Graham crackers', 145, 'g'),
  ('dcf', 'Unsalted butter', 350, 'g'),
  ('dcf', 'Brown sugar', 280, 'g'),
  ('dcf', 'Eggs', 3, 'pcs'),
  ('dcf', 'Bread flour', 540, 'g'),
  ('dcf', 'Cocoa powder', 65, 'g'),
  ('dcf', 'Baking soda', 7, 'g'),
  ('dcf', 'Dark chocolate 55%', 460, 'g'),
  ('dcf', 'Maldon sea salt', 9, 'g'),
  ('pbm', 'Unsalted butter', 210, 'g'),
  ('pbm', 'Brown sugar', 370, 'g'),
  ('pbm', 'Eggs', 1, 'pcs'),
  ('pbm', 'All-purpose flour', 380, 'g'),
  ('pbm', 'Chunky peanut butter', 360, 'g'),
  ('pbm', 'Shiro miso', 45, 'g'),
  ('pbm', 'Baking soda', 5, 'g'),
  ('pbm', 'White sugar', 175, 'g'),
  ('rvc', 'Unsalted butter', 430, 'g'),
  ('rvc', 'White sugar', 250, 'g'),
  ('rvc', 'Eggs', 3, 'pcs'),
  ('rvc', 'All-purpose flour', 360, 'g'),
  ('rvc', 'Cocoa powder', 45, 'g'),
  ('rvc', 'Red velvet gel colour', 17, 'ml'),
  ('rvc', 'Cream cheese', 400, 'g'),
  ('rvc', 'White chocolate chips', 230, 'g'),
  ('nch', 'Unsalted butter', 320, 'g'),
  ('nch', 'White sugar', 360, 'g'),
  ('nch', 'Eggs', 3, 'pcs'),
  ('nch', 'All-purpose flour', 440, 'g'),
  ('nch', 'Cinnamon', 20, 'g'),
  ('nch', 'Nutella', 380, 'g'),
  ('nch', 'Baking soda', 7, 'g'),
  ('nch', 'Vanilla extract', 7, 'ml');

-- allergens (MP-09 c1)
update products set allergens = v.allergens from (values
  ('dcf', 'milk, eggs, wheat, soy'),
  ('hc', 'milk, eggs, wheat, soy'),
  ('wcb', 'milk, eggs, wheat, soy'),
  ('pbm', 'milk, eggs, wheat, soy, peanuts'),
  ('rvc', 'milk, eggs, wheat, soy'),
  ('nch', 'milk, eggs, wheat, soy, tree nuts')
) as v (id, allergens) where products.id = v.id;

-- links by identity (B3a)
select public.apply_identity_links(public.preview_identity_links() -> 'counts');

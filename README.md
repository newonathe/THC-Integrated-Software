# The Happy Cookie Ops

A small cookie business takes orders online, sells at weekend bazaars, bakes to a weekly limit and
keeps its own books. This app runs all of it from a phone: one place for orders, production, stock,
selling and money, built to keep working at a stall with a poor signal.

## What it does

| Area        | Purpose                                                                |
| ----------- | ---------------------------------------------------------------------- |
| **Home**    | What needs attention this week                                         |
| **Bazaar**  | Event days, a stall till that works offline, and end-of-day cash count |
| **Café**    | Bulk café sales and their expenses                                     |
| **Sell**    | Orders, payment checks and customers                                   |
| **Make**    | Recipes, batches and production planning                               |
| **Stock**   | Ingredients, packaging, suppliers and counts                           |
| **Shop**    | The customer storefront, checkout and order status                     |
| **Money**   | Sales, expenses and profit from one journal                            |
| **Account** | Settings, staff access and system health                               |

## Built with

Next.js 16 (App Router), React 19, TypeScript (strict), Tailwind CSS 4, Supabase (PostgreSQL, Auth,
Storage, Realtime), Vitest, Playwright. Installable as a PWA.

## How it works

- **Business rules** live in one engine (`src/store/engine`) that the runtime extends
  (`src/store/ops-runtime.tsx`). Screens render its output.
- **Server rules** are PostgreSQL functions called through `supabase-js`. Row-level security is the
  access boundary; functions check the caller's role, pin their search path and are granted explicitly.
- **Offline sales** wait in a queue on the device and are removed only after the server acknowledges
  them, so a lost connection neither drops nor repeats a sale.
- **Money** is stored in centavos as integers and converted in one place.

```text
src/app          routes, styles, fonts
src/components   screens, sheets, shell and live (signed-in) interfaces
src/lib          data access, rules, offline, auth, money, dates
src/store        business engine and runtime
supabase         schema migrations, synthetic seed, Edge Function
tests            unit and browser tests
scripts          build, seed and interface-integrity tools
```

## Run the demo

Needs Node 24.20.0 and pnpm 9.12.3. No backend or account is required.

```bash
pnpm install --frozen-lockfile
pnpm dev
```

Open http://localhost:3000. The demo keeps its data in the browser and shows the original reviewed
screens, with switches for device and role. The newer signed-in interface, including Café, needs a
database and a live-mode build, which this demo does not set up.

People, recipes, suppliers, costs, orders, payment accounts and default fees are made up. The payment QR images are
placeholders: **do not send money to anything shown in the demo.**

### Optional local database

Needs Docker and Supabase CLI 2.116.0. Copy `.env.example` to `.env.local` and use the local values the
CLI prints.

```bash
pnpm db:start
pnpm db:reset
```

## Verify

```bash
pnpm verify        # interface integrity, types, lint, unit tests
pnpm format:check
pnpm build
pnpm test:e2e      # browser tests, after a build
```

## Status

In development. This repository covers the application, its schema and standalone tests. Hosted
deployment, physical-device checks and final acceptance are outside its tests, and it has had no
security certification. Its default business values are stand-ins, so it must not be deployed as is.

The product name, logo and photographs belong to their owner and are shown with permission. No licence
to reuse the code or artwork is granted. Bundled fonts keep their own licences in `src/app/fonts`.

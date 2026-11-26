/**
 * Keeps this repository to what it is for: source, schema, synthetic data and tests.
 * Catches accidents: any tracked file that is not an approved kind in an approved place, or that deploys.
 * A pull request can edit this file, so review still decides.
 * The defaults here are made up, so nothing in this repository may be deployed.
 */
import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';

const files = execFileSync('git', ['ls-files', '-z'], { encoding: 'utf8' })
  .split('\0')
  .filter(Boolean);

const ALLOWED = new Set(
  (
    '.env.example .github .gitignore .npmrc .nvmrc .prettierignore README.md eslint.config.mjs instrumentation-client.ts ' +
    'instrumentation.ts next.config.ts package.json playwright.config.ts pnpm-lock.yaml postcss.config.mjs ' +
    'prettier.config.mjs public scripts sentry.edge.config.ts sentry.server.config.ts src supabase tests ' +
    'tsconfig.e2e.json tsconfig.json vitest.config.ts'
  ).split(' ')
);
// Only these kinds of file, in these places. Anything else needs a reviewed change here.
const KINDS = [
  /^(src|tests|scripts)\/.*\.(tsx?|m?js|css|json|woff2)$/,
  /^src\/app\/fonts\/[^/]+\.(txt|md)$/,
  /^supabase\/(migrations\/\d{14}_[a-z0-9_]+\.sql|seed\.sql|config\.toml|functions\/.*\.(ts|json))$/,
  /^public\/.*\.(png|js|webmanifest|svg|ico)$/,
  /^\.github\/(check-boundary\.mjs|workflows\/(ci|keep-alive)\.yml)$/,
  /^[^/]+$/
];
const HIDDEN_FOLDER = /\/\.[^/]+/;
const problems = [];
for (const file of files) {
  if (!ALLOWED.has(file.split('/')[0])) problems.push(`${file}: not on the approved list`);
  if (!KINDS.some((kind) => kind.test(file)) || HIDDEN_FOLDER.test(file))
    problems.push(`${file}: not an approved kind of file`);
  if (file.startsWith('.github/workflows/') || file === 'package.json') {
    const text = readFileSync(file, 'utf8').replace(/(^|\s)#.*$/gm, '');
    if (
      /wrangler|vercel|netlify|deploy|supabase\s+(link|db\s+push|functions|migration|secrets)/i.test(
        text
      )
    )
      problems.push(`${file}: deploys or changes a hosted service`);
  }
}

if (problems.length) {
  console.error(`Repository boundary FAILED:\n  ${problems.join('\n  ')}`);
  process.exit(1);
}
console.log(`Repository boundary OK (${files.length} files).`);

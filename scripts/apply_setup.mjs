/**
 * Applique le setup SQL via l'API Management Supabase.
 * Prérequis: variable d'environnement SUPABASE_ACCESS_TOKEN (Personal Access Token)
 *   https://supabase.com/dashboard/account/tokens
 *
 * Usage:
 *   $env:SUPABASE_ACCESS_TOKEN="sbp_..."
 *   node scripts/apply_setup.mjs
 */
const fs = require('fs');
const path = require('path');

const PROJECT_REF = 'rrrlkvcfxykyhscrswzi';
const token = process.env.SUPABASE_ACCESS_TOKEN;

if (!token) {
  console.error('Manque SUPABASE_ACCESS_TOKEN');
  process.exit(1);
}

async function runSql(query) {
  const res = await fetch(`https://api.supabase.com/v1/projects/${PROJECT_REF}/database/query`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ query }),
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`${res.status} ${text}`);
  }
  return text;
}

(async () => {
  const sqlPath = path.join(__dirname, '..', 'docs', 'supabase_setup_all.sql');
  const sql = fs.readFileSync(sqlPath, 'utf8');
  console.log('Applying setup SQL...');
  const result = await runSql(sql);
  console.log('OK', result.slice(0, 200));
})().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});

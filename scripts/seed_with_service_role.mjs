/**
 * Seed / verify with service_role (NE PAS committer la clé).
 * Usage: node scripts/seed_with_service_role.mjs
 */
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

const url = 'https://rrrlkvcfxykyhscrswzi.supabase.co';
const serviceRole = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!serviceRole) {
  console.error('Set SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

const supabase = createClient(url, serviceRole, {
  auth: { persistSession: false, autoRefreshToken: false },
});

const products = JSON.parse(
  fs.readFileSync(path.join(__dirname, '..', 'docs', 'products_seed.json'), 'utf8'),
);

const categories = [
  { id: 'smartphones', label: 'Smartphones' },
  { id: 'ordinateurs', label: 'Ordinateurs' },
  { id: 'tv', label: 'TV & Vidéo' },
  { id: 'audio', label: 'Audio' },
  { id: 'accessoires', label: 'Accessoires' },
  { id: 'eclairage', label: 'Éclairage LED' },
  { id: 'electromenager', label: 'Électroménager' },
];

const pickup = [
  {
    id: 'pk1',
    name: 'Voltify Ouaga Centre',
    address: 'Avenue Kwame Nkrumah, près du Rond-point des Nations',
    city: 'Ouagadougou',
    hours: 'Lun–Sam 9h–19h',
  },
  {
    id: 'pk2',
    name: 'Voltify Bobo Dioulasso',
    address: 'Secteur 4, Avenue de la Révolution',
    city: 'Bobo-Dioulasso',
    hours: 'Lun–Sam 9h–18h30',
  },
];

(async () => {
  const { error: cErr } = await supabase.from('categories').upsert(categories);
  if (cErr) throw cErr;
  const { error: pErr } = await supabase.from('pickup_points').upsert(pickup);
  if (pErr) throw pErr;
  const { error: prErr } = await supabase.from('products').upsert(products);
  if (prErr) throw prErr;
  const { count, error } = await supabase
    .from('products')
    .select('*', { count: 'exact', head: true });
  if (error) throw error;
  console.log('SEED_OK products=', count);
})().catch((e) => {
  console.error('SEED_FAIL', e.message || e);
  process.exit(1);
});

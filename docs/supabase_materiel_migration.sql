-- Migration « catalogue matériel » Voltify
-- À passer APRÈS supabase_setup_all.sql et supabase_lighting_migration.sql.
--
-- Fait basculer la boutique de la taxonomie Éclairage (LED Corner) vers la
-- nomenclature Décoration · Menuiserie · Enseignes : 8 univers, 37 rayons.
-- L'éclairage n'est plus le catalogue, il en devient un rayon.

-- 1. Colonnes attendues par l'app -------------------------------------------

alter table products add column if not exists subcategory_id text;
alter table products add column if not exists image_url text;

-- Mode de vente : 'panier' (prix ferme) ou 'devis' (sur mesure).
-- NULL = on hérite du rayon, comme côté Flutter.
alter table products add column if not exists sale_mode text
  check (sale_mode in ('panier', 'devis'));

-- 2. Univers -----------------------------------------------------------------

insert into categories (id, label) values
  ('deco_interieure', 'Décoration intérieure'),
  ('deco_exterieure', 'Décoration extérieure'),
  ('menuiserie', 'Menuiserie moderne'),
  ('enseignes', 'Enseignes & signalétique'),
  ('fabrication', 'Fabrication & pose'),
  ('electrique', 'Matériel électrique'),
  ('vitrerie', 'Vitrerie & verre'),
  ('consommables', 'Finitions & consommables')
on conflict (id) do update set label = excluded.label;

-- 3. Rayons ------------------------------------------------------------------
-- Table dédiée : jusqu'ici les sous-catégories n'existaient que dans le code
-- Flutter, ce qui empêchait la console admin de proposer une liste fermée.

create table if not exists subcategories (
  id text not null,
  category_id text not null references categories(id) on delete cascade,
  label text not null,
  sale_mode text not null default 'panier'
    check (sale_mode in ('panier', 'devis')),
  position integer not null default 0,
  primary key (category_id, id)
);

insert into subcategories (category_id, id, label, sale_mode, position) values
  -- Décoration intérieure
  ('deco_interieure', 'revetements_muraux', 'Revêtements muraux', 'panier', 1),
  ('deco_interieure', 'plafonds', 'Plafonds', 'devis', 2),
  ('deco_interieure', 'eclairage_deco', 'Éclairage décoratif', 'panier', 3),
  ('deco_interieure', 'sols', 'Sols', 'panier', 4),
  ('deco_interieure', 'mur_tv', 'Décoration TV / mur TV', 'devis', 5),
  ('deco_interieure', 'miroiterie', 'Miroiterie et verre', 'panier', 6),
  ('deco_interieure', 'ameublement', 'Décoration et ameublement', 'panier', 7),
  -- Décoration extérieure
  ('deco_exterieure', 'facades', 'Façades', 'devis', 1),
  ('deco_exterieure', 'terrasses', 'Terrasses', 'devis', 2),
  ('deco_exterieure', 'jardins', 'Jardins', 'panier', 3),
  ('deco_exterieure', 'eclairage_exterieur', 'Éclairage extérieur', 'panier', 4),
  ('deco_exterieure', 'clotures', 'Clôtures et séparation', 'devis', 5),
  ('deco_exterieure', 'pergolas', 'Pergolas et espaces extérieurs', 'devis', 6),
  -- Menuiserie moderne
  ('menuiserie', 'bois_panneaux', 'Menuiserie bois — Panneaux', 'panier', 1),
  ('menuiserie', 'bois_finitions', 'Menuiserie bois — Finitions', 'panier', 2),
  ('menuiserie', 'aluminium', 'Menuiserie aluminium', 'devis', 3),
  ('menuiserie', 'alu_accessoires', 'Aluminium — Accessoires', 'panier', 4),
  ('menuiserie', 'metallique', 'Menuiserie métallique', 'panier', 5),
  ('menuiserie', 'meubles_mesure', 'Meubles sur mesure', 'devis', 6),
  ('menuiserie', 'portes', 'Portes modernes', 'devis', 7),
  ('menuiserie', 'quincaillerie', 'Quincaillerie moderne', 'panier', 8),
  -- Enseignes & signalétique
  ('enseignes', 'enseignes_lumineuses', 'Enseignes lumineuses', 'devis', 1),
  ('enseignes', 'enseignes_non_lumineuses', 'Enseignes non lumineuses', 'devis', 2),
  ('enseignes', 'materiaux_enseignes', 'Matériaux pour enseignes', 'panier', 3),
  ('enseignes', 'caissons', 'Caissons', 'devis', 4),
  ('enseignes', 'signaletique', 'Signalétique', 'devis', 5),
  -- Fabrication & pose
  ('fabrication', 'outillage_bois', 'Travail du bois', 'panier', 1),
  ('fabrication', 'outillage_metal', 'Travail du métal', 'panier', 2),
  ('fabrication', 'machines_enseignes', 'Fabrication d''enseignes', 'devis', 3),
  ('fabrication', 'outillage_pose', 'Pose', 'panier', 4),
  -- Matériel électrique
  ('electrique', 'led', 'LED', 'panier', 1),
  ('electrique', 'alimentation', 'Alimentation', 'panier', 2),
  ('electrique', 'luminaires_techniques', 'Luminaires techniques', 'panier', 3),
  ('electrique', 'installation', 'Installation', 'panier', 4),
  -- Vitrerie & verre
  ('vitrerie', 'types_verre', 'Types de verre', 'panier', 1),
  ('vitrerie', 'applications_verre', 'Applications', 'devis', 2),
  -- Finitions & consommables
  ('consommables', 'peintures_colles', 'Peintures, vernis & colles', 'panier', 1),
  ('consommables', 'abrasifs_coupe', 'Abrasifs & outils de coupe', 'panier', 2),
  ('consommables', 'visserie', 'Visserie & fixations', 'panier', 3),
  ('consommables', 'adhesifs', 'Adhésifs & films', 'panier', 4)
on conflict (category_id, id) do update
  set label = excluded.label,
      sale_mode = excluded.sale_mode,
      position = excluded.position;

-- 4. Reclassement des produits éclairage existants ---------------------------
-- L'app ne garde du catalogue distant que les produits rangés dans un univers
-- connu : sans ce reclassement, la boutique retomberait sur les données mock.

update products set category_id = 'deco_interieure', subcategory_id = 'eclairage_deco'
  where category_id = 'indoor';

update products set category_id = 'deco_exterieure', subcategory_id = 'eclairage_exterieur'
  where category_id in ('outdoor', 'landscape', 'underwater');

update products set category_id = 'electrique', subcategory_id = 'luminaires_techniques'
  where category_id = 'industrial';

update products set category_id = 'electrique', subcategory_id = 'alimentation'
  where category_id = 'accessories' and subcategory_id in ('drivers', 'dimmers');

update products set category_id = 'electrique', subcategory_id = 'installation'
  where category_id = 'accessories';

update products set category_id = 'electrique', subcategory_id = 'led'
  where category_id = 'architectural' and subcategory_id in ('neon_flex', 'strips_rgb');

update products set category_id = 'electrique', subcategory_id = 'installation'
  where category_id = 'architectural' and subcategory_id = 'aluminum_profile';

update products set category_id = 'deco_exterieure', subcategory_id = 'eclairage_exterieur'
  where category_id = 'architectural';

update products set category_id = 'electrique', subcategory_id = 'led'
  where category_id = 'signage' and subcategory_id in ('strips_rgb', 'rope', 'programmable', 'motif');

-- Une enseigne prête à poser garde un prix ferme malgré un rayon sur devis.
update products set category_id = 'enseignes', subcategory_id = 'enseignes_lumineuses',
                    sale_mode = 'panier'
  where category_id = 'signage';

-- 5. Anciens univers ---------------------------------------------------------
-- À exécuter une fois le reclassement vérifié (select ci-dessous à 0 ligne).
--
--   select category_id, count(*) from products
--    where category_id in ('indoor','outdoor','landscape','architectural',
--                          'industrial','signage','underwater','accessories')
--    group by category_id;
--
-- delete from categories where id in (
--   'indoor','outdoor','landscape','architectural',
--   'industrial','signage','underwater','accessories'
-- );

-- 6. Demandes de devis -------------------------------------------------------
-- Le sur-mesure ne passe pas par le panier : sans cette table, la demande
-- reste sur le téléphone du client et personne ne la voit.

create table if not exists quote_requests (
  id uuid primary key default gen_random_uuid(),
  product_id text references products(id) on delete set null,
  product_name text not null,
  category_id text,
  subcategory_id text,
  customer_name text not null,
  phone text not null,
  email text,
  city text,
  details text default '',
  status text not null default 'nouveau'
    check (status in ('nouveau', 'en_cours', 'devis_envoye', 'gagne', 'perdu')),
  user_id uuid references auth.users on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists quote_requests_status_idx
  on quote_requests (status, created_at desc);

alter table quote_requests enable row level security;

-- Un client au Burkina commande sans compte : le dépôt doit rester ouvert,
-- la lecture non.
drop policy if exists "quote_insert_public" on quote_requests;
create policy "quote_insert_public" on quote_requests
  for insert with check (true);

drop policy if exists "quote_select_own" on quote_requests;
create policy "quote_select_own" on quote_requests
  for select using (auth.uid() is not null and user_id = auth.uid());

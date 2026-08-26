-- Migration luminaires Voltify (après supabase_setup_all.sql)
-- Ajoute sous-catégories + images produits

alter table products add column if not exists subcategory_id text;
alter table products add column if not exists image_url text;

-- Optionnel: nettoyer l'ancien catalogue électronique
-- delete from order_items;
-- delete from products where category_id not in (
--   'architectural','indoor','industrial','outdoor','landscape','signage','underwater','accessories'
-- );

insert into categories (id, label) values
  ('architectural', 'Architectural / Façade'),
  ('indoor', 'Indoor / Résidentiel'),
  ('industrial', 'Industriel / Entrepôt'),
  ('outdoor', 'Extérieur'),
  ('landscape', 'Paysage / Jardin'),
  ('signage', 'Signalétique / Publicité'),
  ('underwater', 'Sous-marin / Piscine'),
  ('accessories', 'Accessoires LED')
on conflict (id) do update set label = excluded.label;

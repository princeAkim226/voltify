-- Activez aussi Authentication > Providers > Anonymous (ON)
-- Fichier combiné schéma + seed : docs/supabase_setup_all.sql

create extension if not exists "pgcrypto";

create table if not exists categories (
  id text primary key,
  label text not null
);

create table if not exists products (
  id text primary key,
  name text not null,
  brand text not null,
  category_id text not null references categories(id),
  price integer not null,
  old_price integer,
  description text,
  badge text,
  rating numeric(3,1) default 4.5,
  review_count integer default 0,
  in_stock boolean default true,
  specs jsonb default '[]'::jsonb,
  points_reward integer default 50,
  loyalty_track text check (loyalty_track in ('lumineux', 'deco')) default 'lumineux'
);

create table if not exists pickup_points (
  id text primary key,
  name text not null,
  address text not null,
  city text not null,
  hours text not null
);

create table if not exists profiles (
  id uuid primary key references auth.users on delete cascade,
  full_name text,
  phone text,
  created_at timestamptz default now()
);

create table if not exists loyalty_balances (
  user_id uuid primary key references auth.users on delete cascade,
  lumineux integer default 0,
  deco integer default 0,
  updated_at timestamptz default now()
);

create table if not exists orders (
  id text primary key,
  user_id uuid references auth.users,
  customer_name text not null,
  phone text not null,
  email text,
  delivery_mode text check (delivery_mode in ('delivery', 'pickup')) not null,
  address text,
  city text,
  pickup_point_id text,
  payment_method text not null,
  subtotal integer not null,
  delivery_fee integer not null,
  total integer not null,
  pts_lumineux integer default 0,
  pts_deco integer default 0,
  created_at timestamptz default now()
);

create table if not exists order_items (
  id uuid primary key default gen_random_uuid(),
  order_id text not null references orders(id) on delete cascade,
  product_id text not null references products(id),
  quantity integer not null check (quantity > 0),
  unit_price integer not null
);

alter table categories enable row level security;
alter table products enable row level security;
alter table pickup_points enable row level security;
alter table profiles enable row level security;
alter table loyalty_balances enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;

drop policy if exists "public read categories" on categories;
create policy "public read categories" on categories for select using (true);

drop policy if exists "public read products" on products;
create policy "public read products" on products for select using (true);

drop policy if exists "public read pickup" on pickup_points;
create policy "public read pickup" on pickup_points for select using (true);

drop policy if exists "users read own profile" on profiles;
create policy "users read own profile" on profiles for select using (auth.uid() = id);
drop policy if exists "users upsert own profile" on profiles;
create policy "users upsert own profile" on profiles for insert with check (auth.uid() = id);
drop policy if exists "users update own profile" on profiles;
create policy "users update own profile" on profiles for update using (auth.uid() = id);

drop policy if exists "users read own loyalty" on loyalty_balances;
create policy "users read own loyalty" on loyalty_balances for select using (auth.uid() = user_id);
drop policy if exists "users insert own loyalty" on loyalty_balances;
create policy "users insert own loyalty" on loyalty_balances for insert with check (auth.uid() = user_id);
drop policy if exists "users update own loyalty" on loyalty_balances;
create policy "users update own loyalty" on loyalty_balances for update using (auth.uid() = user_id);

drop policy if exists "users read own orders" on orders;
create policy "users read own orders" on orders for select using (auth.uid() = user_id);
drop policy if exists "users insert own orders" on orders;
create policy "users insert own orders" on orders for insert with check (auth.uid() = user_id or user_id is null);
drop policy if exists "anon insert orders" on orders;
create policy "anon insert orders" on orders for insert with check (true);
drop policy if exists "anon read recent orders by id" on orders;
create policy "anon read recent orders by id" on orders for select using (true);

drop policy if exists "public insert order items" on order_items;
create policy "public insert order items" on order_items for insert with check (true);
drop policy if exists "public read order items" on order_items;
create policy "public read order items" on order_items for select using (true);

-- Seed catégories
insert into categories (id, label) values
  ('smartphones', 'Smartphones'),
  ('ordinateurs', 'Ordinateurs'),
  ('tv', 'TV & Vidéo'),
  ('audio', 'Audio'),
  ('accessoires', 'Accessoires'),
  ('eclairage', 'Éclairage LED'),
  ('electromenager', 'Électroménager')
on conflict (id) do update set label = excluded.label;

insert into pickup_points (id, name, address, city, hours) values
  ('pk1', 'Voltify Ouaga Centre', 'Avenue Kwame Nkrumah, près du Rond-point des Nations', 'Ouagadougou', 'Lun–Sam 9h–19h'),
  ('pk2', 'Voltify Bobo Dioulasso', 'Secteur 4, Avenue de la Révolution', 'Bobo-Dioulasso', 'Lun–Sam 9h–18h30')
on conflict (id) do update set name = excluded.name, address = excluded.address, city = excluded.city, hours = excluded.hours;

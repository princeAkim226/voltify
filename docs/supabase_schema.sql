-- Voltify Supabase schema (préparé pour branchement futur)
-- Activer Anonymous Auth dans le dashboard Supabase pour le guest checkout.

create extension if not exists "pgcrypto";

create table if not exists profiles (
  id uuid primary key references auth.users on delete cascade,
  full_name text,
  phone text,
  created_at timestamptz default now()
);

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
  rating numeric(2,1) default 4.5,
  review_count integer default 0,
  in_stock boolean default true,
  specs jsonb default '[]'::jsonb,
  points_reward integer default 50,
  loyalty_track text check (loyalty_track in ('lumineux', 'deco')) default 'lumineux'
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

-- RLS à activer avant prod :
-- alter table products enable row level security;
-- create policy "public read products" on products for select using (true);

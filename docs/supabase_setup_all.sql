-- Voltify â€” schÃ©ma + RLS (guest checkout via auth anonyme)
-- Ã€ exÃ©cuter dans SQL Editor Supabase

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

-- Seed catÃ©gories
insert into categories (id, label) values
  ('smartphones', 'Smartphones'),
  ('ordinateurs', 'Ordinateurs'),
  ('tv', 'TV & VidÃ©o'),
  ('audio', 'Audio'),
  ('accessoires', 'Accessoires'),
  ('eclairage', 'Ã‰clairage LED'),
  ('electromenager', 'Ã‰lectromÃ©nager')
on conflict (id) do update set label = excluded.label;

insert into pickup_points (id, name, address, city, hours) values
  ('pk1', 'Voltify Ouaga Centre', 'Avenue Kwame Nkrumah, prÃ¨s du Rond-point des Nations', 'Ouagadougou', 'Lunâ€“Sam 9hâ€“19h'),
  ('pk2', 'Voltify Bobo Dioulasso', 'Secteur 4, Avenue de la RÃ©volution', 'Bobo-Dioulasso', 'Lunâ€“Sam 9hâ€“18h30')
on conflict (id) do update set name = excluded.name, address = excluded.address, city = excluded.city, hours = excluded.hours;
insert into products (id,name,brand,category_id,price,old_price,description,badge,rating,review_count,in_stock,specs,points_reward,loyalty_track) values
('s1','Galaxy A35 5G 128 Go','Samsung','smartphones',189000,219000,'Ecran Super AMOLED 6.6, 50 MP, batterie 5000 mAh.','-14%',4.6,128,true,'["6.6 AMOLED","128 Go / 8 Go","50 MP","5000 mAh","5G"]'::jsonb,120,'lumineux'),
('s2','Redmi Note 13 Pro','Xiaomi','smartphones',165000,185000,'Capteur 200 MP, charge rapide 67 W.','Promo',4.5,96,true,'["6.67 AMOLED","256 Go / 8 Go","200 MP","Charge 67W"]'::jsonb,110,'lumineux'),
('s3','iPhone 13 128 Go','Apple','smartphones',425000,null,'Performance A15, photos excellentes.',null,4.8,210,true,'["6.1 OLED","128 Go","Double camera","Face ID"]'::jsonb,250,'lumineux'),
('s4','Tecno Camon 30','Tecno','smartphones',99000,115000,'Excellent rapport qualite-prix.','Best-seller',4.3,74,true,'["6.78","256 Go / 8 Go","50 MP","5000 mAh"]'::jsonb,70,'lumineux'),
('s5','Infinix Hot 40 Pro','Infinix','smartphones',89000,null,'Entree de gamme solide.','Des 89k',4.2,55,true,'["6.78","128 Go / 8 Go","108 MP","5000 mAh"]'::jsonb,60,'lumineux'),
('o1','Laptop IdeaPad 15 i5','Lenovo','ordinateurs',385000,420000,'Ultrabook polyvalent etudes et bureau.','-8%',4.4,42,true,'["15.6 FHD","i5 12e gen","16 Go RAM","512 Go SSD"]'::jsonb,200,'lumineux'),
('o2','MacBook Air M1 256 Go','Apple','ordinateurs',650000,null,'Silence et autonomie exceptionnelle.',null,4.9,88,true,'["13.3 Retina","Apple M1","8 Go","256 Go SSD"]'::jsonb,350,'lumineux'),
('o3','HP Pavilion x360','HP','ordinateurs',445000,null,'Convertible tactile 2-en-1.',null,4.3,31,true,'["14 tactile","i5","16 Go","512 Go SSD"]'::jsonb,220,'lumineux'),
('o4','Chromebook Acer 14','Acer','ordinateurs',175000,null,'Leger et rapide pour Google Workspace.','Etudiants',4.1,27,true,'["14 FHD","8 Go","128 Go","ChromeOS"]'::jsonb,90,'lumineux'),
('t1','Smart TV 43 4K UHD','Samsung','tv',245000,275000,'Image nette, apps streaming integrees.','4K',4.5,63,true,'["43 4K","Smart Hub","HDR","3 HDMI"]'::jsonb,150,'lumineux'),
('t2','Smart TV 55 QLED','Samsung','tv',520000,null,'Couleurs QLED eclatantes.',null,4.7,41,true,'["55 QLED","4K HDR","Gaming Hub","Dolby Atmos"]'::jsonb,280,'lumineux'),
('t3','Android TV 32 HD','TCL','tv',95000,null,'Parfait chambre ou studio.','Compact',4.2,50,true,'["32 HD","Android TV","Wi-Fi","2 HDMI"]'::jsonb,65,'lumineux'),
('t4','TV LED 50 Full HD','Hisense','tv',198000,null,'Grand ecran abordable.',null,4.3,36,true,'["50 FHD","Smart","USB media","HDMI"]'::jsonb,120,'lumineux'),
('a1','AirPods Pro 2e gen','Apple','audio',185000,null,'Reduction de bruit active.',null,4.8,112,true,'["ANC","Spatial Audio","IPX4","USB-C"]'::jsonb,100,'deco'),
('a2','Soundcore Life Q30','Anker','audio',52000,65000,'Casque Bluetooth ANC, 40 h.','-20%',4.6,89,true,'["ANC","40 h","Bluetooth 5","Pliable"]'::jsonb,55,'deco'),
('a3','Enceinte Flip 6','JBL','audio',78000,null,'Son puissant, etanche IP67.',null,4.7,77,true,'["IP67","12 h","PartyBoost","USB-C"]'::jsonb,70,'deco'),
('a4','Barre de son 2.1','Sony','audio',135000,null,'Ameliore le son TV.',null,4.4,29,true,'["2.1","Bluetooth","HDMI ARC","USB"]'::jsonb,85,'deco'),
('x1','Chargeur GaN 65W','Baseus','accessoires',18500,null,'Charge rapide multi-ports.','Essentiel',4.5,140,true,'["65W GaN","2 USB-C","1 USB-A","Compact"]'::jsonb,25,'deco'),
('x2','Powerbank 20000 mAh','Xiaomi','accessoires',22000,null,'Batterie de secours.',null,4.4,201,true,'["20000 mAh","18W","2 sorties","LED"]'::jsonb,30,'deco'),
('x3','Coque + verre Galaxy A35','Spigen','accessoires',8500,null,'Protection antichoc.',null,4.3,64,true,'["Antichoc","Transparent","Verre 9H"]'::jsonb,15,'deco'),
('x4','Clavier + souris sans fil','Logitech','accessoires',32000,null,'Combo bureau silencieux.',null,4.5,48,true,'["2.4 GHz","Silencieux","AA","AZERTY"]'::jsonb,35,'deco'),
('e1','Kit bande LED RGB 5m','Govee','eclairage',28000,35000,'Ambiance connectee via app.','-20%',4.6,93,true,'["5 m","RGBIC","App Wi-Fi","Alim 12V"]'::jsonb,40,'lumineux'),
('e2','Ampoules LED E27 x4','Philips','eclairage',12000,null,'Eclairage economique 3000K.',null,4.5,120,true,'["E27","9W","3000K","Lot de 4"]'::jsonb,20,'lumineux'),
('e3','Lampe de bureau LED','Xiaomi','eclairage',24500,null,'Bras flexible dimmable.',null,4.4,57,true,'["USB-C","Dimmable","Bras flexible"]'::jsonb,30,'lumineux'),
('e4','Projecteur LED 50W','Osram','eclairage',18500,null,'Eclairage cour IP65.','Exterieur',4.3,38,true,'["50W","IP65","6500K","220V"]'::jsonb,25,'lumineux'),
('m1','Ventilateur pedestal 16','Binatone','electromenager',35000,null,'3 vitesses, oscillation.',null,4.2,81,true,'["16","3 vitesses","Oscillation","Minuterie"]'::jsonb,40,'lumineux'),
('m2','Refrigerateur 150L','Hisense','electromenager',185000,205000,'Compact et econome.','Promo',4.4,45,true,'["150 L","Classe A+","Congelateur","Silent"]'::jsonb,130,'lumineux'),
('m3','Micro-ondes 20L','Samsung','electromenager',68000,null,'Decongelation rapide.',null,4.3,52,true,'["20 L","700W","5 niveaux","Timer"]'::jsonb,55,'lumineux'),
('m4','Fer a vapeur ceramique','Philips','electromenager',28000,null,'Glisse facile anti-calcaire.',null,4.5,66,true,'["2400W","Ceramique","Anti-goutte"]'::jsonb,30,'lumineux'),
('m5','Mixeur blender 1.5L','Moulinex','electromenager',42000,null,'Smoothies et sauces.',null,4.4,39,true,'["1.5 L","500W","Verre","2 vitesses"]'::jsonb,35,'lumineux')
on conflict (id) do update set name=excluded.name, brand=excluded.brand, price=excluded.price, old_price=excluded.old_price, description=excluded.description, badge=excluded.badge, rating=excluded.rating, review_count=excluded.review_count, specs=excluded.specs, points_reward=excluded.points_reward, loyalty_track=excluded.loyalty_track;

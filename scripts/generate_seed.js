const fs = require('fs');

const products = [
  {id:'s1',name:'Galaxy A35 5G 128 Go',brand:'Samsung',category_id:'smartphones',price:189000,old_price:219000,badge:'-14%',rating:4.6,review_count:128,points_reward:120,loyalty_track:'lumineux',description:'Ecran Super AMOLED 6.6, 50 MP, batterie 5000 mAh.',specs:['6.6 AMOLED','128 Go / 8 Go','50 MP','5000 mAh','5G']},
  {id:'s2',name:'Redmi Note 13 Pro',brand:'Xiaomi',category_id:'smartphones',price:165000,old_price:185000,badge:'Promo',rating:4.5,review_count:96,points_reward:110,loyalty_track:'lumineux',description:'Capteur 200 MP, charge rapide 67 W.',specs:['6.67 AMOLED','256 Go / 8 Go','200 MP','Charge 67W']},
  {id:'s3',name:'iPhone 13 128 Go',brand:'Apple',category_id:'smartphones',price:425000,old_price:null,badge:null,rating:4.8,review_count:210,points_reward:250,loyalty_track:'lumineux',description:'Performance A15, photos excellentes.',specs:['6.1 OLED','128 Go','Double camera','Face ID']},
  {id:'s4',name:'Tecno Camon 30',brand:'Tecno',category_id:'smartphones',price:99000,old_price:115000,badge:'Best-seller',rating:4.3,review_count:74,points_reward:70,loyalty_track:'lumineux',description:'Excellent rapport qualite-prix.',specs:['6.78','256 Go / 8 Go','50 MP','5000 mAh']},
  {id:'s5',name:'Infinix Hot 40 Pro',brand:'Infinix',category_id:'smartphones',price:89000,old_price:null,badge:'Des 89k',rating:4.2,review_count:55,points_reward:60,loyalty_track:'lumineux',description:'Entree de gamme solide.',specs:['6.78','128 Go / 8 Go','108 MP','5000 mAh']},
  {id:'o1',name:'Laptop IdeaPad 15 i5',brand:'Lenovo',category_id:'ordinateurs',price:385000,old_price:420000,badge:'-8%',rating:4.4,review_count:42,points_reward:200,loyalty_track:'lumineux',description:'Ultrabook polyvalent etudes et bureau.',specs:['15.6 FHD','i5 12e gen','16 Go RAM','512 Go SSD']},
  {id:'o2',name:'MacBook Air M1 256 Go',brand:'Apple',category_id:'ordinateurs',price:650000,old_price:null,badge:null,rating:4.9,review_count:88,points_reward:350,loyalty_track:'lumineux',description:'Silence et autonomie exceptionnelle.',specs:['13.3 Retina','Apple M1','8 Go','256 Go SSD']},
  {id:'o3',name:'HP Pavilion x360',brand:'HP',category_id:'ordinateurs',price:445000,old_price:null,badge:null,rating:4.3,review_count:31,points_reward:220,loyalty_track:'lumineux',description:'Convertible tactile 2-en-1.',specs:['14 tactile','i5','16 Go','512 Go SSD']},
  {id:'o4',name:'Chromebook Acer 14',brand:'Acer',category_id:'ordinateurs',price:175000,old_price:null,badge:'Etudiants',rating:4.1,review_count:27,points_reward:90,loyalty_track:'lumineux',description:'Leger et rapide pour Google Workspace.',specs:['14 FHD','8 Go','128 Go','ChromeOS']},
  {id:'t1',name:'Smart TV 43 4K UHD',brand:'Samsung',category_id:'tv',price:245000,old_price:275000,badge:'4K',rating:4.5,review_count:63,points_reward:150,loyalty_track:'lumineux',description:'Image nette, apps streaming integrees.',specs:['43 4K','Smart Hub','HDR','3 HDMI']},
  {id:'t2',name:'Smart TV 55 QLED',brand:'Samsung',category_id:'tv',price:520000,old_price:null,badge:null,rating:4.7,review_count:41,points_reward:280,loyalty_track:'lumineux',description:'Couleurs QLED eclatantes.',specs:['55 QLED','4K HDR','Gaming Hub','Dolby Atmos']},
  {id:'t3',name:'Android TV 32 HD',brand:'TCL',category_id:'tv',price:95000,old_price:null,badge:'Compact',rating:4.2,review_count:50,points_reward:65,loyalty_track:'lumineux',description:'Parfait chambre ou studio.',specs:['32 HD','Android TV','Wi-Fi','2 HDMI']},
  {id:'t4',name:'TV LED 50 Full HD',brand:'Hisense',category_id:'tv',price:198000,old_price:null,badge:null,rating:4.3,review_count:36,points_reward:120,loyalty_track:'lumineux',description:'Grand ecran abordable.',specs:['50 FHD','Smart','USB media','HDMI']},
  {id:'a1',name:'AirPods Pro 2e gen',brand:'Apple',category_id:'audio',price:185000,old_price:null,badge:null,rating:4.8,review_count:112,points_reward:100,loyalty_track:'deco',description:'Reduction de bruit active.',specs:['ANC','Spatial Audio','IPX4','USB-C']},
  {id:'a2',name:'Soundcore Life Q30',brand:'Anker',category_id:'audio',price:52000,old_price:65000,badge:'-20%',rating:4.6,review_count:89,points_reward:55,loyalty_track:'deco',description:'Casque Bluetooth ANC, 40 h.',specs:['ANC','40 h','Bluetooth 5','Pliable']},
  {id:'a3',name:'Enceinte Flip 6',brand:'JBL',category_id:'audio',price:78000,old_price:null,badge:null,rating:4.7,review_count:77,points_reward:70,loyalty_track:'deco',description:'Son puissant, etanche IP67.',specs:['IP67','12 h','PartyBoost','USB-C']},
  {id:'a4',name:'Barre de son 2.1',brand:'Sony',category_id:'audio',price:135000,old_price:null,badge:null,rating:4.4,review_count:29,points_reward:85,loyalty_track:'deco',description:'Ameliore le son TV.',specs:['2.1','Bluetooth','HDMI ARC','USB']},
  {id:'x1',name:'Chargeur GaN 65W',brand:'Baseus',category_id:'accessoires',price:18500,old_price:null,badge:'Essentiel',rating:4.5,review_count:140,points_reward:25,loyalty_track:'deco',description:'Charge rapide multi-ports.',specs:['65W GaN','2 USB-C','1 USB-A','Compact']},
  {id:'x2',name:'Powerbank 20000 mAh',brand:'Xiaomi',category_id:'accessoires',price:22000,old_price:null,badge:null,rating:4.4,review_count:201,points_reward:30,loyalty_track:'deco',description:'Batterie de secours.',specs:['20000 mAh','18W','2 sorties','LED']},
  {id:'x3',name:'Coque + verre Galaxy A35',brand:'Spigen',category_id:'accessoires',price:8500,old_price:null,badge:null,rating:4.3,review_count:64,points_reward:15,loyalty_track:'deco',description:'Protection antichoc.',specs:['Antichoc','Transparent','Verre 9H']},
  {id:'x4',name:'Clavier + souris sans fil',brand:'Logitech',category_id:'accessoires',price:32000,old_price:null,badge:null,rating:4.5,review_count:48,points_reward:35,loyalty_track:'deco',description:'Combo bureau silencieux.',specs:['2.4 GHz','Silencieux','AA','AZERTY']},
  {id:'e1',name:'Kit bande LED RGB 5m',brand:'Govee',category_id:'eclairage',price:28000,old_price:35000,badge:'-20%',rating:4.6,review_count:93,points_reward:40,loyalty_track:'lumineux',description:'Ambiance connectee via app.',specs:['5 m','RGBIC','App Wi-Fi','Alim 12V']},
  {id:'e2',name:'Ampoules LED E27 x4',brand:'Philips',category_id:'eclairage',price:12000,old_price:null,badge:null,rating:4.5,review_count:120,points_reward:20,loyalty_track:'lumineux',description:'Eclairage economique 3000K.',specs:['E27','9W','3000K','Lot de 4']},
  {id:'e3',name:'Lampe de bureau LED',brand:'Xiaomi',category_id:'eclairage',price:24500,old_price:null,badge:null,rating:4.4,review_count:57,points_reward:30,loyalty_track:'lumineux',description:'Bras flexible dimmable.',specs:['USB-C','Dimmable','Bras flexible']},
  {id:'e4',name:'Projecteur LED 50W',brand:'Osram',category_id:'eclairage',price:18500,old_price:null,badge:'Exterieur',rating:4.3,review_count:38,points_reward:25,loyalty_track:'lumineux',description:'Eclairage cour IP65.',specs:['50W','IP65','6500K','220V']},
  {id:'m1',name:'Ventilateur pedestal 16',brand:'Binatone',category_id:'electromenager',price:35000,old_price:null,badge:null,rating:4.2,review_count:81,points_reward:40,loyalty_track:'lumineux',description:'3 vitesses, oscillation.',specs:['16','3 vitesses','Oscillation','Minuterie']},
  {id:'m2',name:'Refrigerateur 150L',brand:'Hisense',category_id:'electromenager',price:185000,old_price:205000,badge:'Promo',rating:4.4,review_count:45,points_reward:130,loyalty_track:'lumineux',description:'Compact et econome.',specs:['150 L','Classe A+','Congelateur','Silent']},
  {id:'m3',name:'Micro-ondes 20L',brand:'Samsung',category_id:'electromenager',price:68000,old_price:null,badge:null,rating:4.3,review_count:52,points_reward:55,loyalty_track:'lumineux',description:'Decongelation rapide.',specs:['20 L','700W','5 niveaux','Timer']},
  {id:'m4',name:'Fer a vapeur ceramique',brand:'Philips',category_id:'electromenager',price:28000,old_price:null,badge:null,rating:4.5,review_count:66,points_reward:30,loyalty_track:'lumineux',description:'Glisse facile anti-calcaire.',specs:['2400W','Ceramique','Anti-goutte']},
  {id:'m5',name:'Mixeur blender 1.5L',brand:'Moulinex',category_id:'electromenager',price:42000,old_price:null,badge:null,rating:4.4,review_count:39,points_reward:35,loyalty_track:'lumineux',description:'Smoothies et sauces.',specs:['1.5 L','500W','Verre','2 vitesses']},
];

function esc(s) {
  return String(s).replace(/'/g, "''");
}

const rows = products.map((p) => {
  const old = p.old_price == null ? 'null' : p.old_price;
  const badge = p.badge == null ? 'null' : `'${esc(p.badge)}'`;
  return `('${p.id}','${esc(p.name)}','${esc(p.brand)}','${p.category_id}',${p.price},${old},'${esc(p.description)}',${badge},${p.rating},${p.review_count},true,'${JSON.stringify(p.specs).replace(/'/g, "''")}'::jsonb,${p.points_reward},'${p.loyalty_track}')`;
});

const sql = `insert into products (id,name,brand,category_id,price,old_price,description,badge,rating,review_count,in_stock,specs,points_reward,loyalty_track) values\n${rows.join(',\n')}\non conflict (id) do update set name=excluded.name, brand=excluded.brand, price=excluded.price, old_price=excluded.old_price, description=excluded.description, badge=excluded.badge, rating=excluded.rating, review_count=excluded.review_count, specs=excluded.specs, points_reward=excluded.points_reward, loyalty_track=excluded.loyalty_track;\n`;

fs.writeFileSync('docs/supabase_seed_products.sql', sql);
fs.writeFileSync('docs/products_seed.json', JSON.stringify(products, null, 2));
console.log('ok', products.length);

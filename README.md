# Voltify

Application mobile Flutter e-commerce pour la vente de **matériel de décoration, menuiserie et enseignes** au **Burkina Faso** (FCFA).

## Liens

- **Télécharger l’APK** : https://voltify-download-bf.netlify.app
- **Admin catalogue** : https://voltify.raaga-bf.com
- **API et Studio Supabase** : https://api.raaga-bf.com
- **Repo** : https://github.com/princeAkim226/voltify
- **Release GitHub** : https://github.com/princeAkim226/voltify/releases/tag/v1.0.0

## Fonctionnalités

- Catalogue sur 8 univers, 37 rayons et ~400 familles de produits
  (décoration intérieure et extérieure, menuiserie, enseignes, fabrication,
  matériel électrique, vitrerie, consommables)
- Recherche par famille : « charnière invisible », « pergola bioclimatique »
  orientent vers le bon rayon même sans produit en stock
- Deux modes de vente : **panier** pour le prix ferme, **devis** pour le
  sur-mesure (menuiserie, enseignes, pergolas, vitrerie posée)
- Fiche produit + produits similaires
- Panier et checkout invité (sans compte obligatoire)
- Livraison (Ouaga / Bobo) ou retrait magasin
- Paiement mobile simulé : Orange Money, Moov Money, Telecel Money, Wave
- Points fidélité Lumineux / Décoration
- Backend **Supabase auto-hébergé** sur notre VPS (schéma dans `docs/`)

## Catalogue

La nomenclature vit dans [`lib/data/mock/catalog_taxonomy.dart`](lib/data/mock/catalog_taxonomy.dart) :
un univers porte des rayons, un rayon porte des familles et un mode de vente
(`SaleMode.panier` ou `SaleMode.devis`) dont chaque produit hérite — surchargeable
article par article via `saleModeOverride`.

Côté base, la migration `docs/supabase_materiel_migration.sql` crée les univers,
la table `subcategories`, la table `quote_requests`, et reclasse les produits
issus de l'ancienne taxonomie Éclairage.

`test/catalog_taxonomy_test.dart` interdit qu'un produit pointe vers un rayon
inexistant ou qu'un article sans prix parte au panier.

## Lancer en local

```bash
flutter pub get
flutter run
```

## Build APK

En local :

```bash
flutter build apk --release
```

APK : `build/app/outputs/flutter-apk/app-release.apk`

### Build sur GitHub Actions

`.github/workflows/build-apk.yml`, déclenchement **manuel** (onglet Actions →
*Build APK* → *Run workflow*). Un push ne construit rien.

Le workflow analyse, teste, construit l'APK signé avec la clé de release et le
dépose en artefact. Il échoue volontairement si le keystore manque : un APK
signé en debug ne peut pas se mettre à jour par-dessus la version publiée.

Deux secrets sont requis dans **Settings → Secrets and variables → Actions** :

| Secret | Contenu |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `android/keystore/voltify-release.jks` encodé en base64 |
| `ANDROID_KEY_PROPERTIES` | le contenu de `android/key.properties`, tel quel |

Pour produire le base64 du keystore (PowerShell) :

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\keystore\voltify-release.jks")) | Set-Clipboard
```

Les deux fichiers sont gitignorés et ne doivent jamais être commités.

## Publication

La **console admin** tourne sur le VPS, pilotée par Coolify
(`https://voltify.raaga-bf.com`). Pour la mettre à jour : pousser sur `master`,
puis *Redeploy* depuis Coolify. L'image se construit depuis
`admin-server/Dockerfile`.

Le **site de téléchargement** reste sur Netlify, en déploiement manuel :

```bash
netlify deploy --prod --dir web_download \
  --site 6bd79847-4cf9-461a-a72d-73923d57a319      # voltify-download-bf
```

### Publier une nouvelle version de l'app

Dans cet ordre :

```bash
cp <apk-telecharge> web_download/voltify.apk   # 1. l'APK construit par la CI
node scripts/make_version_json.mjs             # 2. le manifeste, depuis l'APK réel
                                               # 3. version + taille dans index.html
netlify deploy --prod --dir web_download --site 6bd79847-4cf9-461a-a72d-73923d57a319
```

L'étape 2 lit `pubspec.yaml` et la taille réelle du fichier : elle refuse de
produire un manifeste incohérent. Ne l'écrivez jamais à la main.

La page et le manifeste ne doivent jamais annoncer une version différente de
l'APK servi à côté d'eux.

## Mise à jour de l'app

Voltify se distribue hors Play Store : personne ne prévient l'utilisateur, et
Android interdit à une app d'en installer une autre sans son accord. Une mise
à jour vraiment silencieuse est donc impossible.

Ce que fait l'app à la place (`lib/core/services/update_service.dart`) : au
lancement, elle lit `version.json` sur le site de téléchargement, compare le
`build` au sien, et propose la mise à jour — elle télécharge l'APK et ouvre
l'installateur système. Le client confirme d'un appui.

`minBuild` dans le manifeste rend la mise à jour **obligatoire** en dessous
d'un certain build : l'écran bloque l'app. À utiliser quand une version
ancienne ne sait plus lire les données en production, pas pour forcer une
nouveauté.

La vérification échoue en silence : réseau coupé, manifeste absent ou
malformé, la boutique s'ouvre normalement.

⚠️ Le contrôle de version doit être **dans** l'APK installé pour agir. Les
versions antérieures au build 2 ne l'ont pas : leurs utilisateurs doivent
installer 1.3.0 à la main une dernière fois.

## Stack

Flutter · Provider · Google Fonts · SharedPreferences

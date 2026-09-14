# AGENTS.md

Contexte destiné aux assistants de code (Codex, Cursor, Claude, Copilot…).
Lisible par n'importe lequel d'entre eux : ne rien écrire ici qui dépende d'un
outil particulier.

## Langue

Projet francophone : documentation, libellés UI et commentaires de code en
français. **Exception : les messages de commit sont en anglais**, suivant
l'historique du dépôt.

## Commandes

```bash
flutter pub get
flutter analyze
flutter test
flutter run

flutter build apk --release       # APK : build/app/outputs/flutter-apk/
```

Console admin, en local (les cinq variables sont obligatoires) :

```bash
cd admin-server
PORT=3999 ADMIN_USERNAME=x ADMIN_PASSWORD=y ADMIN_SESSION_SECRET=z \
  SUPABASE_URL=https://api.raaga-bf.com SUPABASE_SERVICE_ROLE_KEY=... node server.js
```

## Architecture

Flutter + Provider. Backend **Supabase auto-hébergé**. Voir `README.md` pour le
détail fonctionnel et `docs/` pour le schéma SQL.

```
lib/
  core/config/        # supabase_config.dart — URL et clé anon, EN DUR
  core/services/      # update_service.dart — mise à jour hors Play Store
  data/               # models, repositories, mock
  features/           # catalogue, panier, devis, compte
admin/                # console d'administration (HTML/JS statique)
admin-server/         # serveur Node qui sert admin/ et l'API — deploye sur le VPS
netlify/functions/    # admin-api.js — la logique metier de la console
docs/                 # schema et migrations SQL
```

## Infrastructure de production

Tout le backend tourne sur un VPS Contabo piloté par **Coolify**. Rien n'est
plus hébergé chez Supabase cloud.

| Service | Adresse |
|---|---|
| Panel Coolify | `panel.raaga-bf.com` |
| API Supabase + Studio | `api.raaga-bf.com` |
| Console admin | `voltify.raaga-bf.com` |
| Téléchargement APK | encore sur Netlify (`voltify-download-bf`) |

Le domaine `raaga-bf.com` a ses DNS chez **Netlify** ; le site racine est un
projet Next.js distinct, à ne pas toucher.

Déployer la console admin : pousser sur `master`, puis *Redeploy* dans Coolify.
L'image se construit depuis `admin-server/Dockerfile`, avec la racine du dépôt
comme contexte (il copie `admin/` et `netlify/`, situés au-dessus).

La base est sauvegardée chaque nuit à 2h sur le serveur
(`/usr/local/bin/sauvegarde-supabase.sh`, 14 jours de rétention).

## Règles non négociables

**L'URL du backend est gravée dans chaque APK installé.**
`lib/core/config/supabase_config.dart` et `update_service.dart` portent des
adresses en dur. Un client qui n'a pas mis à jour continue d'interroger
l'ancienne adresse **pour toujours** : changer l'une de ces URL sans publier une
nouvelle version coupe les installations existantes, sans aucun moyen de les
rattraper. C'est la raison pour laquelle le backend est joint par nom de domaine
et non par IP.

**`admin-server/server.js` doit refuser de démarrer sans ses variables.**
`netlify/functions/admin-api.js` contient des identifiants de repli codés en dur
et publiés dans ce dépôt public. Sans ce garde-fou, une variable oubliée
ouvrirait la console avec un mot de passe que tout le monde peut lire — et
l'onglet Devis expose les noms et téléphones des clients.

**Toute table exposée via PostgREST doit avoir RLS activé.** La clé anon voyage
dans l'APK et se récupère par décompilation : sans RLS, elle permet d'écrire,
pas seulement de lire. `subcategories` est passée à côté pendant des mois.

**La taxonomie est dupliquée** entre `admin/app.js` (`TAXONOMY`) et
`lib/data/mock/catalog_taxonomy.dart`. Les deux doivent rester alignées, sinon
un produit rangé dans un rayon inconnu de l'app n'apparaît nulle part.

**Le chemin `/.netlify/functions/admin-api` est conservé volontairement** dans
`admin-server/server.js`, bien qu'on ne soit plus sur Netlify : c'est celui
qu'appelle `admin/app.js`. Le renommer imposerait de modifier le front.

## Pièges connus de l'infrastructure

- **Docker contourne UFW.** `ufw deny` ne ferme pas un port publié par un
  conteneur. Lier le port à `127.0.0.1` à la place.
- **Coolify fige ses règles Traefik** dans la colonne `custom_labels`. Changer
  le domaine directement en base ne suffit pas : passer par l'interface, ou
  vider cette colonne pour forcer sa régénération.
- **Les variables saisies dans l'onglet *Preview* de Coolify** (`is_preview`)
  ne sont jamais injectées en production. Symptôme : le conteneur redémarre en
  boucle, les variables absentes.

## Git et livraison

`master` alimente la production. Messages de commit en anglais, décrivant le
**symptôme vécu par l'utilisateur** plutôt que la manipulation technique :

```
Stop letting the public key rewrite the catalog taxonomy.
Reach the backend by name instead of by IP address.
Tell the customer when a new version exists.
```

Le build APK GitHub Actions (`.github/workflows/build-apk.yml`) est **manuel**.
Il échoue volontairement si le keystore manque : un APK signé en debug ne peut
pas se mettre à jour par-dessus la version publiée.

Publier une version (ordre impératif) :

```bash
cp <apk> web_download/voltify.apk      # 1. l'APK construit par la CI
node scripts/make_version_json.mjs     # 2. le manifeste, depuis l'APK réel
                                       # 3. version et taille dans index.html
netlify deploy --prod --dir web_download --site 6bd79847-4cf9-461a-a72d-73923d57a319
```

Ne jamais écrire `version.json` à la main : la page et le manifeste ne doivent
jamais annoncer une version différente de l'APK servi à côté d'eux.

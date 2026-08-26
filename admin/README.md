# Voltify Admin — catalogue & commandes

Interface web pour administrer les produits Voltify (prix, description, stock, badges, etc.).

## Utilisation locale

Ouvrez `admin/index.html` via un serveur local, ou déployez le dossier `admin/` sur Netlify.

1. Collez l’URL Supabase
2. Collez la clé **service_role** (Settings → API)
3. Gérez les produits (créer / éditer / supprimer)

La clé reste dans `sessionStorage` du navigateur uniquement.

## Prérequis Supabase

Exécutez `docs/supabase_setup_all.sql` si les tables n’existent pas encore.

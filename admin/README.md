# Voltify Admin

Connexion par **identifiant / mot de passe** (plus de clé à coller).

## Accès

- URL : https://voltify.raaga-bf.com

Les identifiants ne sont **pas** dans ce dépôt : il est public. Ils vivent dans
Coolify → application `voltify` → Environment Variables, sous `ADMIN_USERNAME`
et `ADMIN_PASSWORD` (et `ADMIN_SESSION_SECRET` pour la signature des sessions).

`netlify/functions/admin-api.js` contient des valeurs de repli codées en dur,
visibles de tous. Elles ne servent qu'au développement local : sans les
variables, la console s'ouvrirait avec un mot de passe que tout le monde peut
lire sur GitHub — et l'onglet Devis expose les noms et numéros de téléphone des
clients.

C'est pourquoi `admin-server/server.js` **refuse de démarrer** tant que les cinq
variables ne sont pas définies. Un conteneur qui redémarre en boucle est un
symptôme attendu, pas une panne à contourner.

## Fonctionnalités

- CRUD produits (prix, description, stock, badges, points…)
- Consultation commandes
- **Demandes de devis** : le sur-mesure (menuiserie, enseignes, pergolas,
  vitrerie posée) n'a pas de prix ferme et ne passe pas par le panier. Les
  demandes déposées depuis l'app arrivent ici avec le projet décrit par le
  client. Le compteur rouge de l'onglet compte celles jamais traitées —
  un client non rappelé sous 48 h est un chantier perdu.
- Points de retrait

## Catalogue

La liste des univers et rayons est dupliquée dans `admin/app.js` (`TAXONOMY`)
et dans `lib/data/mock/catalog_taxonomy.dart`. **Les deux doivent rester
alignées** : un produit rangé dans un rayon absent de l'app n'apparaît nulle
part en boutique.

Les rayons marqués « sur devis » dans le sélecteur sont ceux dont les produits
ouvrent une demande de devis au lieu du panier.

La clé Supabase `service_role` ne quitte jamais le serveur : elle vit dans les
variables Coolify et n'est lue que par `admin-server/server.js`. Elle contourne
toutes les règles de sécurité de la base — quiconque la détient peut lire et
modifier l'intégralité des données.

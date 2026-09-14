const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');

const { handler } = require('../netlify/functions/admin-api.js');

const PORT = Number(process.env.PORT) || 3000;
const RACINE_STATIQUE = path.join(__dirname, '..', 'admin');
const TAILLE_MAX_CORPS = 10 * 1024 * 1024;

// admin/app.js appelle ce chemin, hérité de Netlify. Le conserver évite de
// toucher au front, qui reste déployable des deux côtés pendant la bascule.
const CHEMIN_API = '/.netlify/functions/admin-api';

// Sans ces variables, admin-api.js retombe sur des identifiants codés en dur
// et publiés dans un dépôt public : la console s'ouvrirait à n'importe qui,
// avec les noms et téléphones des clients dans l'onglet Devis.
const VARIABLES_REQUISES = [
  'ADMIN_USERNAME',
  'ADMIN_PASSWORD',
  'ADMIN_SESSION_SECRET',
  'SUPABASE_URL',
  'SUPABASE_SERVICE_ROLE_KEY',
];

const TYPES_MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.ico': 'image/x-icon',
};

function lireCorps(req) {
  return new Promise((resolve, reject) => {
    const morceaux = [];
    let taille = 0;
    req.on('data', (morceau) => {
      taille += morceau.length;
      if (taille > TAILLE_MAX_CORPS) {
        const erreur = new Error('Corps de requête trop volumineux');
        erreur.tropGros = true;
        req.destroy();
        reject(erreur);
        return;
      }
      morceaux.push(morceau);
    });
    req.on('end', () => resolve(Buffer.concat(morceaux).toString('utf8')));
    req.on('error', reject);
  });
}

function servirStatique(res, cheminUrl) {
  let demande;
  try {
    demande = decodeURIComponent(cheminUrl);
  } catch {
    res.writeHead(400, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('Requête invalide');
    return;
  }

  const relatif = path.posix.normalize(demande).replace(/^\/+/, '') || 'index.html';
  const cible = path.resolve(RACINE_STATIQUE, relatif);

  const ecart = path.relative(RACINE_STATIQUE, cible);
  if (ecart.startsWith('..') || path.isAbsolute(ecart)) {
    res.writeHead(403, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('Interdit');
    return;
  }

  fs.readFile(cible, (erreur, contenu) => {
    if (erreur) {
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('Introuvable');
      return;
    }
    const type = TYPES_MIME[path.extname(cible).toLowerCase()] || 'application/octet-stream';
    res.writeHead(200, { 'Content-Type': type });
    res.end(contenu);
  });
}

async function traiterApi(req, res, url) {
  let corps = '';
  try {
    if (req.method !== 'GET' && req.method !== 'HEAD') {
      corps = await lireCorps(req);
    }
  } catch (erreur) {
    const code = erreur.tropGros ? 413 : 400;
    res.writeHead(code, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify({ error: erreur.message }));
    return;
  }

  const parametres = {};
  for (const [cle, valeur] of url.searchParams) parametres[cle] = valeur;

  const reponse = await handler({
    httpMethod: req.method,
    path: url.pathname,
    queryStringParameters: parametres,
    headers: req.headers,
    body: corps,
    isBase64Encoded: false,
  });

  res.writeHead(reponse.statusCode, reponse.headers || {});
  res.end(reponse.body || '');
}

const serveur = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);

  if (url.pathname === CHEMIN_API) {
    traiterApi(req, res, url).catch((erreur) => {
      console.error('Erreur API :', erreur);
      res.writeHead(500, { 'Content-Type': 'application/json; charset=utf-8' });
      res.end(JSON.stringify({ error: 'Erreur serveur' }));
    });
    return;
  }

  servirStatique(res, url.pathname);
});

const manquantes = VARIABLES_REQUISES.filter((nom) => !process.env[nom]);
if (manquantes.length > 0) {
  console.error(
    `Démarrage refusé — variables d'environnement manquantes : ${manquantes.join(', ')}`,
  );
  process.exit(1);
}

serveur.listen(PORT, () => {
  console.log(`Console admin Voltify sur le port ${PORT}`);
});

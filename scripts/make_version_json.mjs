#!/usr/bin/env node
// Génère web_download/version.json à partir de pubspec.yaml et de l'APK
// réellement présent dans web_download/.
//
// À lancer APRÈS avoir copié le nouvel APK, AVANT de déployer le site :
//
//   node scripts/make_version_json.mjs
//
// Écrire ce fichier à la main finit toujours par annoncer une version ou une
// taille qui ne correspond pas au fichier servi — l'app téléchargerait alors
// 23 Mo pour rien, ou se croirait à jour à tort.

import { readFileSync, writeFileSync, statSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const apkPath = resolve(root, 'web_download/voltify.apk');
const outPath = resolve(root, 'web_download/version.json');

const pubspec = readFileSync(resolve(root, 'pubspec.yaml'), 'utf8');
const match = pubspec.match(/^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$/m);
if (!match) {
  console.error('version introuvable dans pubspec.yaml (format attendu X.Y.Z+B)');
  process.exit(1);
}
const [, version, buildStr] = match;
const build = Number(buildStr);

let size;
try {
  size = statSync(apkPath).size;
} catch {
  console.error(`APK absent : ${apkPath}`);
  console.error("Copiez d'abord l'APK construit dans web_download/voltify.apk.");
  process.exit(1);
}

// Notes de version affichées dans l'app. À réécrire à chaque livraison :
// c'est la seule chose que le client lit avant d'accepter 23 Mo.
const notes = [
  'Nouveau catalogue : décoration, menuiserie, enseignes',
  'Demande de devis pour le sur-mesure',
  'Recherche par famille de produits',
];

// En dessous de ce build, l'app ne sait plus lire le catalogue en base et
// retomberait sur ses données de démonstration : la mise à jour est imposée.
const minBuild = 2;

const manifest = {
  version,
  build,
  url: 'https://voltify-download-bf.netlify.app/voltify.apk',
  size,
  minBuild,
  notes,
};

writeFileSync(outPath, `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');

console.log(`version.json écrit : ${version}+${build}, ${(size / 1024 / 1024).toFixed(1)} Mo`);
if (build < minBuild) {
  console.warn(
    `ATTENTION : build ${build} < minBuild ${minBuild} — l'app se demanderait ` +
      'à elle-même de se mettre à jour, en boucle.',
  );
  process.exit(1);
}

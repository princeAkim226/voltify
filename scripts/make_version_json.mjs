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

// Puces de la section « ## X.Y.Z » du journal des versions. Refuser de publier
// sans elles vaut mieux que servir au client les nouveautés d'une autre
// version : c'est la seule chose qu'il lit avant d'accepter 23 Mo.
function lireNotes(version) {
  const chemin = resolve(root, 'CHANGELOG.md');
  let journal;
  try {
    journal = readFileSync(chemin, 'utf8');
  } catch {
    console.error(`CHANGELOG.md introuvable : ${chemin}`);
    process.exit(1);
  }

  const lignes = journal.split('\n');
  const debut = lignes.findIndex((ligne) => ligne.trim() === `## ${version}`);
  if (debut === -1) {
    console.error(`Aucune section "## ${version}" dans CHANGELOG.md.`);
    console.error('Ajoutez-la avant de publier.');
    process.exit(1);
  }

  const notes = [];
  for (const ligne of lignes.slice(debut + 1)) {
    const texte = ligne.trim();
    if (texte.startsWith('## ')) break;
    if (texte.startsWith('- ')) notes.push(texte.slice(2).trim());
  }

  if (notes.length === 0) {
    console.error(`La section "## ${version}" de CHANGELOG.md est vide.`);
    process.exit(1);
  }
  return notes;
}

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

// Les notes viennent de CHANGELOG.md, pas d'ici : codées dans ce script, elles
// finissaient par annoncer au client les nouveautés de la version précédente.
const notes = lireNotes(version);

// En dessous de ce build, l'app ne sait plus lire le catalogue en base et
// retomberait sur ses données de démonstration : la mise à jour est imposée.
//
// Le build 3 est le premier à parler à notre propre backend, et le premier à
// lire son manifeste sur dl.raaga-bf.com. Les builds antérieurs interrogeaient
// voltify-download-bf.netlify.app, supprimé le 14/09/2026 : cette valeur ne
// les bloque pas, elle acte qu'ils sont devenus inatteignables — aucun
// manifeste ne leur parviendra plus, quoi qu'on écrive ici.
const minBuild = 3;

// L'APK vit sur GitHub Releases : bande passante gratuite, et un binaire de
// 23 Mo par version n'a rien à faire dans l'historique git. L'URL est taguée
// et non « latest » : un manifeste doit désigner l'APK dont il annonce la
// taille, pas celui qui sera publié demain.
const manifest = {
  version,
  build,
  url: `https://github.com/princeAkim226/voltify/releases/download/v${version}/voltify.apk`,
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

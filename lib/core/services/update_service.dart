import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Une version publiée, décrite par `version.json` à côté de l'APK.
class AppRelease {
  const AppRelease({
    required this.version,
    required this.build,
    required this.url,
    this.size = 0,
    this.minBuild = 0,
    this.notes = const [],
  });

  final String version;
  final int build;
  final String url;

  /// Taille de l'APK en octets. Affichée avant tout téléchargement : au
  /// Burkina, 23 Mo sur des données mobiles, ça se décide, ça ne s'impose pas.
  final int size;

  /// En dessous de ce build, l'app est trop ancienne pour rester utilisable
  /// (catalogue incompatible, par exemple) et la mise à jour est imposée.
  final int minBuild;

  final List<String> notes;

  String get sizeLabel =>
      size <= 0 ? '' : '${(size / 1024 / 1024).toStringAsFixed(1)} Mo';

  factory AppRelease.fromJson(Map<String, dynamic> m) => AppRelease(
        version: m['version'] as String? ?? '',
        build: (m['build'] as num?)?.toInt() ?? 0,
        url: m['url'] as String? ?? '',
        size: (m['size'] as num?)?.toInt() ?? 0,
        minBuild: (m['minBuild'] as num?)?.toInt() ?? 0,
        notes: (m['notes'] as List<dynamic>?)?.cast<String>() ?? const [],
      );
}

/// Vérification et installation des mises à jour hors Play Store.
///
/// Android interdit à une app d'en installer une autre sans accord explicite :
/// on ne peut donc pas mettre à jour en silence. Ce qu'on fait à la place —
/// détecter, télécharger, ouvrir l'installateur — réduit la manœuvre à un seul
/// appui, sans passer par le navigateur ni chercher le fichier.
class UpdateService {
  UpdateService._();

  /// Gravée dans chaque APK installé : la déplacer coupe définitivement les
  /// mises à jour des versions déjà chez les clients, sans recours. Elle vit
  /// donc sur notre domaine, que nous pouvons rediriger, et jamais sur celui
  /// d'un hébergeur ou sur une IP.
  ///
  /// Le manifeste désigne l'APK par une URL absolue : celui-ci peut déménager
  /// librement, les installations suivront.
  static const manifestUrl = 'https://dl.raaga-bf.com/version.json';

  /// Version installée, telle que le système la connaît.
  static Future<int> currentBuild() async {
    final info = await PackageInfo.fromPlatform();
    return int.tryParse(info.buildNumber) ?? 0;
  }

  static Future<String> currentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// Renvoie la version publiée, ou null si l'app est déjà à jour.
  ///
  /// Ne lève jamais : un réseau coupé ne doit pas empêcher d'ouvrir la
  /// boutique.
  static Future<AppRelease?> checkForUpdate() async {
    if (!Platform.isAndroid) return null;
    try {
      final res = await http
          .get(Uri.parse('$manifestUrl?t=${DateTime.now().millisecondsSinceEpoch}'))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;
      final release = AppRelease.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>,
      );
      if (release.url.isEmpty) return null;
      final current = await currentBuild();
      return release.build > current ? release : null;
    } catch (e) {
      debugPrint('Vérification de mise à jour impossible : $e');
      return null;
    }
  }

  /// L'app installée est-elle trop ancienne pour continuer ?
  static Future<bool> isBlocking(AppRelease release) async {
    final current = await currentBuild();
    return current < release.minBuild;
  }

  /// Télécharge l'APK puis ouvre l'installateur du système.
  ///
  /// [onProgress] reçoit une valeur entre 0 et 1, ou null tant que la taille
  /// annoncée par le serveur est inconnue.
  static Future<void> downloadAndInstall(
    AppRelease release, {
    void Function(double? progress)? onProgress,
  }) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(release.url));
      final response = await client.send(request);
      if (response.statusCode != 200) {
        throw Exception('Téléchargement refusé (${response.statusCode})');
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/voltify-${release.build}.apk');
      final sink = file.openWrite();
      final total = response.contentLength ?? release.size;
      var received = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(total > 0 ? received / total : null);
      }
      await sink.flush();
      await sink.close();

      // Un fichier tronqué produirait un « paquet non valide » incompréhensible
      // pour le client : mieux vaut échouer ici, avec un message clair.
      if (total > 0 && received < total) {
        await file.delete();
        throw Exception('Téléchargement interrompu');
      }

      final result = await OpenFilex.open(
        file.path,
        type: 'application/vnd.android.package-archive',
      );
      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } finally {
      client.close();
    }
  }
}

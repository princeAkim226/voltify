import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:voltify/core/services/update_service.dart';

void main() {
  group('Manifeste de version', () {
    test('lit un version.json complet', () {
      final r = AppRelease.fromJson(
        jsonDecode('''
        {
          "version": "1.4.0",
          "build": 3,
          "url": "https://exemple.test/voltify.apk",
          "size": 23634763,
          "minBuild": 2,
          "notes": ["Une nouveauté"]
        }
        ''') as Map<String, dynamic>,
      );

      expect(r.version, '1.4.0');
      expect(r.build, 3);
      expect(r.minBuild, 2);
      expect(r.notes.single, 'Une nouveauté');
      expect(r.sizeLabel, '22.5 Mo');
    });

    test('survit à un manifeste incomplet', () {
      // Un champ oublié ne doit pas planter l'app au démarrage.
      final r = AppRelease.fromJson(
        jsonDecode('{"version": "1.4.0"}') as Map<String, dynamic>,
      );

      expect(r.build, 0);
      expect(r.url, isEmpty);
      expect(r.minBuild, 0);
      expect(r.notes, isEmpty);
      expect(r.sizeLabel, isEmpty, reason: 'sans taille connue, on n\'affiche rien');
    });

    test('n\'annonce pas une taille inconnue', () {
      const r = AppRelease(version: '1.4.0', build: 3, url: 'x');
      expect(r.sizeLabel, isEmpty);
    });

    test('affiche la taille en mégaoctets', () {
      const r = AppRelease(
        version: '1.4.0',
        build: 3,
        url: 'x',
        size: 5 * 1024 * 1024,
      );
      expect(r.sizeLabel, '5.0 Mo');
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/repositories/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    await SupabaseService.initialize();
  } catch (_) {
    // L'app fonctionne en mode mock si Supabase est indisponible.
  }
  runApp(const VoltifyApp());
}

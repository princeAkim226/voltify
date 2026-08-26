import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/app_state.dart';
import 'features/onboarding/splash_screen.dart';

class VoltifyApp extends StatelessWidget {
  const VoltifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LoyaltyProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutDraft()),
      ],
      child: MaterialApp(
        title: 'Voltify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
        builder: (context, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

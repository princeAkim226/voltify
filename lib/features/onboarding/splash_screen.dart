import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shell/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.86, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1730), AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.bolt_rounded, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Voltify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Électronique · Burkina Faso',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

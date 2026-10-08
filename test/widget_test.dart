import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltify/app.dart';

void main() {
  testWidgets('Lumi-Dec démarre sur le splash', (tester) async {
    await tester.pumpWidget(const VoltifyApp());
    expect(find.text('Lumi-Dec'), findsOneWidget);

    // Le splash arme un Future.delayed qui bascule sur le shell.
    // On démonte l'arbre avant l'échéance : le callback se retire sur son
    // garde `mounted`, sans exiger un Supabase initialisé, et le test ne se
    // termine plus avec un timer en vol.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}

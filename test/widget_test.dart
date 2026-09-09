import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltify/app.dart';

void main() {
  testWidgets('Voltify démarre sur le splash', (tester) async {
    await tester.pumpWidget(const VoltifyApp());
    expect(find.text('Voltify'), findsOneWidget);

    // Le splash arme un Future.delayed de 1,6 s qui bascule sur le shell.
    // On démonte l'arbre avant l'échéance : le callback se retire sur son
    // garde `mounted`, sans exiger un Supabase initialisé, et le test ne se
    // termine plus avec un timer en vol.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:voltify/app.dart';

void main() {
  testWidgets('Voltify démarre sur le splash', (tester) async {
    await tester.pumpWidget(const VoltifyApp());
    expect(find.text('Voltify'), findsOneWidget);
  });
}

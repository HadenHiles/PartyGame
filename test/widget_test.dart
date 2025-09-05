// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/main.dart';

void main() {
  testWidgets('App boots and shows Join screen', (tester) async {
    await tester.pumpWidget(const PartyGameApp());

    // Expect the Join screen app bar/title text to be present
    expect(find.text('Join Game'), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/main.dart';

void main() {
  testWidgets('App boots and shows entry selection screen', (tester) async {
    await tester.pumpWidget(const PartyGameApp());

    // New AppBar title
    expect(find.text('PartyGames 🎉'), findsOneWidget);
    // Selection prompt present
    expect(find.text('How do you want to start?'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/screens/player/r1_fill_screen.dart';

void main() {
  testWidgets('R1FillScreen validates and shows not signed in', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: R1FillScreen(code: 'ABCDE', baseSentenceId: 'B1', textTemplate: 'I like {blank} with {blank}'),
      ),
    );

    // Inputs exist
    expect(find.widgetWithText(TextField, 'Fill 1'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Fill 2'), findsOneWidget);

    // Try submit without auth
    await tester.enterText(find.widgetWithText(TextField, 'Fill 1'), 'pizza');
    await tester.enterText(find.widgetWithText(TextField, 'Fill 2'), 'friends');
    await tester.tap(find.text('SUBMIT FILL'));
    await tester.pump();
    expect(find.textContaining('Not signed in'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/screens/player/r1_author_screen.dart';

void main() {
  testWidgets('R1AuthorScreen has inputs and submit', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: R1AuthorScreen(code: 'ABCDE')));

    expect(find.text('Round 1 – Author ✍️'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Sentence 1 e.g. I love {blank} on {blank} nights'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Sentence 2 e.g. My {blank} can outdance your {blank}'), findsOneWidget);
    expect(find.text('SUBMIT SENTENCES'), findsOneWidget);

    await tester.tap(find.text('SUBMIT SENTENCES'));
    await tester.pump();
    expect(find.text('Sentences submitted!'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/screens/host/host_round_screen.dart';

void main() {
  testWidgets('HostRoundScreen renders core widgets', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HostRoundScreen(code: 'ABCDE')));

    expect(find.text('Round 1 – Author ✍️'), findsOneWidget);
    expect(find.textContaining('Room: ABCDE'), findsOneWidget);
    expect(find.text('ADVANCE PHASE'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/services/r1_service.dart';

void main() {
  test('buildFilledText replaces blanks left-to-right', () {
    final svc = R1Service();
    expect(svc.buildFilledText('Hello {blank}!', ['World']), 'Hello World!');
    expect(svc.buildFilledText('A {blank} B {blank} C', ['X', 'Y']), 'A X B Y C');
    // Missing value becomes empty string, preserving structure
    expect(svc.buildFilledText('Only {blank} here', []), 'Only  here');
  });
}

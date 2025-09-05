import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/services/r1_service.dart';

void main() {
  group('R1Service validation', () {
    final svc = R1Service();

    test('valid when 1 blank', () {
      expect(svc.isTemplateValid('I love {blank} nights'), isTrue);
    });

    test('valid when 2 blanks', () {
      expect(svc.isTemplateValid('I love {blank} on {blank} nights'), isTrue);
    });

    test('invalid when 0 blanks', () {
      expect(svc.isTemplateValid('No blanks here'), isFalse);
    });

    test('invalid when 3 blanks', () {
      expect(svc.isTemplateValid('{blank} {blank} {blank}!'), isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/services/r1_service.dart';

void main() {
  test('computeFillAssignments pairs players to same sentence and avoids self-author', () {
    final svc = R1Service();
    final players = ['A', 'B', 'C', 'D'];
    final sentences = ['S1', 'S2'];
    final authors = {'S1': 'X', 'S2': 'Y'}; // none authored by players

    final asn = svc.computeFillAssignments(playerUids: players, sentenceAuthors: authors, sentenceIds: sentences);

    // Each player assigned
    expect(asn.keys.toSet(), players.toSet());

    // Pairs should share same sentence within pairs (A with B, C with D) because of ordering
    expect(asn['A'], asn['B']);
    expect(asn['C'], asn['D']);
  });

  test('avoids assigning a player their own authored sentence', () {
    final svc = R1Service();
    final players = ['A', 'B'];
    final sentences = ['S1', 'S2'];
    final authors = {'S1': 'A', 'S2': 'B'};

    final asn = svc.computeFillAssignments(playerUids: players, sentenceAuthors: authors, sentenceIds: sentences);

    // With two sentences authored by each, algorithm will still pick a sentence and may wrap;
    // ensure neither gets their own authored one if possible given options.
    expect(asn['A'], isNot(equals('S1')));
    expect(asn['B'], isNot(equals('S2')));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/models/player.dart';
import 'package:partygames/models/room.dart';

void main() {
  group('Model serialization', () {
    test('Player toMap/fromMap', () {
      final p = Player(uid: 'u1', displayName: 'Alice', isHost: true, score: 10);
      final m = p.toMap();
      final back = Player.fromMap(m, 'u1');
      expect(back.uid, 'u1');
      expect(back.displayName, 'Alice');
      expect(back.isHost, true);
      expect(back.score, 10);
    });

    test('Room toMap/fromMap', () {
      final r = Room(code: 'ABCD', status: 'open', round: 0, phase: 'lobby', maxPlayers: 8);
      final m = r.toMap();
      final back = Room.fromMap(m, 'ABCD');
      expect(back.code, 'ABCD');
      expect(back.status, 'open');
      expect(back.round, 0);
      expect(back.phase, 'lobby');
      expect(back.maxPlayers, 8);
    });
  });
}

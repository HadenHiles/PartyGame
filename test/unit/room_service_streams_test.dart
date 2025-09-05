import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/models/room.dart';
import 'package:partygames/services/room_service.dart';

void main() {
  group('RoomService streams', () {
    test('roomStream emits on create and startGame (memory impl)', () async {
      // Ensure we are using memory impl by default
      final svc = RoomService();

      final code = await svc.createRoom(maxPlayers: 5, hostUid: 'host1', hostDisplayName: 'Host');

      // collect first two distinct states: lobby then author after start
      final states = <Room?>[];
      final StreamSubscription sub = svc.roomStream(code).distinct((a, b) => a?.phase == b?.phase && a?.status == b?.status && a?.round == b?.round).listen(states.add);

      // give stream a tick to emit initial
      await pumpEventQueue();

      expect(states, isNotEmpty);
      expect(states.first?.phase, 'lobby');
      expect(states.first?.status, 'open');
      expect(states.first?.round, 0);

      await svc.startGame(code);

      // allow emission
      await pumpEventQueue();

      // find a state with author/inGame/round1
      final started = states.last;
      expect(started?.phase, 'author');
      expect(started?.status, 'inGame');
      expect(started?.round, 1);

      await sub.cancel();
    });

    test('playersStream emits added players (memory impl)', () async {
      final svc = RoomService();
      final code = await svc.createRoom(maxPlayers: 5);

      final counts = <int>[];
      final StreamSubscription sub = svc.playersStream(code).map((l) => l.length).distinct().listen(counts.add);

      await pumpEventQueue();
      expect(counts.isNotEmpty, true);
      expect(counts.first, 0);

      await svc.joinRoom(code: code, uid: 'u1', displayName: 'P1');
      await pumpEventQueue();
      expect(counts.last, 1);

      await svc.joinRoom(code: code, uid: 'u2', displayName: 'P2');
      await pumpEventQueue();
      expect(counts.last, 2);

      await sub.cancel();
    });
  });
}

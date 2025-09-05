import 'package:flutter_test/flutter_test.dart';
import 'package:partygames/services/room_service.dart';

void main() {
  test('createRoom generates 5-char code and stores room', () async {
    final svc = RoomService();
    final code = await svc.createRoom(maxPlayers: 6);
    expect(code.length, 5);
    final room = await svc.getRoom(code);
    expect(room, isNotNull);
    expect(room!.maxPlayers, 6);
    expect(room.status, 'open');
    expect(room.phase, 'lobby');
  });
}

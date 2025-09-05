import 'dart:math';

import '../models/room.dart';

class RoomService {
  static final RoomService _i = RoomService._();
  RoomService._();
  factory RoomService() => _i;

  // For now, this is in-memory to allow UI wiring before Firebase.
  final Map<String, Room> _rooms = {};

  String createRoom({int maxPlayers = 8}) {
    final code = _generateRoomCode();
    _rooms[code] = Room(code: code, status: 'open', round: 0, phase: 'lobby', maxPlayers: maxPlayers);
    return code;
  }

  Room? getRoom(String code) => _rooms[code];

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return String.fromCharCodes(Iterable.generate(5, (_) => chars.codeUnitAt(rand.nextInt(chars.length))));
  }
}

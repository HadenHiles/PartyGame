import 'dart:math';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';
import '../models/player.dart';

abstract class RoomServiceBase {
  Future<String> createRoom({int maxPlayers = 8, String? hostUid, String? hostDisplayName});
  Future<Room?> getRoom(String code);
  Future<void> joinRoom({required String code, required String uid, required String displayName});
  Stream<List<Player>> playersStream(String code);
  Future<void> startGame(String code);
  Stream<Room?> roomStream(String code);
}

class RoomService implements RoomServiceBase {
  static final RoomService _i = RoomService._(MemoryRoomService());
  RoomServiceBase _impl;
  RoomService._(this._impl);
  factory RoomService() => _i;

  static void use(RoomServiceBase impl) => _i._impl = impl;

  @override
  Future<String> createRoom({int maxPlayers = 8, String? hostUid, String? hostDisplayName}) => _impl.createRoom(maxPlayers: maxPlayers, hostUid: hostUid, hostDisplayName: hostDisplayName);

  @override
  Future<Room?> getRoom(String code) => _impl.getRoom(code);

  @override
  Future<void> joinRoom({required String code, required String uid, required String displayName}) => _impl.joinRoom(code: code, uid: uid, displayName: displayName);

  @override
  Stream<List<Player>> playersStream(String code) => _impl.playersStream(code);

  @override
  Future<void> startGame(String code) => _impl.startGame(code);

  @override
  Stream<Room?> roomStream(String code) => _impl.roomStream(code);
}

class MemoryRoomService implements RoomServiceBase {
  final Map<String, Room> _rooms = {};
  final Map<String, List<Player>> _players = {};
  final Map<String, StreamController<List<Player>>> _playerControllers = {};
  final Map<String, StreamController<Room?>> _roomControllers = {};

  @override
  Future<String> createRoom({int maxPlayers = 8, String? hostUid, String? hostDisplayName}) async {
    final code = _generateRoomCode();
    _rooms[code] = Room(code: code, hostUid: hostUid, status: 'open', round: 0, phase: 'lobby', maxPlayers: maxPlayers);
    final list = _players[code] = <Player>[];
    if (hostUid != null) {
      list.add(Player(uid: hostUid, displayName: hostDisplayName ?? 'Host', isHost: true));
    }
    _playerControllers[code] = StreamController<List<Player>>.broadcast();
    _playerControllers[code]!.add(List<Player>.unmodifiable(list));
    _roomControllers[code] = StreamController<Room?>.broadcast();
    _roomControllers[code]!.add(_rooms[code]);
    return code;
  }

  @override
  Future<Room?> getRoom(String code) async => _rooms[code];

  @override
  Future<void> joinRoom({required String code, required String uid, required String displayName}) async {
    _rooms.putIfAbsent(code, () => Room(code: code, status: 'open', round: 0, phase: 'lobby', maxPlayers: 8));
    final list = _players.putIfAbsent(code, () => <Player>[]);
    final existingIndex = list.indexWhere((p) => p.uid == uid);
    if (existingIndex >= 0) {
      list[existingIndex] = list[existingIndex].copyWith(displayName: displayName, isConnected: true);
    } else {
      list.add(Player(uid: uid, displayName: displayName));
    }
    _playerControllers.putIfAbsent(code, () => StreamController<List<Player>>.broadcast());
    _playerControllers[code]!.add(List<Player>.unmodifiable(list));
  }

  @override
  Stream<List<Player>> playersStream(String code) {
    final controller = _playerControllers.putIfAbsent(code, () => StreamController<List<Player>>.broadcast());
    // Emit current snapshot after listeners attach
    final snapshot = List<Player>.unmodifiable(_players[code] ?? const <Player>[]);
    Future.microtask(() => controller.add(snapshot));
    return controller.stream;
  }

  @override
  Future<void> startGame(String code) async {
    final room = _rooms[code];
    if (room == null) return;
    _rooms[code] = room.copyWith(status: 'inGame', round: 1, phase: 'author');
    _roomControllers[code]?.add(_rooms[code]);
  }

  @override
  Stream<Room?> roomStream(String code) {
    final controller = _roomControllers.putIfAbsent(code, () => StreamController<Room?>.broadcast());
    // Emit current snapshot after listeners attach
    final snapshot = _rooms[code];
    Future.microtask(() => controller.add(snapshot));
    return controller.stream;
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return String.fromCharCodes(Iterable.generate(5, (_) => chars.codeUnitAt(rand.nextInt(chars.length))));
  }
}

class FirestoreRoomService implements RoomServiceBase {
  final _db = FirebaseFirestore.instance;

  @override
  Future<String> createRoom({int maxPlayers = 8, String? hostUid, String? hostDisplayName}) async {
    final code = _generateRoomCode();
    final room = Room(code: code, hostUid: hostUid, status: 'open', round: 0, phase: 'lobby', maxPlayers: maxPlayers);
    final roomRef = _db.collection('rooms').doc(code);
    await roomRef.set({...room.toMap(), 'createdAt': FieldValue.serverTimestamp()});
    if (hostUid != null) {
      await roomRef.collection('players').doc(hostUid).set({'displayName': hostDisplayName ?? 'Host', 'joinedAt': FieldValue.serverTimestamp(), 'isHost': true, 'isConnected': true, 'score': 0}, SetOptions(merge: true));
    }
    return code;
  }

  @override
  Future<Room?> getRoom(String code) async {
    final snap = await _db.collection('rooms').doc(code).get();
    if (!snap.exists) return null;
    return Room.fromMap(snap.data() ?? {}, code);
  }

  @override
  Future<void> joinRoom({required String code, required String uid, required String displayName}) async {
    final roomRef = _db.collection('rooms').doc(code);
    final roomSnap = await roomRef.get();
    if (!roomSnap.exists) {
      throw StateError('Room not found');
    }
    await roomRef.collection('players').doc(uid).set({'displayName': displayName, 'joinedAt': FieldValue.serverTimestamp(), 'isHost': false, 'isConnected': true, 'score': 0}, SetOptions(merge: true));
  }

  @override
  Stream<List<Player>> playersStream(String code) {
    final roomRef = _db.collection('rooms').doc(code);
    return roomRef.collection('players').orderBy('joinedAt', descending: false).snapshots().map((qs) => qs.docs.map((d) => Player.fromMap(d.data(), d.id)).toList(growable: false));
  }

  @override
  Future<void> startGame(String code) async {
    final roomRef = _db.collection('rooms').doc(code);
    await roomRef.set({'status': 'inGame', 'round': 1, 'phase': 'author', 'phaseStartAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  @override
  Stream<Room?> roomStream(String code) {
    return _db.collection('rooms').doc(code).snapshots().map((snap) {
      if (!snap.exists) return null;
      return Room.fromMap(snap.data() ?? {}, code);
    });
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return String.fromCharCodes(Iterable.generate(5, (_) => chars.codeUnitAt(rand.nextInt(chars.length))));
  }
}

class Room {
  final String code;
  final String? hostUid;
  final String status; // open | inGame | ended
  final int round; // 0 | 1 | 2 | 3
  final String phase; // lobby | author | fill | vote | tally | leaderboard
  final DateTime? phaseStartAt;
  final DateTime? phaseEndsAt;
  final int maxPlayers;

  const Room({required this.code, this.hostUid, required this.status, required this.round, required this.phase, this.phaseStartAt, this.phaseEndsAt, required this.maxPlayers});

  Room copyWith({String? code, String? hostUid, String? status, int? round, String? phase, DateTime? phaseStartAt, DateTime? phaseEndsAt, int? maxPlayers}) {
    return Room(code: code ?? this.code, hostUid: hostUid ?? this.hostUid, status: status ?? this.status, round: round ?? this.round, phase: phase ?? this.phase, phaseStartAt: phaseStartAt ?? this.phaseStartAt, phaseEndsAt: phaseEndsAt ?? this.phaseEndsAt, maxPlayers: maxPlayers ?? this.maxPlayers);
  }

  factory Room.fromMap(Map<String, dynamic> map, String code) {
    DateTime? tsToDate(dynamic v) => v == null ? null : (v is DateTime ? v : DateTime.tryParse(v.toString()));
    return Room(code: code, hostUid: map['hostUid'] as String?, status: (map['status'] as String?) ?? 'open', round: (map['round'] as num?)?.toInt() ?? 0, phase: (map['phase'] as String?) ?? 'lobby', phaseStartAt: tsToDate(map['phaseStartAt']), phaseEndsAt: tsToDate(map['phaseEndsAt']), maxPlayers: (map['maxPlayers'] as num?)?.toInt() ?? 8);
  }

  Map<String, dynamic> toMap() {
    return {'hostUid': hostUid, 'status': status, 'round': round, 'phase': phase, 'phaseStartAt': phaseStartAt?.toIso8601String(), 'phaseEndsAt': phaseEndsAt?.toIso8601String(), 'maxPlayers': maxPlayers};
  }
}

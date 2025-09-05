class Player {
  final String uid;
  final String displayName;
  final String? avatar;
  final bool isHost;
  final bool isConnected;
  final int score;

  const Player({required this.uid, required this.displayName, this.avatar, this.isHost = false, this.isConnected = true, this.score = 0});

  Player copyWith({String? uid, String? displayName, String? avatar, bool? isHost, bool? isConnected, int? score}) {
    return Player(uid: uid ?? this.uid, displayName: displayName ?? this.displayName, avatar: avatar ?? this.avatar, isHost: isHost ?? this.isHost, isConnected: isConnected ?? this.isConnected, score: score ?? this.score);
  }

  factory Player.fromMap(Map<String, dynamic> map, String uid) {
    return Player(uid: uid, displayName: (map['displayName'] as String?) ?? 'Player', avatar: map['avatar'] as String?, isHost: (map['isHost'] as bool?) ?? false, isConnected: (map['isConnected'] as bool?) ?? true, score: (map['score'] as num?)?.toInt() ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {'displayName': displayName, 'avatar': avatar, 'isHost': isHost, 'isConnected': isConnected, 'score': score};
  }
}

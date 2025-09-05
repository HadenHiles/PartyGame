enum GameStatus { open, inGame, ended }

enum GamePhase { lobby, author, fill, vote, tally, leaderboard }

extension GamePhaseX on GamePhase {
  String get name => toString().split('.').last;
  static GamePhase from(String? v) {
    switch (v) {
      case 'author':
        return GamePhase.author;
      case 'fill':
        return GamePhase.fill;
      case 'vote':
        return GamePhase.vote;
      case 'tally':
        return GamePhase.tally;
      case 'leaderboard':
        return GamePhase.leaderboard;
      case 'lobby':
      default:
        return GamePhase.lobby;
    }
  }
}

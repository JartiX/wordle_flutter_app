const defaultNumGuesses = 5;
const defaultWordLength = 8;

enum HitType { none, hit, partial, miss, removed }

enum GameStatus { playing, won, lost }

class Letter {
  String char;
  HitType type;

  Letter({required this.char, this.type = HitType.none});
}

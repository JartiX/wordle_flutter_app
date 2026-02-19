const defaultNumGuesses = 5;
const wordLength = 5;

enum HitType { none, hit, partial, miss, removed }

enum GameStatus { playing, won, lost }

typedef Letter = ({String char, HitType type});

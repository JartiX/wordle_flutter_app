import 'dart:collection';
import 'types.dart';
import 'word.dart';
import '../utils/word_utils.dart';

class GuessResult {
  final Word? word;
  final String? error;

  GuessResult({this.word, this.error});
}

class Game {
  Game({
    this.numAllowedGuesses = defaultNumGuesses,
    this.wordLength = defaultWordLength,
    this.seed,
  }) {
    _wordToGuess = seed == null
        ? Word.random(wordLength)
        : Word.fromSeed(seed!, wordLength);
    _guesses = List.generate(numAllowedGuesses, (_) => Word.empty(wordLength));
  }

  late final int numAllowedGuesses;
  late final int wordLength;
  late List<Word> _guesses;
  late Word _wordToGuess;
  int? seed;

  Word get hiddenWord => _wordToGuess;

  UnmodifiableListView<Word> get guesses => UnmodifiableListView(_guesses);

  Word get previousGuess {
    final index = _guesses.lastIndexWhere((word) => word.isNotEmpty);
    return index == -1 ? Word.empty(wordLength) : _guesses[index];
  }

  int get activeIndex {
    return _guesses.indexWhere((word) => word.isEmpty);
  }

  int get guessesRemaining {
    if (activeIndex == -1) return 0;
    return numAllowedGuesses - activeIndex;
  }

  void resetGame() {
    _wordToGuess = seed == null
        ? Word.random(wordLength)
        : Word.fromSeed(seed!, wordLength);
    _guesses = List.generate(numAllowedGuesses, (_) => Word.empty(wordLength));
  }

  GuessResult guess(String guess) {
    if (guess.length != wordLength) {
      return GuessResult(error: "Слово должно быть ${hiddenWord.length} букв");
    }
    if (!isLegalGuess(guess)) {
      return GuessResult(error: "Слово отсутствует в словаре");
    }

    final result = matchGuessOnly(guess);
    addGuessToList(result);
    return GuessResult(word: result);
  }

  bool get didWin {
    if (_guesses.first.isEmpty) return false;

    for (var letter in previousGuess) {
      if (letter.type != HitType.hit) return false;
    }

    return true;
  }

  bool get didLose => guessesRemaining == 0 && !didWin;

  bool isLegalGuess(String guess) {
    return Word.fromString(guess).isLegalGuess;
  }

  Word matchGuessOnly(String guess) {
    var hiddenCopy = Word.fromString(_wordToGuess.toString());
    return Word.fromString(guess).evaluateGuess(hiddenCopy);
  }

  void addGuessToList(Word guess) {
    final i = _guesses.indexWhere((word) => word.isEmpty);
    _guesses[i] = guess;
  }
}

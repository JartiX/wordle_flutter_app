import 'package:flutter/foundation.dart';
import 'settings_controller.dart';
import 'statistics_controller.dart';
import '../constants/keyboard_layouts.dart';
import '../models/game.dart';
import '../models/word.dart';
import '../models/types.dart';
import '../events/game_events.dart';
import '../repositories/word_repository.dart';

class GameController {
  void init() async {
    await _createGame();

    _settings.attempts.addListener(resetGame);
    _settings.wordLength.addListener(resetGame);
  }

  GameController(this._settings, this._statisticsController);

  final SettingsController _settings;

  SettingsController get settings => _settings;

  final StatisticsController _statisticsController;

  StatisticsController get statisticsController => _statisticsController;

  late Game _game;
  Game get game => _game;

  bool get didWin => _game.didWin;
  bool get didLose => _game.didLose;
  Word get hiddenWord => _game.hiddenWord;

  int get wordLength => _game.wordLength;
  int get numAllowedGuesses => _game.numAllowedGuesses;

  List<List<String>> get currentLayout =>
      KeyboardLayouts.layouts[_settings.language.value]!;

  final ValueNotifier<String> currentGuessNotifier = ValueNotifier("");

  final ValueNotifier<List<Word>?> _reversingGuesses = ValueNotifier(null);

  bool get isResetting => _reversingGuesses.value != null;

  ValueNotifier<List<Word>?> get reversingGuessesNotifier => _reversingGuesses;

  List<Letter?> get hintLetters {
    final length = wordLength;
    List<Letter?> hints = List.filled(length, null);

    for (var word in guessesNotifier.value) {
      for (int i = 0; i < word.length; i++) {
        if (word[i].type == HitType.hit) {
          hints[i] = word[i];
        }
      }
    }
    return hints;
  }

  int get submittedCount {
    final guesses = guessesNotifier.value;
    int count = 0;

    for (var word in guesses) {
      bool hasContent = false;
      for (var letter in word) {
        final String ch = (letter.char);
        final HitType t = (letter.type);

        if (ch.isNotEmpty || t != HitType.none) {
          hasContent = true;
          break;
        }
      }
      if (hasContent) {
        count++;
      }
    }
    return count;
  }

  final ValueNotifier<Map<String, HitType>> keyboardStatuses = ValueNotifier(
    {},
  );

  final ValueNotifier<GameEvent?> gameEvent = ValueNotifier(null);

  final ValueNotifier<List<Word>> guessesNotifier = ValueNotifier<List<Word>>(
    [],
  );

  bool isRightLength(String guess) =>
      guess.length == _settings.wordLength.value;

  GuessResult submitGuess(String guess) {
    final result = _game.guess(guess);
    guessesNotifier.value = List<Word>.from(_game.guesses);

    if (result.error != null) {
      gameEvent.value = GameEvent(
        error: result.error,
        status: GameStatus.playing,
      );
    } else if (_game.didWin) {
      gameEvent.value = GameEvent(status: GameStatus.won);
      _statisticsController.recordGame(won: true, attempts: submittedCount);
    } else if (_game.didLose) {
      gameEvent.value = GameEvent(status: GameStatus.lost);
      _statisticsController.recordGame(won: false);
    }

    return result;
  }

  GuessResult submitCurrentGuess() {
    final guess = currentGuessNotifier.value;
    final result = submitGuess(guess);
    if (result.error == null) {
      _updateKeyboardStatuses(_game.previousGuess);
      currentGuessNotifier.value = "";
    }
    return result;
  }

  void _updateKeyboardStatuses(Word guess) {
    final current = Map<String, HitType>.from(keyboardStatuses.value);

    for (var letter in guess) {
      final char = letter.char.toUpperCase();
      final oldStatus = current[char];

      if (oldStatus == HitType.hit) continue;

      if (letter.type == HitType.hit) {
        current[char] = HitType.hit;
      } else if (letter.type == HitType.partial && oldStatus != HitType.hit) {
        current[char] = HitType.partial;
      } else if (letter.type == HitType.miss && oldStatus == null) {
        current[char] = HitType.miss;
      }
    }
    keyboardStatuses.value = current;
  }

  void addLetter(String char) {
    if (isResetting) return;
    if (currentGuessNotifier.value.length < wordLength && !didWin && !didLose) {
      currentGuessNotifier.value += char.toLowerCase();
    }
  }

  void removeLetter() {
    if (isResetting) return;
    if (currentGuessNotifier.value.isNotEmpty) {
      currentGuessNotifier.value = currentGuessNotifier.value.substring(
        0,
        currentGuessNotifier.value.length - 1,
      );
    }
  }

  Future<void> _createGame() async {
    final len = _settings.wordLength.value;
    await WordRepository(len).load();

    _game = Game(numAllowedGuesses: _settings.attempts.value, wordLength: len);
  }

  void _reset() {
    keyboardStatuses.value = {};
    currentGuessNotifier.value = "";
    guessesNotifier.value = List<Word>.from(_game.guesses);
  }

  Future<void> resetGame() async {
    if (!_game.didWin && !_game.didLose && submittedCount != 0) {
      _statisticsController.recordGame(won: false);
    }

    final oldSubmittedCount = submittedCount;
    final oldGuesses = List<Word>.from(guessesNotifier.value);

    await _createGame();

    if (oldSubmittedCount > 0) {
      _reversingGuesses.value = oldGuesses;
      _reset();

      final maxDelay = (wordLength - 1) * 150 + 500 + 50;
      await Future.delayed(Duration(milliseconds: maxDelay));

      _reversingGuesses.value = null;
    } else {
      _reset();
    }
  }
}

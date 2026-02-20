import 'package:flutter/foundation.dart';
import 'settings_controller.dart';
import 'statistics_controller.dart';
import '../models/game.dart';
import '../models/word.dart';
import '../models/types.dart';
import '../events/game_events.dart';
import '../repositories/word_repository.dart';

class GameController {
  final SettingsController _settings;

  SettingsController get settings => _settings;

  final StatisticsController _statisticsController;

  StatisticsController get statisticsController => _statisticsController;

  late Game _game;
  bool _isReady = false;
  bool get isReady => _isReady;
  Game get game => _game;

  bool get didWin => _game.didWin;
  bool get didLose => _game.didLose;
  Word get hiddenWord => _game.hiddenWord;
  int get activeIndex => _game.activeIndex;

  int get wordLength => _game.wordLength;
  int get numAllowedGuesses => _game.numAllowedGuesses;

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

  bool isRightLength(String guess) =>
      guess.length == _settings.wordLength.value;

  final ValueNotifier<List<Word>> guessesNotifier = ValueNotifier<List<Word>>(
    [],
  );

  void init() async {
    await _createGame(); // Ждем создания первой игры

    _settings.attempts.addListener(_createGame);
    _settings.wordLength.addListener(_createGame);
  }

  GameController(this._settings, this._statisticsController);

  final ValueNotifier<GameEvent?> gameEvent = ValueNotifier(null);

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
      _statisticsController.recordGame(
        won: true,
        attempts: _game.numAllowedGuesses,
      );
    } else if (_game.didLose) {
      gameEvent.value = GameEvent(status: GameStatus.lost);
      _statisticsController.recordGame(won: false);
    }

    return result;
  }

  Future<void> _createGame() async {
    final len = _settings.wordLength.value;
    await WordRepository(len).load();

    _game = Game(numAllowedGuesses: _settings.attempts.value, wordLength: len);
    guessesNotifier.value = List<Word>.from(_game.guesses);
    _isReady = true;
  }

  void resetGame() {
    _createGame();
  }
}

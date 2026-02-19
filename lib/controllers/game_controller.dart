import 'package:flutter/foundation.dart';
import 'settings_controller.dart';
import 'statistics_controller.dart';
import '../models/game.dart';
import '../models/word.dart';
import '../models/types.dart';
import '../events/game_events.dart';

class GameController {
  final SettingsController _settings;

  SettingsController get settings => _settings;

  final StatisticsController _statisticsController;

  StatisticsController get statisticsController => _statisticsController;

  late Game _game;

  Game get game => _game;

  bool get didWin => _game.didWin;
  bool get didLose => _game.didLose;
  Word get hiddenWord => _game.hiddenWord;

  bool isRightLength(String guess) => guess.length == wordLength;

  final ValueNotifier<List<Word>> guessesNotifier = ValueNotifier<List<Word>>(
    [],
  );

  void init() {
    _createGame();

    _settings.attempts.addListener(() {
      _createGame();
    });
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
      _statisticsController.recordGame(won: true, attempts: _game.numAllowedGuesses);
    } else if (_game.didLose) {
      gameEvent.value = GameEvent(status: GameStatus.lost);
      _statisticsController.recordGame(won: false);
    }

    return result;
  }

  void _createGame() {
    _game = Game(numAllowedGuesses: _settings.attempts.value);
    guessesNotifier.value = List<Word>.from(_game.guesses);
  }

  void resetGame() {
    _createGame();
  }
}

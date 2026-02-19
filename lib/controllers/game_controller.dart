import 'package:flutter/foundation.dart';
import 'settings_controller.dart';
import '../models/game.dart';
import '../models/word.dart';
import '../models/types.dart';
import '../events/game_events.dart';

class GameController {
  final SettingsController _settings;

  SettingsController get settings => _settings;

  late Game _game;

  Game get game => _game;

  bool get didWin => _game.didWin;
  bool get didLose => _game.didLose;
  Word get hiddenWord => _game.hiddenWord;

  final ValueNotifier<List<Word>> guessesNotifier = ValueNotifier<List<Word>>(
    [],
  );

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
    } else if (_game.didLose) {
      gameEvent.value = GameEvent(status: GameStatus.lost);
    }

    return result;
  }

  GameController(this._settings);

  void init() {
    _createGame();

    _settings.attempts.addListener(() {
      _createGame();
    });
  }

  void _createGame() {
    _game = Game(numAllowedGuesses: _settings.attempts.value);
    guessesNotifier.value = List<Word>.from(_game.guesses);
  }

  void resetGame() {
    _createGame();
  }
}

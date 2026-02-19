import 'package:flutter/foundation.dart';
import 'settings_controller.dart';
import '../models/game.dart';
import '../models/word.dart';

class GameController {
  final SettingsController _settings;

  SettingsController get settings => _settings;

  late Game _game;
  
  Game get game => _game;

  bool get didWin => _game.didWin;
  bool get didLose => _game.didLose;
  Word get hiddenWord => _game.hiddenWord;

  final ValueNotifier<List<Word>> guessesNotifier = ValueNotifier<List<Word>>([]);
  

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

  GuessResult submitGuess(String guess) {
    final result = _game.guess(guess);
    guessesNotifier.value = List<Word>.from(_game.guesses);
    return result;
  }

  void resetGame() {
    _createGame();
  }
}

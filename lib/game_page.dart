import 'package:flutter/material.dart';
import 'models/game.dart';
import 'models/types.dart';
import 'widgets/game_over_dialog.dart';
import 'widgets/guess_input.dart';
import 'widgets/tile.dart';
import 'widgets/top_toast.dart';
import 'controllers/audio_controller.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.audioController});

  final AudioController audioController;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  final Game _game = Game(numAllowedGuesses: 6);

  String? _errorMessage;
  bool _showError = false;

  void _showTopError(String message) {
    setState(() {
      _errorMessage = message;
      _showError = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showError = false;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    widget.audioController.load().then((_) {
      setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      await widget.audioController.pauseBackground();
    } else if (state == AppLifecycleState.resumed) {
      await widget.audioController.resumeBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCirc,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8.0),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: theme.cardColor.withValues(
                    alpha: 0.9,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: .3)
                          : Colors.deepPurple.withValues(alpha: .15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      spacing: 5.0,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var guess in _game.guesses)
                          Row(
                            spacing: 5.0,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < guess.length; i++)
                                FutureBuilder(
                                  future: Future.delayed(
                                    Duration(milliseconds: 120 * i),
                                    () {
                                      return Tile(guess[i].char, guess[i].type);
                                    },
                                  ),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData)
                                      return Tile(guess[i].char, HitType.none);
                                    return snapshot.data!;
                                  },
                                ),
                            ],
                          ),
                      ],
                    ),
                    GuessInput(
                      audioController: widget.audioController,
                      onRestart: () => setState(() {
                        _game.resetGame();
                      }),
                      onSubmitGuess: (String guess) {
                        final result = _game.guess(guess);
                        if (result.error != null) {
                          _showTopError(result.error!);
                          return;
                        }

                        setState(() {});

                        if (_game.didWin || _game.didLose) {
                          if (_game.didWin) {
                            widget.audioController.playWin();
                          } else {
                            widget.audioController.playLose();
                          }

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => GameOverDialog(
                              audioController: widget.audioController,
                              didWin: _game.didWin,
                              wordToGuess: _game.hiddenWord,
                              onPlayAgain: () {
                                setState(() {
                                  _game.resetGame();
                                });
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_errorMessage != null)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            top: _showError ? 50 : -100,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _showError ? 1 : 0,
              child: TopToast(message: _errorMessage!),
            ),
          ),
      ],
    );
  }
}

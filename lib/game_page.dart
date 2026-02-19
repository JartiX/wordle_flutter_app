import 'package:flutter/material.dart';
import 'models/types.dart';
import 'widgets/game_over_dialog.dart';
import 'widgets/guess_input.dart';
import 'widgets/tile.dart';
import 'widgets/top_toast.dart';
import 'controllers/audio_controller.dart';
import 'controllers/game_controller.dart';
import 'models/word.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.audioController,
    required this.gameController,
  });

  final AudioController audioController;
  final GameController gameController;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    widget.audioController.load();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final topInset = media.padding.top; // статусбар
    final appBarHeight = kToolbarHeight;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final maxHeight = media.size.height - topInset - appBarHeight - 16;

    final isKeyboardOpen = bottomInset > 0;

    return Stack(
      children: [
        AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCirc,
          padding: EdgeInsets.only(bottom: bottomInset, top: topInset + 8, left: 8, right: 8),
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),

              child: Container(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.cardColor.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: .3)
                          : theme.colorScheme.primary.withValues(alpha: .1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  reverse: isKeyboardOpen,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<List<Word>>(
                        valueListenable: widget.gameController.guessesNotifier,
                        builder: (context, guesses, _) {
                          return Column(
                            spacing: 5.0,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var guess in guesses)
                                Row(
                                  spacing: 5.0,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (int i = 0; i < guess.length; i++)
                                      FutureBuilder(
                                        future: Future.delayed(
                                          Duration(milliseconds: 120 * i),
                                          () {
                                            return Tile(
                                              guess[i].char,
                                              guess[i].type,
                                            );
                                          },
                                        ),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData)
                                            return Tile(
                                              guess[i].char,
                                              HitType.none,
                                            );
                                          return snapshot.data!;
                                        },
                                      ),
                                  ],
                                ),
                            ],
                          );
                        },
                      ),
                      GuessInput(
                        audioController: widget.audioController,
                        onRestart: () {
                          widget.gameController.resetGame();
                        },
                        onSubmitGuess: (String guess) {
                          final result = widget.gameController.submitGuess(
                            guess,
                          );
                          if (result.error != null) {
                            _showTopError(result.error!);
                            return;
                          }

                          if (widget.gameController.didWin ||
                              widget.gameController.didLose) {
                            if (widget.gameController.didWin) {
                              widget.audioController.playWin();
                            } else {
                              widget.audioController.playLose();
                            }

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => GameOverDialog(
                                audioController: widget.audioController,
                                didWin: widget.gameController.didWin,
                                wordToGuess: widget.gameController.hiddenWord,
                                onPlayAgain: () {
                                  widget.gameController.resetGame();
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
        ),
        if (_errorMessage != null)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            top: _showError ? 100 : -80,
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

import 'dart:math';

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

  Widget _buildCell(
    int rowIndex,
    int colIndex,
    List<Word> guesses,
    double tileSize,
  ) {
    if (rowIndex < widget.gameController.activeIndex) {
      final char = guesses[rowIndex][colIndex].char;
      final type = guesses[rowIndex][colIndex].type;

      return FutureBuilder(
        key: ValueKey('row_${rowIndex}_col_$colIndex'),
        future: Future.delayed(
          Duration(milliseconds: 120 * colIndex),
          () => type,
        ),
        builder: (context, snapshot) {
          return Tile(
            snapshot.hasData ? char : '',
            snapshot.hasData ? snapshot.data! : HitType.none,
            size: tileSize,
          );
        },
      );
    }

    if (rowIndex == widget.gameController.activeIndex) {
      final hint = widget.gameController.hintLetters[colIndex];

      if (hint != null) {
        return Tile(hint.char, HitType.none, size: tileSize, needOpacity: true,);
      }
    }

    // 3. ПУСТЫЕ КЛЕТКИ (будущие ходы)
    return Tile('', HitType.none, size: tileSize);
  }

  void _showGameOverDialog(bool didWin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        audioController: widget.audioController,
        didWin: didWin,
        wordToGuess: widget.gameController.hiddenWord,
        onPlayAgain: () => widget.gameController.resetGame(),
      ),
    );
  }

  @override
  void dispose() {
    widget.gameController.gameEvent.removeListener(_handleGameEvent);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.gameController.gameEvent.addListener(_handleGameEvent);

    widget.audioController.load();
  }

  void _handleGameEvent() {
    final event = widget.gameController.gameEvent.value;
    if (event == null) return;

    if (event.error != null) {
      _showTopError(event.error!);
    } else if (event.status == GameStatus.won) {
      widget.audioController.playWin();
      _showGameOverDialog(true);
    } else if (event.status == GameStatus.lost) {
      widget.audioController.playLose();
      _showGameOverDialog(false);
    }

    widget.gameController.gameEvent.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final topInset = media.padding.top; // статусбар
    final appBarHeight = kToolbarHeight;
    final theme = Theme.of(context);

    final maxHeight = media.size.height - topInset - appBarHeight - 16;

    final isKeyboardOpen = bottomInset > 0;

    return Stack(
      children: [
        AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCirc,
          padding: EdgeInsets.only(
            bottom: bottomInset,
            top: topInset + 8,
            left: 8,
            right: 8,
          ),
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),

              child: Container(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 4,
                  bottom: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.cardColor.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.onPrimary.withValues(alpha: .1),
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
                          final screenWidth = media.size.width;
                          final screenHeight = maxHeight;
                          const spacing = 5.0;
                          const horizontalPadding = 32.0;
                          const verticalPadding = 16.0;

                          final lettersCount = widget.gameController.wordLength;
                          final rowsCount =
                              widget.gameController.numAllowedGuesses;

                          final availableWidth =
                              screenWidth - horizontalPadding;
                          final tileWidth =
                              (availableWidth - spacing * (lettersCount - 1)) /
                              lettersCount;

                          const guessInputApproxHeight = 120.0;

                          final availableHeight =
                              screenHeight -
                              guessInputApproxHeight -
                              verticalPadding;

                          final tileHeight =
                              (availableHeight - spacing * (rowsCount - 1)) /
                              rowsCount;

                          final tileSize = min(tileWidth, tileHeight);

                          return Column(
                            spacing: 5.0,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (
                                int rowIndex = 0;
                                rowIndex < rowsCount;
                                rowIndex++
                              )
                                Row(
                                  spacing: 5.0,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (
                                      int colIndex = 0;
                                      colIndex < lettersCount;
                                      colIndex++
                                    )
                                      _buildCell(
                                        rowIndex,
                                        colIndex,
                                        guesses,
                                        tileSize,
                                      ),
                                  ],
                                ),
                            ],
                          );
                        },
                      ),
                      GuessInput(
                        audioController: widget.audioController,
                        gameController: widget.gameController,
                        onRestart: () {
                          widget.gameController.resetGame();
                        },
                        onSubmitGuess: (guess) =>
                            widget.gameController.submitGuess(guess),
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

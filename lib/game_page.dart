import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/types.dart';
import 'widgets/game_over_dialog.dart';
import 'widgets/buttons/animated_send_button.dart';
import 'widgets/tile.dart';
import 'widgets/top_toast.dart';
import 'controllers/audio_controller.dart';
import 'controllers/game_controller.dart';
import 'models/word.dart';
import 'constants/keyboard_layouts.dart';
import 'widgets/game_keyboard.dart';
import 'widgets/shake_widget.dart';

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
  final StreamController<void> _shakeController =
      StreamController<void>.broadcast();

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
    final submittedCount = widget.gameController.submittedCount;
    final bool isSubmittedRow = rowIndex < submittedCount;
    final bool isActiveRow =
        rowIndex == submittedCount &&
        !widget.gameController.didWin &&
        !widget.gameController.didLose;

    if (isSubmittedRow) {
      final letter = guesses[rowIndex][colIndex];
      return Tile(
        letter.char,
        letter.type,
        size: tileSize,
        animationDelay: colIndex * 150,
        key: ValueKey("tile-$rowIndex-$colIndex"),
      );
    }

    if (isActiveRow) {
      return ValueListenableBuilder<String>(
        valueListenable: widget.gameController.currentGuessNotifier,
        builder: (context, currentGuess, _) {
          String char = "";
          bool isHint = false;

          if (colIndex < currentGuess.length) {
            char = currentGuess[colIndex];
          } else {
            final hint = widget.gameController.hintLetters[colIndex];
            if (hint != null) {
              char = hint.char;
              isHint = true;
            }
          }

          return Tile(
            char,
            HitType.none,
            size: tileSize,
            needOpacity: isHint,
            key: ValueKey("tile-$rowIndex-$colIndex"),
          );
        },
      );
    }

    return Tile(
      '',
      HitType.none,
      size: tileSize,
      key: ValueKey("tile-$rowIndex-$colIndex"),
    );
  }

  void _handleKeyEvent(String key) {
    if (widget.gameController.didWin || widget.gameController.didLose) return;

    if (key == KeyboardLayouts.enterKey) {
      widget.audioController.playSend();
      widget.gameController.submitCurrentGuess();
    } else if (key == KeyboardLayouts.deleteKey) {
      widget.gameController.removeLetter();
      widget.audioController.playPop();
    } else if (RegExp(r'^[а-яА-Яa-zA-Z]$').hasMatch(key)) {
      widget.gameController.addLetter(key);
      widget.audioController.playPop();
    }
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
    _shakeController.close();
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
      _shakeController.add(null);
      HapticFeedback.heavyImpact();
      widget.audioController.playErrorWord();
    } else if (event.status == GameStatus.won) {
      widget.audioController.playWin();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _showGameOverDialog(true);
      });
    } else if (event.status == GameStatus.lost) {
      widget.audioController.playLose();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _showGameOverDialog(false);
      });
    }

    widget.gameController.gameEvent.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // final theme = Theme.of(context);

    final topPadding = media.padding.top;
    final bottomPadding = media.padding.bottom;

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            _handleKeyEvent(KeyboardLayouts.enterKey);
          } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
            _handleKeyEvent(KeyboardLayouts.deleteKey);
          } else if (event.character != null) {
            _handleKeyEvent(event.character!);
          }
        }
      },
      child: Stack(
        children: [
          Scaffold(
            body: Container(
              height: double.infinity,
              padding: EdgeInsets.only(
                top: topPadding,
                bottom: bottomPadding > 0 ? bottomPadding : 16,
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 12,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ValueListenableBuilder<List<Word>>(
                        valueListenable: widget.gameController.guessesNotifier,
                        builder: (context, guesses, _) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final lettersCount =
                                  widget.gameController.wordLength;
                              final rowsCount =
                                  widget.gameController.numAllowedGuesses;
                              const spacing = 5.0;

                              final tileWidth =
                                  (constraints.maxWidth -
                                      (spacing * (lettersCount - 1))) /
                                  lettersCount;
                              final tileHeight =
                                  (constraints.maxHeight -
                                      (spacing * (rowsCount - 1))) /
                                  rowsCount;
                              final tileSize = min(
                                tileWidth,
                                tileHeight,
                              ).clamp(30.0, 70.0);

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(rowsCount, (rowIndex) {
                                  final bool isActiveRow =
                                      rowIndex ==
                                      widget.gameController.submittedCount;

                                  Widget rowWidget = Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(lettersCount, (
                                      colIndex,
                                    ) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          right: colIndex == lettersCount - 1
                                              ? 0
                                              : spacing,
                                        ),
                                        child: _buildCell(
                                          rowIndex,
                                          colIndex,
                                          guesses,
                                          tileSize,
                                        ),
                                      );
                                    }),
                                  );

                                  if (isActiveRow) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: rowIndex == rowsCount - 1
                                            ? 0
                                            : spacing,
                                      ),
                                      child: ShakeWidget(
                                        trigger: _shakeController.stream,
                                        child: rowWidget,
                                      ),
                                    );
                                  }

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: rowIndex == rowsCount - 1
                                          ? 0
                                          : spacing,
                                    ),
                                    child: rowWidget,
                                  );
                                }),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 4,
                    child: ValueListenableBuilder<String>(
                      valueListenable:
                          widget.gameController.currentGuessNotifier,
                      builder: (context, guess, _) {
                        return ValueListenableBuilder<Map<String, HitType>>(
                          valueListenable:
                              widget.gameController.keyboardStatuses,
                          builder: (context, statuses, _) {
                            return Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                vertical: 5,
                              ),
                              child: GameKeyboard(
                                statuses: statuses,
                                language: widget
                                    .gameController
                                    .settings
                                    .language
                                    .value,
                                onKeyTap: _handleKeyEvent,
                                enterButton: AnimatedSendButton(
                                  isEnabled: widget.gameController
                                      .isRightLength(guess),
                                  onPressed: () =>
                                      _handleKeyEvent(KeyboardLayouts.enterKey),
                                  audioController: widget.audioController,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
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
      ),
    );
  }
}

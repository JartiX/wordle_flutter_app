import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'buttons/animated_send_button.dart';
import 'buttons/animated_restart_button.dart';
import '../controllers/audio_controller.dart';
import '../controllers/game_controller.dart';

class GuessInput extends StatefulWidget {
  const GuessInput({
    super.key,
    required this.onSubmitGuess,
    required this.onRestart,
    required this.audioController,
    required this.gameController,
  });

  final void Function(String) onSubmitGuess;
  final VoidCallback onRestart;
  final AudioController audioController;
  final GameController gameController;

  @override
  State<GuessInput> createState() => _GuessInputState();
}

class _GuessInputState extends State<GuessInput> {
  final TextEditingController _textEditingController = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  bool isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });

    _textEditingController.addListener(() {
      setState(() {
        isSubmitEnabled = widget.gameController.isRightLength(
          _textEditingController.text.trim(),
        );
      });
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFocused = _focusNode.hasFocus;

    final width = MediaQuery.of(context).size.width;
    final scale = (width / 400).clamp(0.75, 1.2);

    final backgroundColor = theme.colorScheme.surfaceBright;
    final boxShadowColor = theme.colorScheme.outline.withValues(alpha: 0.1);
    final gradientFocused = LinearGradient(
      colors: [
        theme.colorScheme.outline.withValues(alpha: 0.5),
        theme.colorScheme.outline.withValues(alpha: 0.8),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 8 * scale,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: 8 * scale,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30 * scale),
          color: backgroundColor.withValues(alpha: .9),
          boxShadow: [
            BoxShadow(
              color: boxShadowColor,
              blurRadius: 12 * scale,
              offset: Offset(0, 6 * scale),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25 * scale),
                  gradient: isFocused ? gradientFocused : null,
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23 * scale),
                    color: backgroundColor,
                  ),
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[\s|0-9]')),
                    ],
                    focusNode: _focusNode,
                    controller: _textEditingController,
                    maxLength: widget.gameController.getWordLength,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4 * scale,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      hintText: "ВВЕДИТЕ СЛОВО",
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black38,
                        fontSize: 14 * scale,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: isSubmitEnabled
                        ? (String input) {
                            widget.audioController.playSend();
                            widget.onSubmitGuess(
                              _textEditingController.text.trim(),
                            );
                            _textEditingController.clear();
                            _focusNode.requestFocus();
                          }
                        : (_) => _focusNode.requestFocus(),
                    textInputAction: isSubmitEnabled
                        ? TextInputAction.send
                        : TextInputAction.none,
                  ),
                ),
              ),
            ),

            SizedBox(width: 10 * scale),

            AnimatedRestartButton(
              audioController: widget.audioController,
              onPressed: () {
                widget.onRestart();
                _textEditingController.clear();
              },
            ),

            SizedBox(width: 8 * scale),

            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSubmitEnabled ? 1.0 : 0.4,
              child: AnimatedSendButton(
                audioController: widget.audioController,
                isEnabled: isSubmitEnabled,
                onPressed: () {
                  widget.audioController.playSend();
                  widget.onSubmitGuess(_textEditingController.text.trim());
                  _textEditingController.clear();
                  _focusNode.requestFocus();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

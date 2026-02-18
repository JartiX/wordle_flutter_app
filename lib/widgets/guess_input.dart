import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'buttons/animated_send_button.dart';
import 'buttons/animated_restart_button.dart';
import '../controllers/audio_controller.dart';

class GuessInput extends StatefulWidget {
  const GuessInput({
    super.key,
    required this.onSubmitGuess,
    required this.onRestart,
    required this.audioController,
  });

  final void Function(String) onSubmitGuess;
  final VoidCallback onRestart;
  final AudioController audioController;

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

    _textEditingController.addListener(() {
      setState(() {
        isSubmitEnabled = _textEditingController.text.trim().length == 5;
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

    final backgroundColor = isDark ? Colors.grey.shade900 : Colors.white;
    final boxShadowColor = isDark
        ? Colors.black.withValues(alpha: .3)
        : Colors.deepPurple.withValues(alpha: .1);
    final gradientFocused = LinearGradient(
      colors: isDark
          ? [Colors.deepPurple.shade700, Colors.deepPurple.shade400]
          : [Colors.deepPurple.shade200, Colors.deepPurple.shade400],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: backgroundColor.withValues(alpha: .9),
          boxShadow: [
            BoxShadow(
              color: boxShadowColor,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: isFocused ? gradientFocused : null,
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23),
                    color: backgroundColor,
                  ),
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[\s|0-9]')),
                    ],
                    focusNode: _focusNode,
                    controller: _textEditingController,
                    maxLength: 5,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      hintText: "ВВЕДИТЕ СЛОВО",
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black38,
                        fontSize: MediaQuery.of(context).size.width < 400 ? 10 : 16,
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
                    autofocus: true,
                    textInputAction: isSubmitEnabled
                        ? TextInputAction.send
                        : TextInputAction.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            AnimatedRestartButton(
              audioController: widget.audioController,
              onPressed: () {
                widget.onRestart();
                _textEditingController.clear();
              },
            ),

            const SizedBox(width: 8),

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

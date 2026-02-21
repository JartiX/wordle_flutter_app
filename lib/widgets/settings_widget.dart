import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../controllers/game_controller.dart';
import '../controllers/audio_controller.dart';
import '../widgets/buttons/animated_restart_button.dart';
import '../widgets/confirmation_dialog.dart';

class SettingsWidget extends StatelessWidget {
  final GameController gameController;
  final AudioController audioController;

  const SettingsWidget({
    super.key,
    required this.gameController,
    required this.audioController,
  });

  @override
  Widget build(BuildContext context) {
    final settings = gameController.settings;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),

              Text('Настройки', style: Theme.of(context).textTheme.titleLarge),

              AnimatedRestartButton(
                audioController: audioController,
                onPressed: () async {
                  audioController.playPop();
                  final confirmed = await showConfirmationDialog(
                    context,
                    "Сбросить настройки",
                    "Настройки будут сброшены до значений по умолчанию.",
                    audioController: audioController,
                  );
                  if (confirmed ?? false) await gameController.settings.reset();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          ValueListenableBuilder(
            valueListenable: settings.attempts,
            builder: (context, attempts, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Попыток:'),
                  Expanded(
                    child: Slider(
                      min: SettingsModel.allowedAttempts[0].toDouble(),
                      max: SettingsModel.allowedAttempts[1].toDouble(),
                      divisions:
                          SettingsModel.allowedAttempts[1] -
                          SettingsModel.allowedAttempts[0],
                      value: settings.attempts.value.toDouble(),
                      onChanged: (v) {
                        settings.setAttempts(v.toInt());
                      },
                    ),
                  ),
                  Text('${settings.attempts.value}'),
                ],
              );
            },
          ),

          ValueListenableBuilder(
            valueListenable: settings.wordLength,
            builder: (context, wordLength, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Длина слов:'),
                  Expanded(
                    child: Slider(
                      min: SettingsModel.allowedWordLength[0].toDouble(),
                      max: SettingsModel.allowedWordLength[1].toDouble(),
                      divisions:
                          SettingsModel.allowedWordLength[1] -
                          SettingsModel.allowedWordLength[0],
                      value: settings.wordLength.value.toDouble(),
                      onChanged: (v) {
                        settings.setWordLength(v.toInt());
                      },
                    ),
                  ),
                  Text('${settings.wordLength.value}'),
                ],
              );
            },
          ),

          Divider(
            height: 8,
            thickness: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: .3),
          ),

          ValueListenableBuilder<bool>(
            valueListenable: settings.sfxEnabled,
            builder: (_, enabled, _) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Звуки'),
                Switch(
                  value: enabled,
                  onChanged: (v) {
                    settings.toggleSfx();
                    audioController.playPop();
                  },
                ),
              ],
            ),
          ),

          Divider(
            height: 8,
            thickness: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: .3),
          ),

          ValueListenableBuilder<bool>(
            valueListenable: settings.musicEnabled,
            builder: (context, enabled, _) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Музыка'),
                Switch(
                  value: enabled,
                  onChanged: (v) {
                    settings.toggleMusic();
                    audioController.playPop();
                  },
                ),
              ],
            ),
          ),

          Divider(
            height: 8,
            thickness: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: .3),
          ),

          ValueListenableBuilder<double>(
            valueListenable: settings.volume,
            builder: (context, volume, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Громкость:'),
                  Slider(
                    min: 0,
                    max: 1,
                    value: settings.volume.value,
                    onChanged: (v) => settings.setVolume(v),
                  ),
                  Text('${(settings.volume.value * 100).toInt()}%'),
                ],
              );
            },
          ),

          Divider(
            height: 8,
            thickness: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: .3),
          ),

          ValueListenableBuilder(
            valueListenable: settings.theme,
            builder: (context, theme, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Тема:'),
                  Row(
                    children: [
                      for (var (option, icon, fill) in [
                        ('light', Icons.light_mode, Colors.amber),
                        ('dark', Icons.dark_mode, Colors.deepPurple.shade600),
                        ('system', Icons.settings, Colors.grey.shade700),
                      ])
                        Container(
                          decoration: BoxDecoration(
                            color: settings.theme.value == option
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: .5)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          child: IconButton(
                            onPressed: () {
                              settings.setTheme(option);
                              audioController.playPop();
                            },
                            icon: Icon(icon, color: fill),
                          ),
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              );
            },
          ),

          Divider(
            height: 8,
            thickness: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: .3),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              audioController.playPop();
            },
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}

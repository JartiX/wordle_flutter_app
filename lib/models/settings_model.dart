import 'types.dart';

class SettingsModel {
  static const List<int> allowedAttempts = [5, 8];
  static const List<int> allowedWordLength = [5, 8];

  final int attempts;
  final bool sfxEnabled;
  final bool musicEnabled;
  final double volume;
  final String theme;
  final int wordLength;
  final GameLanguage language;

  const SettingsModel({
    required this.attempts,
    required this.sfxEnabled,
    required this.musicEnabled,
    required this.volume,
    required this.theme,
    required this.wordLength,
    required this.language,
  });

  factory SettingsModel.defaults() {
    return const SettingsModel(
      attempts: 6,
      sfxEnabled: true,
      musicEnabled: true,
      volume: 0.5,
      theme: 'system',
      wordLength: 5,
      language: GameLanguage.ru,
    );
  }
}

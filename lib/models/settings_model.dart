class SettingsModel {
  static const List<int> allowedAttempts = [5, 8];

  final int attempts;
  final bool sfxEnabled;
  final bool musicEnabled;
  final double volume;
  final String theme;

  const SettingsModel({
    required this.attempts,
    required this.sfxEnabled,
    required this.musicEnabled,
    required this.volume,
    required this.theme,
  });

  factory SettingsModel.defaults() {
    return const SettingsModel(
      attempts: 6,
      sfxEnabled: true,
      musicEnabled: true,
      volume: 1.0,
      theme: 'system',
    );
  }
}

import '../models/settings_model.dart';

class StatisticsModel {
  int gamesPlayed;
  int currentStreak;
  int maxStreak;
  final Map<int, int> winsByAttempts;

  int get gamesWon => winsByAttempts.values.fold(0, (sum, count) => sum + count);

  double get winRate => gamesPlayed == 0 ? 0 : (gamesWon / gamesPlayed) * 100;

  StatisticsModel({
    required this.gamesPlayed,
    required this.currentStreak,
    required this.maxStreak,
    required Map<int, int> winsByAttempts,
  }) : winsByAttempts = Map.from(winsByAttempts);

  factory StatisticsModel.initial() {
    final minAttempts = SettingsModel.allowedAttempts[0];
    final maxAttempts = SettingsModel.allowedAttempts[1];

    return StatisticsModel(
      gamesPlayed: 0,
      currentStreak: 0,
      maxStreak: 0,
      winsByAttempts: { for (int i = minAttempts; i <= maxAttempts; i++) i: 0 },
    );
  }

  void recordGame({required bool won, int? attempts}) {
    gamesPlayed++;

    if (won) {
      currentStreak++;
      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }

      if (attempts != null && winsByAttempts.containsKey(attempts)) {
        winsByAttempts[attempts] = winsByAttempts[attempts]! + 1;
      }
    } else {
      currentStreak = 0;
    }
  }

  void reset() {
    gamesPlayed = 0;
    currentStreak = 0;
    maxStreak = 0;

    winsByAttempts.updateAll((key, value) => 0);
  }

  StatisticsModel copy() => StatisticsModel(
    gamesPlayed: gamesPlayed,
    currentStreak: currentStreak,
    maxStreak: maxStreak,
    winsByAttempts: winsByAttempts,
  );
}

import 'package:shared_preferences/shared_preferences.dart';
import '../models/statistics_model.dart';
import '../constants/pref_keys.dart';

class StatisticsService {
  Future<StatisticsModel> load() async {
    final prefs = await SharedPreferences.getInstance();

    final stats = StatisticsModel.initial();

    stats.gamesPlayed = prefs.getInt(PrefKeys.gamesPlayedKey) ?? 0;
    stats.currentStreak = prefs.getInt(PrefKeys.currentStreakKey) ?? 0;
    stats.maxStreak = prefs.getInt(PrefKeys.maxStreakKey) ?? 0;

    stats.winsByAttempts.updateAll(
      (attempts, value) =>
          prefs.getInt('${PrefKeys.winsByAttemptsKeyPrefix}$attempts') ?? 0,
    );

    return stats;
  }

  Future<void> save(StatisticsModel stats) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(PrefKeys.gamesPlayedKey, stats.gamesPlayed);
    await prefs.setInt(PrefKeys.currentStreakKey, stats.currentStreak);
    await prefs.setInt(PrefKeys.maxStreakKey, stats.maxStreak);

    for (var entry in stats.winsByAttempts.entries) {
      await prefs.setInt(
        '${PrefKeys.winsByAttemptsKeyPrefix}${entry.key}',
        entry.value,
      );
    }
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';
import '../constants/pref_keys.dart';

class SettingsService {
  Future<SettingsModel> load() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(PrefKeys.numberOfAttempts) ||
        !prefs.containsKey(PrefKeys.sfxEnabled) ||
        !prefs.containsKey(PrefKeys.musicEnabled) ||
        !prefs.containsKey(PrefKeys.volume) ||
        !prefs.containsKey(PrefKeys.theme)) {
      return SettingsModel.defaults();
    }

    return SettingsModel(
      attempts: prefs.getInt(PrefKeys.numberOfAttempts)!,
      sfxEnabled: prefs.getBool(PrefKeys.sfxEnabled)!,
      musicEnabled: prefs.getBool(PrefKeys.musicEnabled)!,
      volume: prefs.getDouble(PrefKeys.volume)!,
      theme: prefs.getString(PrefKeys.theme)!,
    );
  }

  Future<void> save(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(PrefKeys.numberOfAttempts, settings.attempts);
    await prefs.setBool(PrefKeys.sfxEnabled, settings.sfxEnabled);
    await prefs.setBool(PrefKeys.musicEnabled, settings.musicEnabled);
    await prefs.setDouble(PrefKeys.volume, settings.volume);
    await prefs.setString(PrefKeys.theme, settings.theme);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordle_flutter/models/types.dart';
import '../models/settings_model.dart';
import '../constants/pref_keys.dart';

class SettingsService {
  Future<SettingsModel> load() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(PrefKeys.numberOfAttempts) ||
        !prefs.containsKey(PrefKeys.sfxEnabled) ||
        !prefs.containsKey(PrefKeys.musicEnabled) ||
        !prefs.containsKey(PrefKeys.volume) ||
        !prefs.containsKey(PrefKeys.theme) ||
        !prefs.containsKey(PrefKeys.wordLength) ||
        !prefs.containsKey(PrefKeys.language)) {
      return SettingsModel.defaults();
    }

    return SettingsModel(
      attempts: prefs.getInt(PrefKeys.numberOfAttempts)!,
      sfxEnabled: prefs.getBool(PrefKeys.sfxEnabled)!,
      musicEnabled: prefs.getBool(PrefKeys.musicEnabled)!,
      volume: prefs.getDouble(PrefKeys.volume)!,
      theme: prefs.getString(PrefKeys.theme)!,
      wordLength: prefs.getInt(PrefKeys.wordLength)!,
      language: GameLanguage.fromJson(prefs.getString(PrefKeys.language)!),
    );
  }

  Future<void> save(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(PrefKeys.numberOfAttempts, settings.attempts);
    await prefs.setBool(PrefKeys.sfxEnabled, settings.sfxEnabled);
    await prefs.setBool(PrefKeys.musicEnabled, settings.musicEnabled);
    await prefs.setDouble(PrefKeys.volume, settings.volume);
    await prefs.setString(PrefKeys.theme, settings.theme);
    await prefs.setInt(PrefKeys.wordLength, settings.wordLength);
    await prefs.setString(PrefKeys.language, settings.language.toJson());
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesController {
  static final SharedPreferencesController _instance =
      SharedPreferencesController._internal();

  factory SharedPreferencesController() => _instance;

  SharedPreferencesController._internal();

  Future<void> setAudioMuted(bool muted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audioMuted', muted);
  }

  Future<bool> getAudioMuted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('audioMuted') ?? true;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

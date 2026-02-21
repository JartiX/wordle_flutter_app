import 'package:flutter/material.dart';
import '../models/types.dart';
import '../services/settings_service.dart';
import '../models/settings_model.dart';

class SettingsController {
  final SettingsService _service;

  late SettingsModel _settings;

  late final ValueNotifier<int> attempts = ValueNotifier<int>(
    SettingsModel.defaults().attempts,
  );
  late final ValueNotifier<bool> sfxEnabled = ValueNotifier<bool>(
    SettingsModel.defaults().sfxEnabled,
  );
  late final ValueNotifier<bool> musicEnabled = ValueNotifier<bool>(
    SettingsModel.defaults().musicEnabled,
  );
  late final ValueNotifier<double> volume = ValueNotifier<double>(
    SettingsModel.defaults().volume,
  );
  late final ValueNotifier<String> theme = ValueNotifier<String>(
    SettingsModel.defaults().theme,
  );
  late final ValueNotifier<int> wordLength = ValueNotifier<int>(
    SettingsModel.defaults().wordLength,
  );
  late final ValueNotifier<GameLanguage> language = ValueNotifier(
    SettingsModel.defaults().language,
  );

  SettingsController(this._service);

  Future<void> load() async {
    _settings = await _service.load();

    attempts.value = _settings.attempts;
    sfxEnabled.value = _settings.sfxEnabled;
    musicEnabled.value = _settings.musicEnabled;
    volume.value = _settings.volume;
    theme.value = _settings.theme;
    wordLength.value = _settings.wordLength;
    language.value = _settings.language;
  }

  Future<void> _save() async {
    _settings = SettingsModel(
      attempts: attempts.value,
      sfxEnabled: sfxEnabled.value,
      musicEnabled: musicEnabled.value,
      volume: volume.value,
      theme: theme.value,
      wordLength: wordLength.value,
      language: language.value,
    );

    await _service.save(_settings);
  }

  Future<void> setAttempts(int value) async {
    if (value < SettingsModel.allowedAttempts[0] ||
        value > SettingsModel.allowedAttempts[1]) {
      return;
    }

    attempts.value = value;
    await _save();
  }

  Future<void> toggleSfx() async {
    sfxEnabled.value = !sfxEnabled.value;
    await _save();
  }

  Future<void> toggleMusic() async {
    musicEnabled.value = !musicEnabled.value;
    await _save();
  }

  Future<void> setVolume(double value) async {
    volume.value = value;
    await _save();
  }

  Future<void> setTheme(String value) async {
    theme.value = value;
    await _save();
  }

  Future<void> setWordLength(int value) async {
    wordLength.value = value;
    await _save();
  }

  Future<void> setLanguage(GameLanguage value) async {
    language.value = value;
    await _save();
  }

  Future<void> reset() async {
    await _service.reset();
    await load();
  }

  Future<void> dispose() async {
    attempts.dispose();
    sfxEnabled.dispose();
    musicEnabled.dispose();
    volume.dispose();
    theme.dispose();
    wordLength.dispose();
  }
}

import 'dart:ui';

import '../controllers/settings_controller.dart';
import '../services/audio_player_service.dart';

class AudioController {
  final SettingsController _settings;
  final AudioPlayerService _audioService;

  AudioController(this._audioService, this._settings);

  void init() {
    _audioService.init();
    _audioService.setVolume(_settings.volume.value);

    _settings.musicEnabled.addListener(_handleMusicToggle);
    _settings.volume.addListener(_handleVolumeChange);
  }

  void _handleMusicToggle() async{
    if (_settings.musicEnabled.value) {
      await _audioService.setVolume(_settings.volume.value);
      await _audioService.playBackground();
    } else {
      await _audioService.stopBackground();
    }
  }

  void _handleVolumeChange() {
    if (_settings.musicEnabled.value) {
      _audioService.setVolume(_settings.volume.value);
    }
  }

  Future<void> load() async {
    if (_settings.musicEnabled.value) {
      _audioService.playBackground();
    }
  }

  Future<void> playClick() async {
    if (_settings.sfxEnabled.value) {
      await _audioService.playClick();
    }
  }

  Future<void> playPop() async {
    if (_settings.sfxEnabled.value) {
      await _audioService.playPop();
    }
  }
  
  Future<void> playSend() async {
    if (_settings.sfxEnabled.value) {
      await _audioService.playSend();
    }
  }

  Future<void> playWin() async {
    if (_settings.sfxEnabled.value) {
      await _audioService.playWin();
    }
  }

  Future<void> playLose() async {
    if (_settings.sfxEnabled.value) {
      await _audioService.playLose();
    }
  }

  void handleLifecycle(AppLifecycleState state) {
    if (!_settings.musicEnabled.value) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _audioService.pauseBackground();
    }

    if (state == AppLifecycleState.resumed) {
      _audioService.resumeBackground();
    }
  }

  void dispose() {
    _settings.musicEnabled.removeListener(_handleMusicToggle);
    _settings.volume.removeListener(_handleVolumeChange);
  }
}

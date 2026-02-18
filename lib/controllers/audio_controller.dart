import '../services/audio_player_service.dart';
import 'shared_preferences_controller.dart';
import 'package:flutter/foundation.dart';

class AudioController {
  final AudioPlayerService _audioService;
  final SharedPreferencesController _prefsController;

  final ValueNotifier<bool> audioMuted = ValueNotifier(true);

  AudioController(this._audioService, this._prefsController);

  Future<void> load() async {
    audioMuted.value = await _prefsController.getAudioMuted();
    if (!audioMuted.value) {
      await _audioService.playBackground();
    }
  }

  Future<void> toggleAudio() async {
    audioMuted.value = !audioMuted.value;
    await _prefsController.setAudioMuted(audioMuted.value);

    if (audioMuted.value) {
      _audioService.stopBackground();
    } else {
      _audioService.playBackground();
    }
  }

  Future<void> playBackground() async {
    if (!audioMuted.value) {
      await _audioService.playBackground();
    }
  }

  Future<void> pauseBackground() async {
    if (!audioMuted.value) {
      await _audioService.pauseBackground();
    }
  }

  Future<void> resumeBackground() async {
    if (!audioMuted.value) {
      await _audioService.resumeBackground();
      
    }
  }

  Future<void> stopBackground() async {
    if (!audioMuted.value) {
      await _audioService.stopBackground();
    }
  }

  Future<void> playClick() async {
    if (!audioMuted.value) {
      await _audioService.playClick();
    }
  }

  Future<void> playSend() async {
    if (!audioMuted.value) {
      await _audioService.playSend();
    }
  }

  Future<void> playWin() async {
    if (!audioMuted.value) {
      await _audioService.playWin();
    }
  }

  Future<void> playLose() async {
    if (!audioMuted.value) {
      await _audioService.playLose();
    }
  }
}

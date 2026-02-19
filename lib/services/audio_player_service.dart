import 'package:just_audio/just_audio.dart';
import '../constants/assets.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();
  bool _effectPlaying = false;

  AudioPlayerService._internal();

  factory AudioPlayerService() => _instance;

  Future<void> init() async {
    _backgroundPlayer.setLoopMode(LoopMode.one);
    await _backgroundPlayer.setAsset(Assets.backgroundMusic);
  }

  Future<void> playBackground({
    int steps = 5,
    Duration stepDuration = const Duration(milliseconds: 30),
  }) async {
    if (_backgroundPlayer.playing) return;

    try {
      final targetVolume = _backgroundPlayer.volume;
      await _backgroundPlayer.setVolume(0.01);
      _backgroundPlayer.play();

      await Future.delayed(const Duration(milliseconds: 50));

      for (int i = 1; i <= steps; i++) {
        final v = targetVolume * i / steps;
        await _backgroundPlayer.setVolume(v);
        await Future.delayed(stepDuration);
      }

      await _backgroundPlayer.setVolume(targetVolume);
    } catch (_) {}
  }

  Future<void> setVolume(double volume) async {
    await _backgroundPlayer.setVolume(volume);
    await _effectPlayer.setVolume(volume);
  }

  Future<void> pauseBackground() async {
    await _backgroundPlayer.pause();
  }

  Future<void> resumeBackground() async {
    await _backgroundPlayer.play();
  }

  Future<void> stopBackground({
    int steps = 10,
    Duration stepDuration = const Duration(milliseconds: 20),
  }) async {
    final initialVolume = _backgroundPlayer.volume;
    for (int i = steps; i > 0; i--) {
      _backgroundPlayer.setVolume(initialVolume * i / steps);
      await Future.delayed(stepDuration);
    }
    await _backgroundPlayer.stop();
    await _backgroundPlayer.setVolume(
      initialVolume,
    ); // вернуть на следующий запуск
  }

  Future<void> _playEffect(String asset) async {
    try {
      if (_effectPlaying) {
        await _effectPlayer.stop();
      }
      _effectPlaying = true;
      await _effectPlayer.setAsset(asset);

      await _effectPlayer.play();

      _effectPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed ||
            state.processingState == ProcessingState.idle) {
          _effectPlaying = false;
        }
      });
    } catch (_) {
      _effectPlaying = false;
    }
  }

  Future<void> playClick() async => _playEffect(Assets.clickSound);
  Future<void> playSend() async => _playEffect(Assets.sendSound);
  Future<void> playWin() async => _playEffect(Assets.winSound);
  Future<void> playLose() async => _playEffect(Assets.loseSound);
  Future<void> playPop() async => _playEffect(Assets.popSound);

  Future<void> dispose() async {
    await _backgroundPlayer.dispose();
  }
}

import 'package:just_audio/just_audio.dart';
import '../constants/assets.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();

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
  }

  Future<void> setVolume(double volume) async {
    await _backgroundPlayer.setVolume(volume);
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
    final player = AudioPlayer();
    await player.setVolume(_backgroundPlayer.volume);
    await player.setAsset(asset);
    await player.play();

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed ||
          state.processingState == ProcessingState.idle) {
        player.dispose();
      }
    });
  }

  Future<void> playClick() async => _playEffect(Assets.clickSound);
  Future<void> playSend() async => _playEffect(Assets.sendSound);
  Future<void> playWin() async => _playEffect(Assets.winSound);
  Future<void> playLose() async => _playEffect(Assets.loseSound);

  Future<void> dispose() async {
    await _backgroundPlayer.dispose();
  }
}

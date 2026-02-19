import 'package:just_audio/just_audio.dart';
import '../constants/assets.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();

  AudioPlayerService._internal();

  factory AudioPlayerService() => _instance;

  Future<void> playBackground() async {
    if (_backgroundPlayer.playing) return;

    final current = _backgroundPlayer.audioSource;
    if (current == null) {
      await _backgroundPlayer.setAsset(Assets.backgroundMusic);
      _backgroundPlayer.setLoopMode(LoopMode.one);
    }

    await _backgroundPlayer.play();
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

  Future<void> stopBackground() async {
    await _backgroundPlayer.stop();
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

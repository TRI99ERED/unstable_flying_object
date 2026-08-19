import 'dart:async';

import 'package:flame_audio/bgm.dart';
import 'package:flame_audio/flame_audio.dart';

class SoundEffects {
  SoundEffects._() {
    FlameAudio.updatePrefix('assets/sfx/');
  }

  static final SoundEffects instance = SoundEffects._();

  static const double _volume = 0.5;

  final Bgm _musicBgm = Bgm(audioCache: AudioCache(prefix: 'assets/music/'));

  AudioPool? _attachPool;
  AudioPool? _crashPool;
  AudioPlayer? ufoFloatingPlayer;

  final List<Future<void> Function()> _activeStopFunctions = [];

  Future<void> init() async {
    _attachPool = await FlameAudio.createPool('attach.wav', maxPlayers: 4);
    _crashPool = await FlameAudio.createPool('crash.wav', maxPlayers: 4);
    await _musicBgm.initialize();
  }

  void stopGameplayAudio() {
    for (final stopFn in _activeStopFunctions) {
      stopFn();
    }
    _activeStopFunctions.clear();
    stopUfoFloating();
  }

  void playAttach() async {
    final pool = _attachPool;
    if (pool != null) {
      final stopFn = await pool.start(volume: _volume);
      _activeStopFunctions.add(stopFn);
    }
  }

  void playCrash() async {
    final pool = _crashPool;
    if (pool != null) {
      final stopFn = await pool.start(volume: _volume);
      _activeStopFunctions.add(stopFn);
    }
  }

  void playUfoLeave() {
    unawaited(FlameAudio.play('ufo_leave.mp3', volume: _volume));
  }

  Future<void> playUfoFloating() async {
    ufoFloatingPlayer = await FlameAudio.loop(
      'ufo_floating.mp3',
      volume: _volume,
    );
  }

  void stopUfoFloating() {
    unawaited(ufoFloatingPlayer?.stop());
  }

  void playMainTheme() {
    unawaited(_musicBgm.play('main.wav', volume: _volume));
  }
}

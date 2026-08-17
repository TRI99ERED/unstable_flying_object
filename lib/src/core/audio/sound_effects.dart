import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

class SoundEffects {
  SoundEffects._() {
    FlameAudio.updatePrefix('assets/sfx/');
  }

  static final SoundEffects instance = SoundEffects._();

  static const double _volume = 0.5;

  AudioPool? _attachPool;
  AudioPool? _crashPool;
  AudioPlayer? ufoFloatingPlayer;

  Future<void> init() async {
    _attachPool = await FlameAudio.createPool('attach.wav', maxPlayers: 4);
    _crashPool = await FlameAudio.createPool('crash.wav', maxPlayers: 4);
  }

  void playAttach() {
    final pool = _attachPool;
    if (pool != null) unawaited(pool.start(volume: _volume));
  }

  void playCrash() {
    final pool = _crashPool;
    if (pool != null) unawaited(pool.start(volume: _volume));
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
}

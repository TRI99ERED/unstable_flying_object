import 'package:flutter/foundation.dart';
import 'package:unstable_flying_object/src/core/audio/sound_effects.dart';
import 'package:unstable_flying_object/src/core/utils/logger.dart';

enum GameState { menu, playing, gameOver }

class GameSession extends ChangeNotifier {
  GameState _state = GameState.menu;
  int _score = 0;
  int _bestScore = 0;

  GameState get state => _state;
  int get score => _score;
  int get bestScore => _bestScore;

  void start() {
    _score = 0;
    _state = GameState.playing;
    notifyListeners();
  }

  void addScore() {
    ++_score;
    if (_score > _bestScore) {
      _bestScore = _score;
    }
    notifyListeners();

    Logger.d(score.toString(), 'GameSession');
  }

  void gameOver() {
    if (_state == GameState.gameOver) return;

    _state = GameState.gameOver;
    notifyListeners();

    SoundEffects.instance.stopUfoFloating();

    Logger.d('Game over!', 'GameSession');
  }
}

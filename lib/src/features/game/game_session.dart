import 'package:flutter/foundation.dart';
import 'package:unstable_flying_object/src/core/audio/sound_effects.dart';

enum GameState { menu, settling, playing, gameOver }

class GameSession extends ChangeNotifier {
  GameState _state = GameState.menu;
  int _score = 0;
  int _bestScore = 0;

  GameState get state => _state;
  int get score => _score;
  int get bestScore => _bestScore;

  void loadBestScore(int bestScore) {
    _bestScore = bestScore;
    notifyListeners();
  }

  void menu() {
    _score = 0;
    _state = GameState.menu;
    notifyListeners();
  }

  void settle() {
    _score = 0;
    _state = GameState.settling;
    notifyListeners();
  }

  void play() {
    _score = 0;
    _state = GameState.playing;
    notifyListeners();
  }

  void addScore(int score) {
    _score += score;
    if (_score > _bestScore) {
      _bestScore = _score;
    }
    notifyListeners();
  }

  void gameOver() {
    if (_state == GameState.gameOver || _state == GameState.settling) return;

    _state = GameState.gameOver;
    notifyListeners();

    SoundEffects.instance.stopUfoFloating();
  }
}

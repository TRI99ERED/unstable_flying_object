import 'package:flutter/foundation.dart';
import 'package:unstable_flying_object/src/core/audio/sound_effects.dart';

enum GameState { menu, settling, playing, gameOver }

class GameSession extends ChangeNotifier {
  static const double comboDuration = 5.0;

  GameState _state = GameState.menu;
  int _score = 0;
  int _bestScore = 0;
  int _comboLevel = 0;
  double? _comboTimer;
  double scoreMultiplier = 1.0;

  GameState get state => _state;
  int get score => _score;
  int get bestScore => _bestScore;
  int get comboLevel => _comboLevel;
  double get comboTimerNormalized =>
      _comboTimer != null ? (_comboTimer! / comboDuration).clamp(0.0, 1.0) : 0.0;

  void loadBestScore(int bestScore) {
    _bestScore = bestScore;
    notifyListeners();
  }

  void menu() {
    _score = 0;
    _state = GameState.menu;
    _resetCombo();
    scoreMultiplier = 1.0;
    notifyListeners();
  }

  void settle() {
    _score = 0;
    _state = GameState.settling;
    _resetCombo();
    scoreMultiplier = 1.0;
    notifyListeners();
  }

  void play() {
    _score = 0;
    _state = GameState.playing;
    _resetCombo();
    scoreMultiplier = 1.0;
    notifyListeners();
  }

  void addScore(int score) {
    _score += score;
    if (_score > _bestScore) {
      _bestScore = _score;
    }
    notifyListeners();
  }

  void onAttach(int baseScore) {
    _comboLevel++;
    _comboTimer = comboDuration;
    addScore((baseScore * scoreMultiplier).round() * _comboLevel);
  }

  void updateCombo(double dt) {
    if (_comboTimer == null) return;
    _comboTimer = _comboTimer! - dt;
    if (_comboTimer! <= 0) {
      _resetCombo();
    }
    notifyListeners();
  }

  void _resetCombo() {
    _comboLevel = 0;
    _comboTimer = null;
  }

  void gameOver() {
    if (_state == GameState.gameOver || _state == GameState.settling) return;

    _state = GameState.gameOver;
    notifyListeners();

    SoundEffects.instance.stopUfoFloating();
  }
}

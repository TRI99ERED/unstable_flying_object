import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';
import 'package:unstable_flying_object/src/features/themes/game_fonts.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class GameOverOverlayComponent extends Component {
  final int score;

  GameOverOverlayComponent({required this.score});

  static const double _cycleDuration = 1.0;

  late int _colorIndex;
  double _elapsed = 0;

  @override
  void onLoad() {
    _colorIndex = Random().nextInt(Palette.levelBackgrounds.length);
  }

  @override
  void update(double dt) {
    _elapsed += dt;
    if (_elapsed >= _cycleDuration) {
      _elapsed = 0;
      _colorIndex = (_colorIndex + 1) % Palette.levelBackgrounds.length;
    }
  }

  @override
  void render(Canvas canvas) {
    final overlayRect = Rect.fromLTWH(
      0,
      0,
      UfoGame.kGameWidth,
      UfoGame.kGameHeight,
    );
    final overlayPaint = Paint()
      ..color = Palette.levelBackgrounds[_colorIndex].color;
    canvas.drawRect(overlayRect, overlayPaint);

    final centerX = UfoGame.kGameWidth / 2;
    final centerY = UfoGame.kGameHeight / 2;

    final messagePainter = TextPainter(
      text: TextSpan(
        text: 'Game Over!',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    messagePainter.layout();
    messagePainter.paint(
      canvas,
      Offset(
        centerX - messagePainter.width / 2,
        centerY - messagePainter.height / 2,
      ),
    );

    final scorePainter = TextPainter(
      text: TextSpan(
        text: 'Score: $score',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    scorePainter.layout();
    scorePainter.paint(
      canvas,
      Offset(
        centerX - scorePainter.width / 2,
        centerY + messagePainter.height / 2 + scorePainter.height,
      ),
    );

    final retryPainter = TextPainter(
      text: TextSpan(
        text: 'Press [R] to Retry',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    retryPainter.layout();
    retryPainter.paint(
      canvas,
      Offset(
        centerX - retryPainter.width / 2,
        centerY +
            messagePainter.height / 2 +
            scorePainter.height +
            retryPainter.height +
            8,
      ),
    );
  }
}

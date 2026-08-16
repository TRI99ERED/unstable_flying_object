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
      -UfoGame.kGameWidth / 2,
      -UfoGame.kGameHeight / 2,
      UfoGame.kGameWidth,
      UfoGame.kGameHeight,
    );
    final overlayPaint = Paint()
      ..color = Palette.levelBackgrounds[_colorIndex].color;
    canvas.drawRect(overlayRect, overlayPaint);

    final messagePainter = TextPainter(
      text: TextSpan(
        text: 'Game Over!',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 4.8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    messagePainter.layout();
    messagePainter.paint(
      canvas,
      Offset(-messagePainter.width / 2, -messagePainter.height / 2),
    );

    final moveCountPainter = TextPainter(
      text: TextSpan(
        text: 'Score: $score',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 3.2,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    moveCountPainter.layout();
    moveCountPainter.paint(
      canvas,
      Offset(
        -moveCountPainter.width / 2,
        messagePainter.height / 2 + moveCountPainter.height,
      ),
    );

    final retryPainter = TextPainter(
      text: TextSpan(
        text: 'Press [R] to Retry',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 2.4,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    retryPainter.layout();
    retryPainter.paint(
      canvas,
      Offset(
        -retryPainter.width / 2,
        messagePainter.height / 2 +
            moveCountPainter.height +
            retryPainter.height +
            8,
      ),
    );
  }
}

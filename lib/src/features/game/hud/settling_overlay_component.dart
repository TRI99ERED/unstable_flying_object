import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';
import 'package:unstable_flying_object/src/features/themes/game_fonts.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class SettlingOverlayComponent extends Component {
  double _elapsed = 0;

  @override
  void update(double dt) {
    _elapsed += dt;
  }

  @override
  void render(Canvas canvas) {
    final overlayRect = Rect.fromLTWH(
      0,
      0,
      UfoGame.kGameWidth,
      UfoGame.kGameHeight,
    );
    canvas.drawRect(overlayRect, Palette.color27.paint());

    final centerX = UfoGame.kGameWidth / 2;
    final centerY = UfoGame.kGameHeight / 2;

    final dots = '.' * ((_elapsed * 3).toInt() % 4);

    final messagePainter = TextPainter(
      text: TextSpan(
        text: 'Get ready$dots',
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
  }
}

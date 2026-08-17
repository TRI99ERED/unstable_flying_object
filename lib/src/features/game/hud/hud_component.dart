import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';
import 'package:unstable_flying_object/src/features/themes/game_fonts.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class HudComponent extends Component with HasGameReference<UfoGame> {
  @override
  void render(Canvas canvas) {
    final scoreTextPainter = TextPainter(
      text: TextSpan(
        text: '${game.session.score}',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    scoreTextPainter.layout();
    scoreTextPainter.paint(canvas, Offset(16, 16));
  }
}

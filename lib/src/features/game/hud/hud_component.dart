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
        text: 'Score: ${game.session.score}',
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

    final bestScoreTextPainter = TextPainter(
      text: TextSpan(
        text: 'Best: ${game.session.bestScore}',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    bestScoreTextPainter.layout();
    bestScoreTextPainter.paint(
      canvas,
      Offset(UfoGame.kGameWidth - bestScoreTextPainter.width - 16, 16),
    );

    final hintTextPainter = TextPainter(
      text: TextSpan(
        text: '[←↑↓→] or [WASD] to move. [Q] and [E] to rotate. [Esc] to menu',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    hintTextPainter.layout();
    hintTextPainter.paint(
      canvas,
      Offset(
        UfoGame.kGameWidth / 2 - hintTextPainter.width / 2,
        UfoGame.kGameHeight - hintTextPainter.height,
      ),
    );
  }
}

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:unstable_flying_object/src/features/game/entities/power_up_component.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';
import 'package:unstable_flying_object/src/features/themes/game_fonts.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class HudComponent extends Component with HasGameReference<UfoGame> {
  static const double _barWidth = 100;
  static const double _barHeight = 4;
  static const double _powerUpShapeSize = 6;
  static const double _powerUpSpacing = 22;

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

    if (game.session.comboLevel >= 1) {
      final comboTextPainter = TextPainter(
        text: TextSpan(
          text: 'x${game.session.comboLevel}',
          style: GameFonts.style(
            color: Palette.color12.color,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      comboTextPainter.layout();
      comboTextPainter.paint(canvas, const Offset(16, 56));

      final barX = 16.0;
      final barY = 92.0;
      final fillWidth = _barWidth * game.session.comboTimerNormalized;

      final bgPaint = Paint()..color = Palette.color27.color.withAlpha(128);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, _barWidth, _barHeight),
          const Radius.circular(2),
        ),
        bgPaint,
      );

      if (fillWidth > 0) {
        final fillPaint = Paint()..color = Palette.color12.color;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(barX, barY, fillWidth, _barHeight),
            const Radius.circular(2),
          ),
          fillPaint,
        );
      }
    }

    final powerUpManager = game.powerUpManager;
    var powerUpIndex = 0;
    for (final type in PowerUpType.values) {
      if (!powerUpManager.isActive(type)) continue;

      final x = 16.0;
      final y = 100.0 + powerUpIndex * _powerUpSpacing;

      _drawPowerUpShape(canvas, type, x, y + _powerUpShapeSize / 2);

      final timerNormalized = powerUpManager.getTimerNormalized(type);
      final barFillWidth = _barWidth * timerNormalized;

      final bgPaint = Paint()..color = Palette.color27.color.withAlpha(128);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + _powerUpShapeSize + 6, y, _barWidth, _barHeight),
          const Radius.circular(2),
        ),
        bgPaint,
      );

      if (barFillWidth > 0) {
        final fillPaint = Paint()..color = type.color.color;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              x + _powerUpShapeSize + 6,
              y,
              barFillWidth,
              _barHeight,
            ),
            const Radius.circular(2),
          ),
          fillPaint,
        );
      }

      final labelPainter = TextPainter(
        text: TextSpan(
          text: type.label,
          style: GameFonts.style(
            color: Palette.color20.color,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(x + _powerUpShapeSize + 6, y + _barHeight + 1),
      );
      labelPainter.dispose();

      powerUpIndex++;
    }

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

  void _drawPowerUpShape(
    Canvas canvas,
    PowerUpType type,
    double cx,
    double cy,
  ) {
    final s = _powerUpShapeSize / 2;
    final paint = Paint()..color = type.color.color;

    switch (type) {
      case PowerUpType.antiGravity:
        final path = Path()
          ..moveTo(cx, cy - s)
          ..lineTo(cx + s, cy)
          ..lineTo(cx, cy + s)
          ..lineTo(cx - s, cy)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case PowerUpType.beamBoost:
        canvas.drawCircle(Offset(cx, cy), s, paint);
        break;
      case PowerUpType.speedBoost:
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(cx, cy),
            width: s * 1.6,
            height: s * 1.6,
          ),
          paint,
        );
        break;
      case PowerUpType.scoreBoost:
        canvas.drawCircle(Offset(cx, cy), s, paint);
        final holePaint = Paint()..color = Palette.color18.color;
        canvas.drawCircle(Offset(cx, cy), s * 0.45, holePaint);
        break;
    }
  }
}

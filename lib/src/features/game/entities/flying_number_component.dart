import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:unstable_flying_object/src/features/themes/game_fonts.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class FlyingNumberComponent extends PositionComponent {
  static const double _duration = 1.0;
  static const double _floatDistance = 3.0;
  static const double _fontSize = 20 / 10;

  final String objectName;
  final int objectScore;
  late final TextPainter _textPainter;
  double _elapsed = 0;

  FlyingNumberComponent({
    required super.position,
    required this.objectName,
    required this.objectScore,
  }) {
    priority = 1000;
  }

  @override
  Future<void> onLoad() async {
    _textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$objectName ',
            style: GameFonts.style(
              color: Palette.color20.color,
              fontSize: _fontSize,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(
            text: '+$objectScore',
            style: GameFonts.style(
              color: Palette.color12.color,
              fontSize: _fontSize,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    add(
      MoveEffect.by(
        Vector2(0, -_floatDistance),
        EffectController(duration: _duration, curve: Curves.easeOut),
      ),
    );

    add(RemoveEffect(delay: _duration));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
  }

  @override
  void render(Canvas canvas) {
    final opacity = (1 - (_elapsed / _duration)).clamp(0.0, 1.0);
    final paint = Paint()..color = Color.fromRGBO(255, 255, 255, opacity);
    canvas.saveLayer(
      Rect.fromCenter(
        center: Offset.zero,
        width: _textPainter.width,
        height: _textPainter.height,
      ),
      paint,
    );
    _textPainter.paint(
      canvas,
      Offset(-_textPainter.width / 2, -_textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  void onRemove() {
    _textPainter.dispose();
    super.onRemove();
  }
}

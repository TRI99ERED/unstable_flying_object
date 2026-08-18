import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';
import 'package:unstable_flying_object/src/features/themes/game_fonts.dart';
import 'package:unstable_flying_object/src/features/themes/palette.dart';

class TitleScene extends Component {
  TitleScene();

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    final ufo = PolygonComponent(
      [
        Vector2(-20, 0),
        Vector2(-10, 8.5),
        Vector2(10, 8.5),
        Vector2(20, 0),
        Vector2(0, -10),
      ],
      priority: 127,
      position: Vector2(
        UfoGame.kGameWidth / 2 - 10,
        UfoGame.kGameHeight / 2 - 4.25 - 200,
      ),
      paint: Palette.color23.paint(),
    );
    final beam = PolygonComponent(
      [
        Vector2(-10, 8.5),
        Vector2(10, 8.5),
        Vector2(200, 1000),
        Vector2(-200, 1000),
      ],
      position: Vector2(-180, 19),
      paint: Palette.color19.withAlpha(10).paint(),
    );
    beam.add(
      OpacityEffect.to(
        70 / 255,
        InfiniteEffectController(SineEffectController(period: 2 * pi / 3)),
      ),
    );
    ufo.add(beam);
    ufo.add(
      MoveEffect.by(
        Vector2(100, 0),
        InfiniteEffectController(SineEffectController(period: 4)),
      ),
    );
    ufo.add(
      MoveEffect.by(
        Vector2(0, 10),
        InfiniteEffectController(SineEffectController(period: 2)),
      ),
    );
    add(ufo);
  }

  @override
  void render(Canvas canvas) {
    final overlayRect = Rect.fromLTWH(
      0,
      0,
      UfoGame.kGameWidth,
      UfoGame.kGameHeight,
    );
    final overlayPaint = Palette.color27.paint();
    canvas.drawRect(overlayRect, overlayPaint);

    final centerX = UfoGame.kGameWidth / 2;
    final centerY = UfoGame.kGameHeight / 2;

    final titlePainter = TextPainter(
      text: TextSpan(
        text: 'U',
        style: GameFonts.style(
          color: Palette.color29.color,
          fontSize: 64,
          fontWeight: FontWeight.w900,
        ),
        children: [
          TextSpan(
            text: 'nstable\n',
            style: TextStyle(color: Palette.color20.color),
          ),
          TextSpan(text: 'F'),
          TextSpan(
            text: 'lying\n',
            style: TextStyle(color: Palette.color20.color),
          ),
          TextSpan(text: 'O'),
          TextSpan(
            text: 'bject',
            style: TextStyle(color: Palette.color20.color),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(
        centerX - titlePainter.width / 2,
        centerY - titlePainter.height / 2,
      ),
    );

    final hintPainter = TextPainter(
      text: TextSpan(
        text: 'Press [Enter] to start',
        style: GameFonts.style(
          color: Palette.color20.color,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    hintPainter.layout();
    hintPainter.paint(
      canvas,
      Offset(
        centerX - hintPainter.width / 2,
        centerY + UfoGame.kGameHeight / 2 - 64,
      ),
    );
  }
}

import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unstable_flying_object/src/features/game/ufo_game.dart';

import 'src/core/utils/logger.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      runApp(GameWidget(game: UfoGame()));
    },
    (error, stackTrace) {
      Logger.e('Uncaught error', 'Main', error, stackTrace);
    },
  );
}

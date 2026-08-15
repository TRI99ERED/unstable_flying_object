import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameFonts {
  static TextStyle style({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.geistMono(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  static void disableRuntimeFetching() {
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  static void preload() {
    GoogleFonts.geistMono();
    GoogleFonts.geistMono(fontWeight: FontWeight.w400);
    GoogleFonts.geistMono(fontWeight: FontWeight.w900);
  }
}

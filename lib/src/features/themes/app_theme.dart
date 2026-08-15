import 'package:flutter/material.dart';

class AppTheme extends ThemeExtension<AppTheme> {
  final Color highlightDarkestColor;
  final Color highlightDarkColor;
  final Color highlightMediumColor;
  final Color highlightLightColor;
  final Color highlightLightestColor;
  final Color mainColor;
  final Color greyStrongestColor;
  final Color greyStrongColor;
  final Color greyMediumColor;
  final Color greyWeakColor;
  final Color greyWeakestColor;
  final Color offColor;

  const AppTheme({
    this.highlightDarkestColor = const Color(0xFF3F2832),
    this.highlightDarkColor = const Color(0xFF743F39),
    this.highlightMediumColor = const Color(0xFFB86F50),
    this.highlightLightColor = const Color(0xFFE4A672),
    this.highlightLightestColor = const Color(0xFFEAD4AA),
    this.mainColor = const Color(0xFFFFFFFF),
    this.greyStrongestColor = const Color(0xFFC0CBDC),
    this.greyStrongColor = const Color(0xFF8B9BB4),
    this.greyMediumColor = const Color(0xFF5A6988),
    this.greyWeakColor = const Color(0xFF3A4466),
    this.greyWeakestColor = const Color(0xFF262B44),
    this.offColor = const Color(0xFF181425),
  });

  @override
  AppTheme copyWith({
    Color? highlightDarkestColor,
    Color? highlightDarkColor,
    Color? highlightMediumColor,
    Color? highlightLightColor,
    Color? highlightLightestColor,
    Color? mainColor,
    Color? greyStrongestColor,
    Color? greyStrongColor,
    Color? greyMediumColor,
    Color? greyWeakColor,
    Color? greyWeakestColor,
    Color? offColor,
  }) {
    return AppTheme(
      highlightDarkestColor:
          highlightDarkestColor ?? this.highlightDarkestColor,
      highlightDarkColor: highlightDarkColor ?? this.highlightDarkColor,
      highlightMediumColor: highlightMediumColor ?? this.highlightMediumColor,
      highlightLightColor: highlightLightColor ?? this.highlightLightColor,
      highlightLightestColor:
          highlightLightestColor ?? this.highlightLightestColor,
      mainColor: mainColor ?? this.mainColor,
      greyStrongestColor: greyStrongestColor ?? this.greyStrongestColor,
      greyStrongColor: greyStrongColor ?? this.greyStrongColor,
      greyMediumColor: greyMediumColor ?? this.greyMediumColor,
      greyWeakColor: greyWeakColor ?? this.greyWeakColor,
      greyWeakestColor: greyWeakestColor ?? this.greyWeakestColor,
      offColor: offColor ?? this.offColor,
    );
  }

  @override
  AppTheme lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) {
      return this;
    }
    return AppTheme(
      highlightDarkestColor: Color.lerp(
        highlightDarkestColor,
        other.highlightDarkestColor,
        t,
      )!,
      highlightDarkColor: Color.lerp(
        highlightDarkColor,
        other.highlightDarkColor,
        t,
      )!,
      highlightMediumColor: Color.lerp(
        highlightMediumColor,
        other.highlightMediumColor,
        t,
      )!,
      highlightLightColor: Color.lerp(
        highlightLightColor,
        other.highlightLightColor,
        t,
      )!,
      highlightLightestColor: Color.lerp(
        highlightLightestColor,
        other.highlightLightestColor,
        t,
      )!,
      mainColor: Color.lerp(mainColor, other.mainColor, t)!,
      greyStrongestColor: Color.lerp(
        greyStrongestColor,
        other.greyStrongestColor,
        t,
      )!,
      greyStrongColor: Color.lerp(greyStrongColor, other.greyStrongColor, t)!,
      greyMediumColor: Color.lerp(greyMediumColor, other.greyMediumColor, t)!,
      greyWeakColor: Color.lerp(greyWeakColor, other.greyWeakColor, t)!,
      greyWeakestColor: Color.lerp(
        greyWeakestColor,
        other.greyWeakestColor,
        t,
      )!,
      offColor: Color.lerp(offColor, other.offColor, t)!,
    );
  }
}

const appThemeLight = AppTheme();

const appThemeDark = AppTheme(
  mainColor: Color(0xFF181425),
  greyStrongestColor: Color(0xFF262B44),
  greyStrongColor: Color(0xFF3A4466),
  greyMediumColor: Color(0xFF5A6988),
  greyWeakColor: Color(0xFF8B9BB4),
  greyWeakestColor: Color(0xFFC0CBDC),
  offColor: Color(0xFFFFFFFF),
);

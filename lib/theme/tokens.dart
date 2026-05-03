import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Colour palette ───────────────────────────────────────────────────────────
// Converted from the HTML prototype's oklch values.
class AppColors {
  AppColors._();

  // Backgrounds — warm off-white
  static const Color bg0 = Color(0xFFFAF9F6);
  static const Color bg1 = Color(0xFFF5F4F1);
  static const Color bg2 = Color(0xFFEDECE9);
  static const Color bg3 = Color(0xFFE2E1DD);
  static const Color card = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFE5E4E0);

  // Ink — near-black with slight blue tinge
  static const Color ink0 = Color(0xFF1D1C28);
  static const Color ink1 = Color(0xFF2E2D3B);
  static const Color ink2 = Color(0xFF67667C);
  static const Color ink3 = Color(0xFF9C9BAB);
  static const Color ink4 = Color(0xFFBAB9C8);

  // You — warm gold (oklch 0.62 0.13 70)
  static const Color you = Color(0xFFB8882A);
  static const Color youDim = Color(0xFFC99B3C);
  static const Color youSoft = Color(0xFFF5EDD8);
  static const Color youGlow = Color(0x1AB8882A);

  // Partner — cool slate (oklch 0.50 0.07 240)
  static const Color pal = Color(0xFF4F6A90);
  static const Color palDim = Color(0xFF6880A5);
  static const Color palSoft = Color(0xFFEAF0F8);
  static const Color palGlow = Color(0x1A4F6A90);

  static const Color ok = Color(0xFF3D9B6A);
  static const Color warn = Color(0xFFC49420);
  static const Color alert = Color(0xFFC44A4A);
}

// ─── Shadows ──────────────────────────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A14120C), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F14120C), blurRadius: 20, spreadRadius: -8, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> pop = [
    BoxShadow(color: Color(0x0D14120C), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x1F14120C), blurRadius: 40, spreadRadius: -12, offset: Offset(0, 16)),
  ];

  static const List<BoxShadow> nav = [
    BoxShadow(color: Color(0x2E14120C), blurRadius: 32, spreadRadius: -8, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0A14120C), blurRadius: 2, offset: Offset(0, 1)),
  ];
}

// ─── Typography ───────────────────────────────────────────────────────────────
class AppText {
  AppText._();

  static TextStyle display({
    double size = 17,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.ink0,
    double? letterSpacing,
    double height = 1.0,
  }) =>
      GoogleFonts.interTight(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing ?? size * -0.030,
        height: height,
      );

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink0,
    double letterSpacing = 0,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Small all-caps tracking label
  static TextStyle tracked({
    double size = 9.5,
    Color color = AppColors.ink3,
    FontWeight weight = FontWeight.w600,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: size * 0.16,
      );

  static TextStyle editorial({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink2,
    FontStyle fontStyle = FontStyle.italic,
    double height = 1.4,
  }) =>
      GoogleFonts.newsreader(
        fontSize: size,
        fontWeight: weight,
        color: color,
        fontStyle: fontStyle,
        height: height,
        letterSpacing: -0.14,
      );
}

// ─── Card decoration ──────────────────────────────────────────────────────────
BoxDecoration cardDecoration({double radius = 20}) => BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.hairline, width: 1),
      boxShadow: AppShadows.card,
    );

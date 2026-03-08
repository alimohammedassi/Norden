/// App theme tokens — NORDEN Maison de Luxe
/// Provides Winter and Summer design token sets.
import 'package:flutter/material.dart';
import '../models/season.dart';

class AppTheme {
  AppTheme._();

  // ── Winter Tokens (default) ───────────────────────────────────────────────
  static const Color winterBg = Color(0xFF080808);
  static const Color winterSurface = Color(0xFF111111);
  static const Color winterSurface2 = Color(0xFF181818);
  static const Color winterBorder = Color(0xFF242424);
  static const Color winterGold = Color(0xFFD4AF37);
  static const Color winterGoldLt = Color(0xFFF0D060);
  static const Color winterGoldDk = Color(0xFF9A7A1A);
  static const Color winterText = Colors.white;
  static const Color winterSubtext = Color(0xFF999999);

  // ── Summer Tokens ─────────────────────────────────────────────────────────
  static const Color summerBg = Color(0xFFFBF5E9);
  static const Color summerSurface = Color(0xFFF5EDD8);
  static const Color summerSurface2 = Color(0xFFEDE2C8);
  static const Color summerBorder = Color(0xFFDDD0B5);
  static const Color summerGold = Color(0xFFB8893A);
  static const Color summerGoldLt = Color(0xFFD4A85A);
  static const Color summerGoldDk = Color(0xFF8A6020);
  static const Color summerText = Color(0xFF1A1206);
  static const Color summerSubtext = Color(0xFF7A6545);

  // ── Token accessor ────────────────────────────────────────────────────────
  static SeasonTokens of(SeasonMode mode) =>
      mode == SeasonMode.summer ? summerTokens : winterTokens;

  static const SeasonTokens winterTokens = SeasonTokens(
    bg: winterBg,
    surface: winterSurface,
    surface2: winterSurface2,
    border: winterBorder,
    gold: winterGold,
    goldLight: winterGoldLt,
    goldDark: winterGoldDk,
    text: winterText,
    subtext: winterSubtext,
  );

  static const SeasonTokens summerTokens = SeasonTokens(
    bg: summerBg,
    surface: summerSurface,
    surface2: summerSurface2,
    border: summerBorder,
    gold: summerGold,
    goldLight: summerGoldLt,
    goldDark: summerGoldDk,
    text: summerText,
    subtext: summerSubtext,
  );
}

/// Immutable token set for a season
class SeasonTokens {
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color gold;
  final Color goldLight;
  final Color goldDark;
  final Color text;
  final Color subtext;
  static const Color red = Color(0xFFFF3B30);

  const SeasonTokens({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.gold,
    required this.goldLight,
    required this.goldDark,
    required this.text,
    required this.subtext,
  });
}

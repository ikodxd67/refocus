import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Calm, non-alarming palette for Refocus.
/// Two app themes (light/dark) + a fixed "night" palette used only by the
/// pause screen, which stays dark in both themes on purpose.
class AppPalette {
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color ink;
  final Color muted;
  final Color faint;
  final Color line;
  final Color teal;
  final Color tealSoft;
  final Color tealInk;

  const AppPalette({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.line,
    required this.teal,
    required this.tealSoft,
    required this.tealInk,
  });

  static const light = AppPalette(
    bg: Color(0xFFEBEEF1),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF5F7F9),
    ink: Color(0xFF141C26),
    muted: Color(0xFF5D6B7A),
    faint: Color(0xFF8B98A6),
    line: Color(0xFFDCE2E8),
    teal: Color(0xFF0E7C6B),
    tealSoft: Color(0xFFD6ECE6),
    tealInk: Color(0xFF0A5A4E),
  );

  static const dark = AppPalette(
    bg: Color(0xFF0C1017),
    surface: Color(0xFF151B25),
    surface2: Color(0xFF1B222E),
    ink: Color(0xFFEAEFF4),
    muted: Color(0xFF9BA8B7),
    faint: Color(0xFF6C7A8A),
    line: Color(0xFF242D3A),
    teal: Color(0xFF3FCBB4),
    tealSoft: Color(0xFF123029),
    tealInk: Color(0xFF8FE4D6),
  );

  /// Pick the palette for the current brightness.
  static AppPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Fixed dark palette for the pause screen (identical in light & dark mode).
class NightPalette {
  static const bg = Color(0xFF0E1526);
  static const bgTop = Color(0xFF1B2A4A);
  static const surface = Color(0x0FFFFFFF); // white @ ~6%
  static const surfaceLine = Color(0x1FFFFFFF); // white @ ~12%
  static const ink = Color(0xFFEAF0F7);
  static const muted = Color(0xFF93A2BC);
  static const teal = Color(0xFF3FCBB4);
}

class AppTheme {
  static ThemeData _base(Brightness brightness, AppPalette p) {
    final scheme = ColorScheme.fromSeed(
      seedColor: p.teal,
      brightness: brightness,
    ).copyWith(
      surface: p.surface,
      primary: p.teal,
    );

    final textTheme = GoogleFonts.manropeTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: p.ink, displayColor: p.ink);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bg,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static ThemeData light() => _base(Brightness.light, AppPalette.light);
  static ThemeData dark() => _base(Brightness.dark, AppPalette.dark);

  /// Serif face for the reframe line and other "editorial" moments.
  static TextStyle serif({
    double size = 18,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double height = 1.4,
  }) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
}

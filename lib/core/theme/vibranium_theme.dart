import 'package:flutter/material.dart';

/// Brand colors sampled from the Vibranium Esport shield logo:
/// — pure black field, saturated violet frame, electric cyan accent (eye),
/// — white typography and inner highlights.
abstract final class VibraniumColors {
  VibraniumColors._();

  /// Logo background / shield field.
  static const Color black = Color(0xFF000000);

  /// Raised surfaces slightly above pure black.
  static const Color surface = Color(0xFF0D0D0F);

  /// Inputs, cards — dark with a subtle violet cast (hood / inner shield).
  static const Color surfaceContainer = Color(0xFF16101F);

  /// Thick outer shield stroke — primary brand hue.
  static const Color purple = Color(0xFFA855F7);

  /// Deeper violet for gradients and secondary emphasis.
  static const Color purpleDeep = Color(0xFF7C3AED);

  /// Glowing eye — focus rings, links, active highlights.
  static const Color cyan = Color(0xFF22D3EE);

  /// Main on-dark text (logo wordmark).
  static const Color white = Color(0xFFFFFFFF);

  /// Secondary body copy.
  static const Color onSurfaceMuted = Color(0xFFB4B4C8);

  /// Hairline borders (inner white stroke, dimmed for UI).
  static const Color outline = Color(0xFF3D3558);
}

/// Dark Material 3 theme aligned with [VibraniumColors].
ThemeData vibraniumDarkTheme() {
  final scheme = ColorScheme.dark(
    surface: VibraniumColors.surface,
    onSurface: VibraniumColors.white,
    primary: VibraniumColors.purple,
    onPrimary: VibraniumColors.white,
    secondary: VibraniumColors.purpleDeep,
    onSecondary: VibraniumColors.white,
    tertiary: VibraniumColors.cyan,
    onTertiary: VibraniumColors.black,
    surfaceContainerHighest: VibraniumColors.surfaceContainer,
    onSurfaceVariant: VibraniumColors.onSurfaceMuted,
    outline: VibraniumColors.outline,
    error: const Color(0xFFFF8A80),
    onError: VibraniumColors.black,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: VibraniumColors.black,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: VibraniumColors.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.65)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.65)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.tertiary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        foregroundColor: scheme.onPrimary,
        backgroundColor: scheme.primary,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.tertiary),
    ),
  );
}

import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

/// 暗色主题与设计 Token（需求文档 §10.1 最小集）
abstract final class AppTheme {
  static ThemeData dark() {
    const bg = Color(0xFF121212);
    const bgSecondary = Color(0xFF1E1E1E);
    const card = Color(0xFF2C2C2C);
    const divider = Color(0xFF3D3D3D);
    const onSurface = Color(0xFFE8E8E8);
    const onSurfaceVariant = Color(0xFFB0B0B0);
    const success = Color(0xFF4CAF50);
    const warning = Color(0xFFFFC107);
    const error = Color(0xFFEF5350);

    final colorScheme = ColorScheme.dark(
      surface: bg,
      onSurface: onSurface,
      primary: const Color(0xFF7C9EFF),
      onPrimary: Colors.black,
      secondary: const Color(0xFF80D8FF),
      error: error,
      outline: divider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      dividerColor: divider,
      cardTheme: CardThemeData(
        color: card,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: bgSecondary,
        foregroundColor: onSurface,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: onSurface),
        bodyMedium: TextStyle(fontSize: 14, color: onSurface),
        bodySmall: TextStyle(fontSize: 12, color: onSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppColors(
          background: bg,
          backgroundSecondary: bgSecondary,
          card: card,
          divider: divider,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          success: success,
          warning: warning,
          error: error,
        ),
      ],
    );
  }
}

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.backgroundSecondary,
    required this.card,
    required this.divider,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.success,
    required this.warning,
    required this.error,
  });

  final Color background;
  final Color backgroundSecondary;
  final Color card;
  final Color divider;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color success;
  final Color warning;
  final Color error;

  @override
  AppColors copyWith({
    Color? background,
    Color? backgroundSecondary,
    Color? card,
    Color? divider,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return AppColors(
      background: background ?? this.background,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      card: card ?? this.card,
      divider: divider ?? this.divider,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      backgroundSecondary:
          Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      card: Color.lerp(card, other.card, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>()!;
}

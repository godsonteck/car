import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  // Updated Color Palette for better harmony and modern look
  static const Color primaryColor = Color(0xFF0052CC); // Strong Blue
  static const Color secondaryColor = Color(0xFF2684FF); // Vivid Blue
  static const Color accentColor = Color(0xFF00BFA6); // Teal
  static const Color successColor = Color(0xFF00C853); // Bright Green
  static const Color warningColor = Color(0xFFFFAB00); // Amber
  static const Color errorColor = Color(0xFFD50000); // Strong Red

  // Neutral Colors - Dark Theme
  static const Color backgroundColorDark = Color(0xFF121B2B); // Darker Blue Background
  static const Color surfaceColorDark = Color(0xFF1E2A47); // Dark Blue Surface
  static const Color cardColorDark = Color(0xFF273858); // Dark Blue Card

  // Neutral Colors - Light Theme
  static const Color backgroundColorLight = Color(0xFFF5F7FA); // Soft White Background
  static const Color surfaceColorLight = Color(0xFFFFFFFF); // White Surface
  static const Color cardColorLight = Color(0xFFF0F4F8); // Light Gray Card

  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFE1E6F0); // Soft White
  static const Color textSecondaryDark = Color(0xFF9AA5B1); // Medium Gray
  static const Color textTertiaryDark = Color(0xFF6B7A8F); // Dark Gray

  // Text Colors - Light Theme
  static const Color textPrimaryLight = Color(0xFF1B263B); // Dark Blue
  static const Color textSecondaryLight = Color(0xFF4A5A75); // Medium Blue Gray
  static const Color textTertiaryLight = Color(0xFF7B8CA3); // Light Blue Gray

  // Border Colors
  static const Color borderColorDark = Color(0xFF394B6A); // Dark Blue Border
  static const Color dividerColorDark = Color(0xFF394B6A); // Dark Blue Divider

  // Border Colors - Light Theme
  static const Color borderColorLight = Color(0xFFD9E2EC); // Light Blue Border
  static const Color dividerColorLight = Color(0xFFD9E2EC); // Light Blue Divider

  // Backward compatibility getters for existing code
  static Color get backgroundColor => backgroundColorLight;
  static Color get surfaceColor => surfaceColorLight;
  static Color get cardColor => cardColorLight;
  static Color get textPrimary => textPrimaryLight;
  static Color get textSecondary => textSecondaryLight;
  static Color get textTertiary => textTertiaryLight;
  static Color get borderColor => borderColorLight;
  static Color get dividerColor => dividerColorLight;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, Color(0xFF00E5B4)],
  );

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;
  static const double borderRadiusXL = 20.0;
  static const double borderRadiusXXL = 24.0;

  // Shadows
  static final BoxShadow shadowSm = BoxShadow(
    color: const Color(0x000000).withAlpha(13), // 5% opacity
    blurRadius: 4,
    offset: const Offset(0, 1),
  );

  static final BoxShadow shadowMd = BoxShadow(
    color: const Color(0x000000).withAlpha(26), // 10% opacity
    blurRadius: 8,
    offset: const Offset(0, 4),
  );

  static final BoxShadow shadowLg = BoxShadow(
    color: const Color(0x000000).withAlpha(38), // 15% opacity
    blurRadius: 12,
    offset: const Offset(0, 8),
  );

  static final BoxShadow shadowXl = BoxShadow(
    color: const Color(0x000000).withAlpha(51), // 20% opacity
    blurRadius: 16,
    offset: const Offset(0, 12),
  );

  // Text Styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: textPrimaryDark,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: textPrimaryDark,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimaryDark,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimaryDark,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryDark,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryDark,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimaryDark,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimaryDark,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textPrimaryDark,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimaryDark,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimaryDark,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textPrimaryDark,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondaryDark,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondaryDark,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textSecondaryDark,
  );

  // Neumorphic Shadows
  static final BoxShadow neumorphicShadow = BoxShadow(
    color: Colors.black.withAlpha(77), // 0.3 * 255
    blurRadius: 8,
    offset: const Offset(4, 4),
  );

  static final BoxShadow neumorphicHighlight = BoxShadow(
    color: Colors.white.withAlpha(26), // 0.1 * 255
    blurRadius: 8,
    offset: const Offset(-4, -4),
  );

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColorDark,
        background: backgroundColorDark,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColorDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColorDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimaryDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surfaceColorDark,
          foregroundColor: textPrimaryDark,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusM),
          ),
          textStyle: titleLarge.copyWith(color: textPrimaryDark),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingM,
            vertical: spacingS,
          ),
          textStyle: titleMedium.copyWith(color: primaryColor),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusM),
          ),
          textStyle: titleMedium.copyWith(color: primaryColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColorDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: borderColorDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: borderColorDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(spacingM),
        hintStyle: bodyMedium.copyWith(color: textTertiaryDark),
        labelStyle: titleMedium.copyWith(color: textSecondaryDark),
        errorStyle: bodySmall.copyWith(color: errorColor),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColorDark,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColorLight,
        background: backgroundColorLight,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColorLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColorLight,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimaryLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surfaceColorLight,
          foregroundColor: textPrimaryLight,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusM),
          ),
          textStyle: titleLarge.copyWith(color: textPrimaryLight),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingM,
            vertical: spacingS,
          ),
          textStyle: titleMedium.copyWith(color: primaryColor),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusM),
          ),
          textStyle: titleMedium.copyWith(color: primaryColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColorLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: borderColorLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: borderColorLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(spacingM),
        hintStyle: bodyMedium.copyWith(color: textTertiaryLight),
        labelStyle: titleMedium.copyWith(color: textSecondaryLight),
        errorStyle: bodySmall.copyWith(color: errorColor),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColorLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Categories
  static const List<String> categories = [
    'All',
    'Sedan',
    'SUV',
    'Sports',
    'Luxury',
    'Supercar',
    'Compact',
    'Hatchback',
    'Van',
    'Electric',
    'Hybrid'
  ];

  // Gradient Colors
  static const List<Color> gradientColors = [
    primaryColor,
    secondaryColor,
  ];

  // Helper methods
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(borderRadiusM),
      boxShadow: [shadowMd],
    );
  }

  static BoxDecoration get elevatedCardDecoration {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(borderRadiusM),
      boxShadow: [shadowLg],
    );
  }

  static BoxDecoration get primaryCardDecoration {
    return BoxDecoration(
      gradient: primaryGradient,
      borderRadius: BorderRadius.circular(borderRadiusM),
      boxShadow: [shadowLg],
    );
  }

  static BoxDecoration get accentCardDecoration {
    return BoxDecoration(
      gradient: accentGradient,
      borderRadius: BorderRadius.circular(borderRadiusM),
      boxShadow: [shadowLg],
    );
  }

  // Neumorphic helper methods
  static BoxDecoration get neumorphicDecoration {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(borderRadiusM),
      boxShadow: [
        neumorphicShadow,
        neumorphicHighlight,
      ],
    );
  }

  static BoxDecoration get neumorphicPressedDecoration {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(borderRadiusM),
      boxShadow: [
        neumorphicHighlight,
        neumorphicShadow,
      ],
    );
  }

  static BoxDecoration get glassmorphicDecoration {
    return BoxDecoration(
      color: surfaceColor.withOpacity(0.8),
      borderRadius: BorderRadius.circular(borderRadiusM),
      border: Border.all(
        color: borderColor.withOpacity(0.5),
        width: 1,
      ),
      boxShadow: [shadowMd],
    );
  }
}

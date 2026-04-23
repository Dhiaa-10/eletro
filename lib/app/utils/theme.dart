import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static TextTheme get _textTheme => TextTheme(
    headlineLarge: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w800),
    headlineMedium: GoogleFonts.cairo(
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700),
    titleLarge: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700),
    titleMedium: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600),
    titleSmall: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600),
    labelSmall: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w400),
  );

  static InputDecorationTheme _inputDecTheme(bool isDark) =>
      InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkCard2 : AppColors.lightCard2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.cairo(
          color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
          fontSize: 13,
        ),
        labelStyle: GoogleFonts.cairo(fontSize: 13),
      );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    textTheme: _textTheme.apply(
      bodyColor: AppColors.lightText,
      displayColor: AppColors.lightText,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightCard,
      foregroundColor: AppColors.lightText,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    inputDecorationTheme: _inputDecTheme(false),
    dividerTheme: const DividerThemeData(color: AppColors.lightBorder),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkCard,
      contentTextStyle: GoogleFonts.cairo(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    textTheme: _textTheme.apply(
      bodyColor: AppColors.darkText,
      displayColor: AppColors.darkText,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkCard,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    inputDecorationTheme: _inputDecTheme(true),
    dividerTheme: const DividerThemeData(color: AppColors.darkBorder),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkCard2,
      contentTextStyle: GoogleFonts.cairo(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//==============================================================================
// App Theme Definitions
//==============================================================================

class AppColors {
  static const primary = Color(0xFF3B82F6);
  static const secondary = Color(0xFF14B8A6);
  static const background = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const fontTitle = Color(0xFF1E293B);
  static const fontBody = Color(0xFF475569);

  static const statusSafe = Color(0xFF22C55E);
  static const statusModerate = Color(0xFFF59E0B);
  static const statusCritical = Color(0xFFEF4444);
  static const chartLine = Color(0xFF38BDF8);
  static const chartGrid = Color(0xFFE2E8F0);
  static const chartBackground = Color(0xFFF8FAFC);
}

ThemeData buildAppTheme() {
  final baseTheme = ThemeData.light(useMaterial3: true);
  return baseTheme.copyWith(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).copyWith(
      headlineSmall: const TextStyle(color: AppColors.fontTitle, fontWeight: FontWeight.bold),
      titleLarge: const TextStyle(color: AppColors.fontTitle, fontWeight: FontWeight.bold),
      titleMedium: const TextStyle(color: AppColors.fontBody),
      bodyMedium: const TextStyle(color: AppColors.fontBody),
      bodySmall: const TextStyle(color: AppColors.fontBody),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.fontTitle,
      elevation: 4,
      shadowColor: Color(0x1A1E293B),
      centerTitle: true,
      shape: Border(bottom: BorderSide.none),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.chartGrid, width: 1),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      headingTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.fontTitle),
      dataTextStyle: GoogleFonts.poppins(color: AppColors.fontBody),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.fontBody,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    colorScheme: const ColorScheme.light(primary: AppColors.primary, secondary: AppColors.secondary),
  );
}
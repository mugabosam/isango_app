import 'package:flutter/material.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/theme/app_radii.dart';

import 'app_text_styles.dart';

class AppTheme {
  static ThemeData light(){
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.logisticsNavy,
      primary: AppColors.logisticsNavy,
      secondary: AppColors.commandBlue,
      surface: AppColors.cardWhite,
      error: AppColors.criticalRed,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.mistBackground,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardWhite,
        foregroundColor: AppColors.logisticsNavy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.title,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: const BorderSide(color: AppColors.softBorder)
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cardWhite,
        indicatorColor: AppColors.paleSignalBlue,
        iconTheme: WidgetStateProperty.resolveWith((states){
          final color = states.contains(WidgetState.selected)
              ? AppColors.logisticsNavy
              : AppColors.mutedOperationalInk;
          return IconThemeData(color: color);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states){
          final color = states.contains(WidgetState.selected)
              ? AppColors.logisticsNavy
              : AppColors.mutedOperationalInk;
          return AppTextStyles.label.copyWith(color: color);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.mutedOperationalInk,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(color: AppColors.softBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(color: AppColors.softBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(
            color: AppColors.logisticsNavy,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(color: AppColors.criticalRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(
            color: AppColors.criticalRed,
            width: 1.4,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.criticalRed,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.display,
        headlineMedium: AppTextStyles.headline,
        titleMedium: AppTextStyles.title,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodyMuted,
        labelMedium: AppTextStyles.label
      ),
    );
  }
}
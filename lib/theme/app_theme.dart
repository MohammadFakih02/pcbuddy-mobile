import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // 1. Background Colors
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkBackground, // For Drawers/BottomSheets

      // 2. Color Scheme (The core palette)
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.lightBlue,
        surface: AppColors.cardSurface,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),

      // 3. Text Theme (Automatic White/Grey text)
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.white, 
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineMedium: TextStyle(
          color: AppColors.white, 
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(color: AppColors.white, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.greyText, fontSize: 14),
      ),

      // 4. Card Theme (For your "How it works" or Product cards)
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // 5. Input Decoration (For the form fields in your screenshot)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardSurface, // Dark grey background
        hintStyle: const TextStyle(color: AppColors.greyText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // No border by default
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),

      // 6. Button Theme (The "Get Started" button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 5,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Rounded pill shape
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16,
          ),
        ),
      ),
      
      // 7. AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, // Modern look
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
    );
  }
}
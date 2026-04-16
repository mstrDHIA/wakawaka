import 'package:flutter/material.dart';

// Color constants from the Python app (gui.py)
const Color kBg = Color(0xFF0D0D1A);
const Color kSurface = Color(0xFF13132A);
const Color kCard = Color(0xFF1C1C38);
const Color kInputBg = Color(0xFF222244);
const Color kAccent = Color(0xFFC264FE);
const Color kText = Color(0xFFF0F0FF);
const Color kText2 = Color(0xFF6666AA);
const Color kSelBg = Color(0xFF3D1A6E);
const Color kTrack = Color(0xFF2A2A55);

// Status colors
const Color kStatusPlaying = Color(0xFF4CAF50);
const Color kStatusPaused = Color(0xFFFF9800);
const Color kStatusLoading = kAccent;
const Color kStatusError = Color(0xFFF44336);

ThemeData buildAppTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: kBg,
    colorScheme: ColorScheme.dark(
      primary: kAccent,
      secondary: kAccent,
      surface: kSurface,
      onSurface: kText,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: kAccent,
      inactiveTrackColor: kTrack,
      thumbColor: kAccent,
      overlayColor: WidgetStateColor.resolveWith(
        (states) => kAccent.withValues(alpha: 0.2),
      ),
      trackHeight: 6.0,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kInputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      hintStyle: const TextStyle(color: kText2),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: kCard,
      selectedTileColor: kSelBg,
      textColor: kText,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kAccent,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: kText,
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kInputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      menuStyle: const MenuStyle(
        backgroundColor: WidgetStatePropertyAll(kCard),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: kSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    cardTheme: CardThemeData(
      color: kCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

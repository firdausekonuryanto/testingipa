import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static ValueNotifier<List<Color>> gradientNotifier =
      ValueNotifier<List<Color>>(
          [secondary, const Color.fromRGBO(0, 89, 153, 1)]);

  // Warna primer - biru agak gelap
  static const Color primary = Color(0XFF097bc3);
  static const Color primaryLight = Color(0xFF155588);
  static const Color primaryDark = Color(0xFF003359);

  // Warna aksen/sekunder
  static const Color secondary = Color(0XFF4a9bd1);
  static const Color secondaryLight = Color(0xFF66b3e6);
  static const Color secondaryDark = Color(0xFF005999);
  static const Color checkIn = Color.fromARGB(255, 5, 110, 14);
  static const Color cameraFace = Color.fromARGB(255, 21, 255, 40);
  static const Color attendanceInArea = Color.fromARGB(255, 16, 185, 30);
  static const Color checkOut = Color.fromARGB(255, 153, 0, 0);
  static const Color myOrange = Color.fromARGB(255, 230, 104, 1);
  static const Color myLightYellow = Color(0xFFFFF3CD);
  static const Color myLightGreen = Color.fromARGB(255, 209, 255, 205);
  static const Color myLightRed = Color.fromARGB(255, 255, 205, 205);
  static const Color myYellow = Color(0xFFCC9A06);
  static const Color myPurple = Colors.purple;

  // Warna netral
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC3545);

  // Warna teks
  static const Color textPrimary = Color(0xFF24252A);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textLight = Color(0xFFFFFFFF);
}

class AppDimens {
  static double padding = 16.r;
  static double margin = 16.r;
  static double borderRadius = 8.r;
  static double radiusCircle = 50.r;

  //font size
  static double fontLarge = 20.sp;
  static double fontMedium = 16.sp;
  static double fontSmall = 14.sp;
  static double fontXS = 12.sp;

  static double fontXL = 22.sp;
  static double fontHeading = 18.sp;
  static double fontTitle = 16.sp;
  static double fontBody = 14.sp;
  static double fontCaption = 12.sp;
}

// Extension untuk mendapatkan TextTheme dengan font Poppins
extension PoppinsTextTheme on TextTheme {
  TextTheme get poppins {
    return copyWith(
      displayLarge: GoogleFonts.poppins(
        textStyle: displayLarge,
        fontWeight: FontWeight.w300,
      ),
      displayMedium: GoogleFonts.poppins(
        textStyle: displayMedium,
        fontWeight: FontWeight.w300,
      ),
      displaySmall: GoogleFonts.poppins(
        textStyle: displaySmall,
        fontWeight: FontWeight.normal,
      ),
      headlineLarge: GoogleFonts.poppins(
        textStyle: headlineLarge,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: headlineMedium,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: GoogleFonts.poppins(
        textStyle: headlineSmall,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: GoogleFonts.poppins(
        textStyle: titleLarge,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: GoogleFonts.poppins(
        textStyle: titleMedium,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: GoogleFonts.poppins(
        textStyle: titleSmall,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.poppins(
        textStyle: bodyLarge,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: GoogleFonts.poppins(
        textStyle: bodyMedium,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: GoogleFonts.poppins(
        textStyle: bodySmall,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: GoogleFonts.poppins(
        textStyle: labelLarge,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: GoogleFonts.poppins(
        textStyle: labelMedium,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.poppins(
        textStyle: labelSmall,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// Tema Terang
ThemeData lightTheme() {
  const ColorScheme colorScheme = ColorScheme(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondary,
    secondaryContainer: AppColors.secondaryLight,
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: AppColors.textLight,
    onSecondary: AppColors.textLight,
    onSurface: AppColors.textPrimary,
    onError: AppColors.textLight,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textLight,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),
    ),
    textTheme: const TextTheme().poppins,
  );
}

// Tema Gelap (opsional, jika dibutuhkan)
ThemeData darkTheme() {
  const ColorScheme colorScheme = ColorScheme(
    primary: Color.fromARGB(255, 110, 240, 84),
    primaryContainer: AppColors.primary,
    secondary: AppColors.secondaryLight,
    secondaryContainer: AppColors.secondary,
    surface: Color(0xFF212529),
    error: AppColors.myLightRed,
    onPrimary: AppColors.textLight,
    onSecondary: AppColors.textPrimary,
    onSurface: AppColors.textLight,
    onError: AppColors.textLight,
    brightness: Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: AppColors.textLight,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),
    ),
    textTheme: const TextTheme().poppins,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      hintStyle: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.textSecondary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.myLightRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.myLightRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}

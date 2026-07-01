import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {

  // ================= SPECIAL =================
  static final TextStyle welcomeText = GoogleFonts.caveat(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    color: AppColors.textDark,
  );

  // ================= HEADINGS =================
  static TextStyle heading = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static TextStyle subHeading = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // ================= BODY =================
  static TextStyle body = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static TextStyle bodyBold = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static TextStyle small = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  // ================= BUTTONS =================
  static TextStyle buttonWhite = GoogleFonts.poppins(
    fontSize: 16,
    color: AppColors.textLight,
    fontWeight: FontWeight.w500,
  );

  static TextStyle buttonDark = GoogleFonts.poppins(
    fontSize: 16,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );

  // ================= DRAWER =================
  static TextStyle drawerItem = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );
}

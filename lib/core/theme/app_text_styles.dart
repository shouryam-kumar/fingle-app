import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Heading Styles
  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
  );

  // Body Styles
  static TextStyle body1 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static TextStyle body2 = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
  );

  // Button Styles
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // App Bar Styles
  static TextStyle appBarTitle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  // Trending Topic Styles
  static TextStyle trendingTitle = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  // Story Styles
  static TextStyle storyName = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  // Post Card Styles
  static TextStyle postUserName = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static TextStyle postContent = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle postTimeAgo = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  static TextStyle postCategory = GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}

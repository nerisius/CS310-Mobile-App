import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Font families
  static const String primaryFont = 'Inter';
  static const String signatureFont = 'MomoSignature';

  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: primaryFont,
  );

  // Special styles
  static const TextStyle title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    fontFamily: primaryFont,
  );

  static const TextStyle label = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
    fontFamily: primaryFont,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: primaryFont,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: primaryFont,
  );

  // Stats specific
  static const TextStyle statValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: primaryFont,
  );

  static const TextStyle statChange = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: primaryFont,
  );

  // Book related
  static const TextStyle bookTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle bookAuthor = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: primaryFont,
  );
}

import 'package:flutter/material.dart';

class AppSpacing {
  // Padding values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Edge insets
  static const EdgeInsets screenPadding = EdgeInsets.all(20);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets smallPadding = EdgeInsets.all(8);
  static const EdgeInsets largePadding = EdgeInsets.all(24);

  // Spacing widgets (for backward compatibility)
  static const SizedBox fieldSpacing = SizedBox(height: 5);
  static const SizedBox buttonSpacing = SizedBox(height: 30);

  // Specific spacing
  static const SizedBox small = SizedBox(height: 8, width: 8);
  static const SizedBox medium = SizedBox(height: 16, width: 16);
  static const SizedBox large = SizedBox(height: 24, width: 24);
  static const SizedBox extraLarge = SizedBox(height: 32, width: 32);

  // Horizontal spacing
  static const SizedBox horizontalSmall = SizedBox(width: 8);
  static const SizedBox horizontalMedium = SizedBox(width: 16);
  static const SizedBox horizontalLarge = SizedBox(width: 24);

  // Vertical spacing
  static const SizedBox verticalSmall = SizedBox(height: 8);
  static const SizedBox verticalMedium = SizedBox(height: 16);
  static const SizedBox verticalLarge = SizedBox(height: 24);

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusCircular = 50.0;
}

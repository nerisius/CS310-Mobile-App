// utils/login_styling.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF4F4F4);
  static const primary = Color(0xFFFA6B24);
  static const textFieldBorder = Color(0xFFCCCCCC);
  static const Color accent = Colors.orange;
  static const Color inputFill = Color(0xFFF1F1F1);
}



class AppTextStyles {
  static const title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const label = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static const buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

class AppPaddings {
  static const screen = EdgeInsets.all(20);
  static const fieldSpacing = SizedBox(height: 5);
  static const buttonSpacing = SizedBox(height: 30);
}

import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  
  final Color brand;
  final Color warning;
  final Color success;

  const AppColors({
    required this.brand,
    required this.warning,
    required this.success,
  });

  static const light = AppColors(
    brand: Color(0xFF6750A4),
    warning: Color(0xFFBA1A1A),
    success: Color(0xFF1B873F),
  );

  static const dark = AppColors(
    brand: Color(0xFFD0BCFF),
    warning: Color(0xFFFFB4AB),
    success: Color(0xFF4CD061),
  );

   @override
   AppColors copyWith({Color? brand, Color? warning, Color? success}) {
     return AppColors(
       brand: brand ?? this.brand,
       warning: warning ?? this.warning,
       success: success ?? this.success,
     );
   }

   @override
    AppColors lerp(ThemeExtension<AppColors>? other, double t) {
      if (other is! AppColors) return this;
      return AppColors(
        brand: Color.lerp(brand, other.brand, t)!,
        warning: Color.lerp(warning, other.warning, t)!,
        success: Color.lerp(success, other.success, t)!,
      );
    }
}
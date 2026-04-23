import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF137FEC);
  static const Color primaryDark = Color(0xFF0E5EA9);
  static const Color primaryLight = Color(0xFF4FA3F5);
  static const Color accent = Color(0xFF00D4FF);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkBg = Color(0xFF0D1117); // alias
  static const Color darkCard = Color(0xFF161B22);
  static const Color darkCard2 = Color(0xFF1C2333);
  static const Color darkBorder = Color(0xFF30363D);
  static const Color darkText = Color(0xFFE6EDF3);
  static const Color darkSubText = Color(0xFF8B949E);

  // Light Theme
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightBg = Color(0xFFF5F7FA); // alias
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCard2 = Color(0xFFF0F4FF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightText = Color(0xFF1A202C);
  static const Color lightSubText = Color(0xFF718096);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF137FEC), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D1117), Color(0xFF161B22)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppStrings {
  static const String appName = 'Eletro';
  static const String dashboard = 'الرئيسية';
  static const String apartments = 'الشقق';
  static const String bills = 'الفواتير';
  static const String settings = 'الإعدادات';
  static const String activities = 'النشاطات';
  static const String readings = 'القراءات';

  // Bill Status
  static const String paid = 'مدفوع';
  static const String unpaid = 'غير مدفوع';
  static const String partial = 'جزئي';

  // Meter
  static const String mainMeter = 'العداد الرئيسي';
  static const String subMeter = 'العداد الفرعي';

  // Units
  static const String kwh = 'ك.و.س';
  static const String sar = 'ر.س';
}

class AppSizes {
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;

  static const double cardElevation = 0;
}

class AppRoutes {
  static const String biometric = '/biometric';
  static const String main = '/main';
  static const String home = '/home';
  static const String apartments = '/apartments';
  static const String billHistory = '/bill-history';
  static const String billDetail = '/bill-detail';
  static const String meterAssignment = '/meter-assignment';
  static const String activityLog = '/activity-log';
  static const String settings = '/settings';
}

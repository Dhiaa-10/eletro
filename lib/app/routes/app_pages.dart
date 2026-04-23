import 'package:get/get.dart';
import '../views/screens/biometric_screen.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/apartments_screen.dart';
import '../views/screens/bill_history_screen.dart';
import '../views/screens/bill_detail_screen.dart';
import '../views/screens/meter_assignment_screen.dart';
import '../views/screens/activity_log_screen.dart';
import '../views/screens/settings_screen.dart';
import '../utils/constants.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.biometric,
      page: () => const BiometricScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.apartments,
      page: () => const ApartmentsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.billHistory,
      page: () => const BillHistoryScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.billDetail,
      page: () => const BillDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.meterAssignment,
      page: () => const MeterAssignmentScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.activityLog,
      page: () => const ActivityLogScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}

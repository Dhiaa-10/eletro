import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/controllers/app_controller.dart';
import 'app/controllers/auth_controller.dart';
import 'app/controllers/home_controller.dart';
import 'app/controllers/apartment_controller.dart';
import 'app/controllers/bill_controller.dart';
import 'app/controllers/settings_controller.dart';
import 'app/controllers/activity_controller.dart';
import 'app/data/database/database_helper.dart';
import 'app/utils/constants.dart';
import 'app/themes/app_theme.dart';
import 'app/views/screens/biometric_screen.dart';
import 'app/views/screens/main_screen.dart';
import 'app/views/screens/apartments_screen.dart';
import 'app/views/screens/bill_history_screen.dart';
import 'app/views/screens/bill_detail_screen.dart';
import 'app/views/screens/meter_assignment_screen.dart';
import 'app/views/screens/activity_log_screen.dart';
import 'app/views/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await DatabaseHelper.instance.database;

  runApp(const EletroApp());
}

class EletroApp extends StatelessWidget {
  const EletroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Eletro',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),
      textDirection: TextDirection.rtl,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialBinding: BindingsBuilder(() {
        Get.put(AppController(), permanent: true);
        Get.put(SettingsController(), permanent: true);
        Get.put(AuthController(), permanent: true);
        Get.put(ApartmentController(), permanent: true);
        Get.put(BillController(), permanent: true);
        Get.put(HomeController(), permanent: true);
        Get.put(ActivityController(), permanent: true);
      }),
      initialRoute: AppRoutes.biometric,
      getPages: [
        GetPage(name: AppRoutes.biometric, page: () => const BiometricScreen()),
        GetPage(name: AppRoutes.main, page: () => const MainScreen()),
        GetPage(
            name: AppRoutes.apartments, page: () => const ApartmentsScreen()),
        GetPage(
            name: AppRoutes.billHistory, page: () => const BillHistoryScreen()),
        GetPage(
            name: AppRoutes.billDetail, page: () => const BillDetailScreen()),
        GetPage(
            name: AppRoutes.meterAssignment,
            page: () => const MeterAssignmentScreen()),
        GetPage(
            name: AppRoutes.activityLog, page: () => const ActivityLogScreen()),
        GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
      ],
    );
  }
}

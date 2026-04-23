import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../screens/home_screen.dart';
import '../screens/apartments_screen.dart';
import '../screens/bill_history_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/custom_bottom_nav.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();

    return Obx(() {
      final idx = appCtrl.navIndex;
      return Scaffold(
        body: IndexedStack(
          index: idx,
          children: const [
            HomeScreen(),
            ApartmentsScreen(isEmbedded: true),
            BillHistoryScreen(isEmbedded: true),
            SettingsScreen(isEmbedded: true),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: idx,
          onTap: appCtrl.setNavIndex,
        ),
      );
    });
  }
}

import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/apartment_controller.dart';
import '../controllers/bill_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/activity_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.put(ApartmentController(), permanent: true);
    Get.put(BillController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
    Get.put(ActivityController(), permanent: true);
  }
}

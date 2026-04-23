import 'package:get/get.dart';
import '../data/database/database_helper.dart';

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  final _unitPrice = 0.18.obs;
  final _subscriptionFee = 50.0.obs;
  final _buildingName = 'برج الغروب'.obs;
  final _biometricEnabled = false.obs;
  final _mainMeter1 = 0.0.obs;
  final _mainMeter2 = 0.0.obs;
  final _isLoading = false.obs;

  double get unitPrice => _unitPrice.value;
  double get subscriptionFee => _subscriptionFee.value;
  String get buildingName => _buildingName.value;
  bool get biometricEnabled => _biometricEnabled.value;
  double get mainMeter1 => _mainMeter1.value;
  double get mainMeter2 => _mainMeter2.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading.value = true;
    final db = DatabaseHelper.instance;
    _unitPrice.value =
        double.tryParse(await db.getSetting('unit_price') ?? '0.18') ?? 0.18;
    _subscriptionFee.value =
        double.tryParse(await db.getSetting('subscription_fee') ?? '50') ??
            50.0;
    _buildingName.value = await db.getSetting('building_name') ?? 'برج الغروب';
    _biometricEnabled.value =
        (await db.getSetting('biometric_enabled')) == 'true';
    _mainMeter1.value =
        double.tryParse(await db.getSetting('main_meter_1_reading') ?? '0') ??
            0;
    _mainMeter2.value =
        double.tryParse(await db.getSetting('main_meter_2_reading') ?? '0') ??
            0;
    _isLoading.value = false;
  }

  Future<void> saveUnitPrice(double val) async {
    _unitPrice.value = val;
    await DatabaseHelper.instance.setSetting('unit_price', val.toString());
    Get.snackbar('نجح', 'تم حفظ سعر الوحدة',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> saveSubscriptionFee(double val) async {
    _subscriptionFee.value = val;
    await DatabaseHelper.instance
        .setSetting('subscription_fee', val.toString());
    Get.snackbar('نجح', 'تم حفظ رسوم الاشتراك',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> saveBuildingName(String name) async {
    _buildingName.value = name;
    await DatabaseHelper.instance.setSetting('building_name', name);
    Get.snackbar('نجح', 'تم حفظ اسم المبنى',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> saveMainMeter1(double val) async {
    _mainMeter1.value = val;
    await DatabaseHelper.instance
        .setSetting('main_meter_1_reading', val.toString());
  }

  Future<void> saveMainMeter2(double val) async {
    _mainMeter2.value = val;
    await DatabaseHelper.instance
        .setSetting('main_meter_2_reading', val.toString());
  }

  Future<void> toggleBiometric(bool val) async {
    _biometricEnabled.value = val;
    await DatabaseHelper.instance
        .setSetting('biometric_enabled', val.toString());
  }

  double calculateBill(double consumption) {
    return (consumption * _unitPrice.value) + _subscriptionFee.value;
  }
}

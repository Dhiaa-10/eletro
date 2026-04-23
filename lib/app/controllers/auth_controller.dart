import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../data/database/database_helper.dart';
import '../utils/constants.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final LocalAuthentication _auth = LocalAuthentication();
  final _isAuthenticated = false.obs;
  final _biometricEnabled = false.obs;
  final _canCheckBiometrics = false.obs;
  final _authError = ''.obs;
  final _isAuthenticating = false.obs;

  bool get isAuthenticated => _isAuthenticated.value;
  bool get biometricEnabled => _biometricEnabled.value;
  bool get canCheckBiometrics => _canCheckBiometrics.value;
  String get authError => _authError.value;
  bool get isAuthenticating => _isAuthenticating.value;

  @override
  void onInit() {
    super.onInit();
    _checkCapabilities();
    _loadSettings();
  }

  Future<void> _checkCapabilities() async {
    try {
      _canCheckBiometrics.value = await _auth.canCheckBiometrics;
    } catch (e) {
      _canCheckBiometrics.value = false;
    }
  }

  Future<void> _loadSettings() async {
    final val = await DatabaseHelper.instance.getSetting('biometric_enabled');
    _biometricEnabled.value = val == 'true';
  }

  Future<bool> authenticate() async {
    if (!_biometricEnabled.value || !_canCheckBiometrics.value) {
      _isAuthenticated.value = true;
      return true;
    }
    _isAuthenticating.value = true;
    _authError.value = '';
    try {
      final result = await _auth.authenticate(
        localizedReason: 'قم بمسح بصمتك للدخول إلى Eletro',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      _isAuthenticated.value = result;
      if (!result) _authError.value = 'فشل التحقق. حاول مرة أخرى.';
      return result;
    } catch (e) {
      _authError.value = 'حدث خطأ أثناء التحقق';
      _isAuthenticated.value = false;
      return false;
    } finally {
      _isAuthenticating.value = false;
    }
  }

  void skipAuth() {
    _isAuthenticated.value = true;
    Get.offAllNamed(AppRoutes.main);
  }

  Future<void> toggleBiometric(bool value) async {
    _biometricEnabled.value = value;
    await DatabaseHelper.instance
        .setSetting('biometric_enabled', value.toString());
  }
}

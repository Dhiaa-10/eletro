import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database/database_helper.dart';

class AppController extends GetxController {
  static AppController get to => Get.find();

  final _isDark = false.obs;
  final _buildingName = 'برج الغروب'.obs;
  final _isLoading = false.obs;
  final _navIndex = 0.obs;

  bool get isDark => _isDark.value;
  String get buildingName => _buildingName.value;
  bool get isLoading => _isLoading.value;
  int get navIndex => _navIndex.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark.value = prefs.getBool('dark_mode') ?? false;
    final name = await DatabaseHelper.instance.getSetting('building_name');
    if (name != null) _buildingName.value = name;
    // Apply saved theme
    Get.changeThemeMode(_isDark.value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    _isDark.value = !_isDark.value;
    Get.changeThemeMode(_isDark.value ? ThemeMode.dark : ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDark.value);
    await DatabaseHelper.instance
        .setSetting('dark_mode', _isDark.value.toString());
  }

  void setNavIndex(int i) => _navIndex.value = i;

  Future<void> updateBuildingName(String name) async {
    _buildingName.value = name;
    await DatabaseHelper.instance.setSetting('building_name', name);
  }
}

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../data/database/database_helper.dart';
import '../utils/constants.dart';
import '../bindings/initial_binding.dart';

class BackupService {
  static Future<void> exportDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'eletro.db');
      final dbFile = File(path);

      if (await dbFile.exists()) {
        final tempDir = await getTemporaryDirectory();
        final timestamp =
            DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
        final backupPath = join(tempDir.path, 'Eletro_Backup_$timestamp.db');

        final backupFile = await dbFile.copy(backupPath);

        await Share.shareXFiles(
          [XFile(backupFile.path)],
          text: 'النسخة الاحتياطية لبيانات تطبيق Eletro',
        );
      } else {
        Get.snackbar('خطأ', 'لم يتم العثور على قاعدة البيانات',
            backgroundColor: AppColors.danger, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تصدير البيانات: $e',
          backgroundColor: AppColors.danger, colorText: Colors.white);
    }
  }

  static Future<void> importDatabase() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final importPath = result.files.single.path!;
        if (!importPath.endsWith('.db') && !importPath.endsWith('.sqlite')) {
          Get.snackbar('خطأ', 'يرجى اختيار ملف قاعدة بيانات صالح (.db)',
              backgroundColor: AppColors.danger, colorText: Colors.white);
          return;
        }

        // Close current DB
        await DatabaseHelper.instance.close();

        final dbPath = await getDatabasesPath();
        final path = join(dbPath, 'eletro.db');
        final currentFile = File(path);

        final importedFile = File(importPath);
        await importedFile.copy(currentFile.path);

        Get.snackbar(
          'نجاح',
          'تم استعادة النسخة الاحتياطية بنجاح!',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        // Re-init controllers
        Get.deleteAll(force: true);
        InitialBinding().dependencies();
        Get.offAllNamed(AppRoutes.biometric);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل استيراد البيانات: $e',
          backgroundColor: AppColors.danger, colorText: Colors.white);
    }
  }
}

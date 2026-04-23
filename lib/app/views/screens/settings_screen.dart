import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/app_controller.dart';
import '../../../app/controllers/auth_controller.dart';
import '../../../app/controllers/settings_controller.dart';
import '../../../app/services/backup_service.dart';
import '../../../app/utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  final bool isEmbedded;
  const SettingsScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final sCtrl = Get.find<SettingsController>();
    final appCtrl = Get.find<AppController>();
    final authCtrl = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors matching Stitch dark mode settings.png
    final bgColor =
        isDark ? const Color(0xFF0D1117) : AppColors.lightBackground;
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white54 : Colors.black54;
    // The Stitch settings screen uses red for icons/toggles, but we'll use primary for brand consistency
    // or danger if we want to match exactly. Let's use primary (Blue) but shape matching exactly.
    final accentColor =
        AppColors.danger; // Using red to match the Stitch settings.png exactly

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('إعدادات النظام والأمان',
            style: TextStyle(
                color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !isEmbedded,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Obx(() => sCtrl.isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _SectionTitle(title: 'الأمان والحماية', color: subTextColor),
                _SectionCard(
                  color: cardColor,
                  children: [
                    _SettingItem(
                      title: 'تفعيل قفل التطبيق',
                      subtitle: 'حماية التطبيق عند الخروج',
                      icon: Icons.lock_outline,
                      iconColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: CupertinoSwitch(
                        value: true,
                        activeColor: accentColor,
                        onChanged: (v) {},
                      ),
                    ),
                    _Divider(color: isDark ? Colors.white12 : Colors.black12),
                    _SettingItem(
                      title: 'استخدام البصمة / الوجه',
                      subtitle: 'الدخول السريع والآمن',
                      icon: Icons.fingerprint,
                      iconColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: CupertinoSwitch(
                        value: authCtrl.biometricEnabled,
                        activeColor: accentColor,
                        onChanged: authCtrl.canCheckBiometrics
                            ? authCtrl.toggleBiometric
                            : null,
                      ),
                    ),
                    _Divider(color: isDark ? Colors.white12 : Colors.black12),
                    _SettingItem(
                      title: 'تغيير رمز المرور',
                      subtitle: 'تحديث كلمة مرور الدخول',
                      icon: Icons.password,
                      iconColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: Icon(Icons.chevron_left,
                          color: subTextColor, size: 20),
                      onTap: () {}, // Placeholder
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: 'التخصيص', color: subTextColor),
                _SectionCard(
                  color: cardColor,
                  children: [
                    _SettingItem(
                      title: 'اللغة',
                      subtitle: 'العربية',
                      icon: Icons.language,
                      iconColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: CupertinoSwitch(
                        value: true,
                        activeColor: accentColor,
                        onChanged: (v) {},
                      ),
                    ),
                    _Divider(color: isDark ? Colors.white12 : Colors.black12),
                    _SettingItem(
                      title: 'المظهر',
                      subtitle: appCtrl.isDark ? 'داكن' : 'فاتح',
                      icon: appCtrl.isDark ? Icons.dark_mode : Icons.light_mode,
                      iconColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: CupertinoSwitch(
                        value: appCtrl.isDark,
                        activeColor: accentColor,
                        onChanged: (v) => appCtrl.toggleTheme(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: 'تعرفة الكهرباء', color: subTextColor),
                _SectionCard(
                  color: cardColor,
                  children: [
                    _SettingItem(
                      title: 'سعر الكيلوواط',
                      subtitle: 'القيمة بالريال السعودي',
                      icon: Icons.electric_bolt,
                      iconColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: Text('${sCtrl.unitPrice} ر.س',
                          style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      onTap: () => _editNumeric(sCtrl.unitPrice,
                          sCtrl.saveUnitPrice, 'سعر الكيلوواط', accentColor),
                    ),
                    _Divider(color: isDark ? Colors.white12 : Colors.black12),
                    _SettingItem(
                      title: 'رسوم الاشتراك الثابتة',
                      subtitle: 'تضاف لكل فاتورة',
                      icon: Icons.receipt_long,
                      iconColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: Text('${sCtrl.subscriptionFee} ر.س',
                          style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      onTap: () => _editNumeric(
                          sCtrl.subscriptionFee,
                          sCtrl.saveSubscriptionFee,
                          'رسوم الاشتراك',
                          accentColor),
                    ),
                    _Divider(color: isDark ? Colors.white12 : Colors.black12),
                    _SettingItem(
                      title: 'نوع دورة الفاتورة',
                      icon: Icons.calendar_today,
                      iconColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('شهري',
                              style:
                                  TextStyle(color: subTextColor, fontSize: 14)),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_left,
                              color: subTextColor, size: 20),
                        ],
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: 'إدارة العدادات', color: subTextColor),
                _SectionCard(
                  color: cardColor,
                  children: [
                    _SettingItem(
                      title: 'تكوين العداد الرئيسي',
                      subtitle: 'تحديد العدادات الفرعية التابعة',
                      icon: Icons.hub,
                      iconColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: Icon(Icons.chevron_left,
                          color: subTextColor, size: 20),
                      onTap: () => Get.toNamed(AppRoutes.meterAssignment),
                    ),
                    _Divider(color: isDark ? Colors.white12 : Colors.black12),
                    _SettingItem(
                      title: 'ربط العداد الذكي',
                      subtitle: 'قراءة تلقائية للاستهلاك',
                      icon: Icons.smart_button,
                      iconColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: CupertinoSwitch(
                        value: false,
                        activeColor: accentColor,
                        onChanged: (v) {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: 'النسخ الاحتياطي', color: subTextColor),
                _SectionCard(
                  color: cardColor,
                  children: [
                    _SettingItem(
                      title: 'تصدير نسخة احتياطية',
                      subtitle: 'حفظ البيانات محلياً أو سحابياً',
                      icon: Icons.cloud_upload_outlined,
                      iconColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: Icon(Icons.chevron_left,
                          color: subTextColor, size: 20),
                      onTap: BackupService.exportDatabase,
                    ),
                    _Divider(color: isDark ? Colors.white12 : Colors.black12),
                    _SettingItem(
                      title: 'استيراد نسخة احتياطية',
                      subtitle: 'استعادة البيانات من ملف سابق',
                      icon: Icons.cloud_download_outlined,
                      iconColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      trailing: Icon(Icons.chevron_left,
                          color: subTextColor, size: 20),
                      onTap: BackupService.importDatabase,
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            )),
    );
  }

  void _editNumeric(
      double value, Function(double) onSave, String label, Color accent) {
    final ctrl = TextEditingController(text: value.toString());
    Get.defaultDialog(
      title: label,
      content: TextField(controller: ctrl, keyboardType: TextInputType.number),
      textConfirm: 'حفظ',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: accent,
      cancelTextColor: accent,
      onConfirm: () {
        Get.back();
        final v = double.tryParse(ctrl.text);
        if (v != null) onSave(v);
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 8),
      child: Text(
        title,
        style:
            TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Color color;
  final List<Widget> children;
  const _SectionCard({required this.color, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: color, indent: 64);
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color textColor;
  final Color subTextColor;

  const _SettingItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.trailing,
    this.onTap,
    required this.iconColor,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: TextStyle(color: subTextColor, fontSize: 12)),
                  ]
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

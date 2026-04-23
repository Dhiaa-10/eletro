import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../app/controllers/apartment_controller.dart';
import '../../../app/data/models/apartment_model.dart';
import '../../../app/data/models/meter_model.dart';
import '../../../app/utils/constants.dart';

class MeterAssignmentScreen extends StatelessWidget {
  const MeterAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ApartmentController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('تخصيص العدادات الفرعية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMeterDialog(context, ctrl),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        return RefreshIndicator(
          onRefresh: ctrl.loadData,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Unassigned meters
              if (ctrl.unassignedMeters.isNotEmpty) ...[
                Text('عدادات غير مخصصة',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.warning)),
                const SizedBox(height: 8),
                ...ctrl.unassignedMeters.map((m) =>
                    _MeterChip(meter: m, isDark: isDark)
                        .animate()
                        .fadeIn(duration: 300.ms)),
                const SizedBox(height: 16),
              ],
              Text('قائمة الشقق والعدادات',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...ctrl.apartments.asMap().entries.map(
                    (e) => _ApartmentMeterRow(
                      apartment: e.value,
                      ctrl: ctrl,
                      isDark: isDark,
                    )
                        .animate()
                        .slideX(
                            begin: 0.15,
                            delay: (e.key * 50).ms,
                            duration: 300.ms,
                            curve: Curves.easeOut)
                        .fadeIn(delay: (e.key * 50).ms),
                  ),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  void _showAddMeterDialog(BuildContext ctx, ApartmentController ctrl) {
    final numCtrl = TextEditingController();
    Get.defaultDialog(
      title: 'إضافة عداد جديد',
      content: TextField(
        controller: numCtrl,
        decoration: const InputDecoration(labelText: 'رقم العداد *'),
      ),
      textConfirm: 'إضافة',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        if (numCtrl.text.trim().isEmpty) return;
        ctrl.addMeter(MeterModel(
          meterNumber: numCtrl.text.trim(),
          type: 'sub',
          createdAt: DateTime.now().toIso8601String(),
        ));
      },
    );
  }
}

class _MeterChip extends StatelessWidget {
  final MeterModel meter;
  final bool isDark;
  const _MeterChip({required this.meter, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.electric_meter, color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          Text(meter.meterNumber,
              style: Theme.of(context).textTheme.titleSmall),
          const Spacer(),
          Text('${meter.currentReading.toStringAsFixed(0)} ك.و.س',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ApartmentMeterRow extends StatelessWidget {
  final ApartmentModel apartment;
  final ApartmentController ctrl;
  final bool isDark;

  const _ApartmentMeterRow(
      {required this.apartment, required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final hasMeter = apartment.meterNumber != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: hasMeter
              ? AppColors.success.withOpacity(0.3)
              : AppColors.danger.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (hasMeter ? AppColors.success : AppColors.danger)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasMeter ? Icons.electric_meter : Icons.electric_meter_outlined,
              color: hasMeter ? AppColors.success : AppColors.danger,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'شقة ${apartment.number} - ${apartment.tenantName ?? 'فارغة'}',
                    style: Theme.of(context).textTheme.titleSmall),
                Text(
                  hasMeter
                      ? 'عداد: ${apartment.meterNumber} · ${apartment.currentReading?.toStringAsFixed(0) ?? 0} ك.و.س'
                      : 'لا يوجد عداد مخصص',
                  style: TextStyle(
                    fontSize: 11,
                    color: hasMeter ? AppColors.success : AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (val) {
              if (val == 'unassign') {
                ctrl.assignMeter(apartment.id!, null);
              } else {
                final meterId = int.tryParse(val);
                if (meterId != null) ctrl.assignMeter(apartment.id!, meterId);
              }
            },
            itemBuilder: (_) => [
              if (hasMeter)
                const PopupMenuItem(
                    value: 'unassign', child: Text('إلغاء التخصيص')),
              ...ctrl.unassignedMeters.map((m) => PopupMenuItem(
                    value: m.id.toString(),
                    child: Text('تعيين: ${m.meterNumber}'),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

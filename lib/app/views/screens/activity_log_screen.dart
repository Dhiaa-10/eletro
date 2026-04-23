import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/controllers/activity_controller.dart';
import '../../../app/utils/constants.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ActivityController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('سجل النشاطات والعمليات'),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FilterChip(label: 'الكل', value: 'all', ctrl: ctrl),
                _FilterChip(label: 'المدفوعات', value: 'payment', ctrl: ctrl),
                _FilterChip(label: 'الفواتير', value: 'bill', ctrl: ctrl),
                _FilterChip(label: 'القراءات', value: 'reading', ctrl: ctrl),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (ctrl.activities.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history,
                          size: 64,
                          color: isDark
                              ? AppColors.darkSubText
                              : AppColors.lightSubText),
                      const SizedBox(height: 12),
                      const Text('لا توجد نشاطات بعد'),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: ctrl.loadActivities,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ctrl.activities.length,
                  itemBuilder: (ctx, i) {
                    final act = ctrl.activities[i];
                    return _ActivityCard(activity: act, isDark: isDark)
                        .animate()
                        .slideX(
                            begin: 0.1,
                            delay: (i * 40).ms,
                            duration: 280.ms,
                            curve: Curves.easeOut)
                        .fadeIn(delay: (i * 40).ms);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, value;
  final ActivityController ctrl;

  const _FilterChip(
      {required this.label, required this.value, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = ctrl.filterType == value;
      return GestureDetector(
        onTap: () => ctrl.setFilter(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.darkBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSubText
                      : AppColors.lightSubText),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      );
    });
  }
}

class _ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  final bool isDark;

  const _ActivityCard({required this.activity, required this.isDark});

  Color _getColor(String type) {
    switch (type) {
      case 'payment':
        return AppColors.success;
      case 'bill':
        return AppColors.primary;
      case 'reading':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payments_outlined;
      case 'bill':
        return Icons.receipt_long;
      case 'reading':
        return Icons.electric_meter;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = activity['type'] as String;
    final color = _getColor(type);
    final timestamp = activity['timestamp'] as String? ?? '';
    DateTime? dt;
    try {
      dt = DateTime.parse(timestamp);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(type), color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['description'] as String? ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dt != null)
                  Text(
                    DateFormat('d MMM yyyy - hh:mm a', 'ar').format(dt),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ),
          if (activity['amount'] != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(activity['amount'] as num).toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../app/controllers/bill_controller.dart';
import '../../../app/data/models/bill_model.dart';
import '../../../app/utils/constants.dart';

class BillDetailScreen extends StatelessWidget {
  const BillDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BillController>();
    final bill = Get.arguments as BillModel? ?? ctrl.selectedBill;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (bill == null) {
      return Scaffold(
          appBar: AppBar(), body: const Center(child: Text('لا توجد بيانات')));
    }

    Color statusColor;
    String statusLabel;
    switch (bill.status) {
      case 'paid':
        statusColor = AppColors.success;
        statusLabel = 'مدفوع بالكامل';
        break;
      case 'partial':
        statusColor = AppColors.warning;
        statusLabel = 'دفع جزئي';
        break;
      default:
        statusColor = AppColors.danger;
        statusLabel = 'غير مدفوع';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('تفاصيل الفاتورة'),
        actions: [
          if (bill.status != 'paid')
            TextButton.icon(
              onPressed: () => _showPaymentDialog(context, ctrl, bill),
              icon: const Icon(Icons.payment, color: Colors.white),
              label: const Text('تسجيل دفعة',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [statusColor.withOpacity(0.8), statusColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Column(
          children: [
            // Status Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withOpacity(0.15),
                    statusColor.withOpacity(0.05)
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(_statusIcon(bill.status), color: statusColor, size: 48)
                      .animate()
                      .scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 12),
                  Text(statusLabel,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(bill.cycleLabel,
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                      'شقة ${bill.apartmentNumber ?? ''} - ${bill.tenantName ?? ''}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 16),

            // Financial Summary
            _SectionCard(
              title: 'الملخص المالي',
              isDark: isDark,
              children: [
                _DetailRow(
                    label: 'القراءة السابقة',
                    value: '${bill.prevReading.toStringAsFixed(0)} ك.و.س'),
                _DetailRow(
                    label: 'القراءة الحالية',
                    value: '${bill.currReading.toStringAsFixed(0)} ك.و.س'),
                _DetailRow(
                    label: 'الاستهلاك',
                    value: '${bill.consumption.toStringAsFixed(0)} ك.و.س',
                    highlight: true),
                const Divider(),
                _DetailRow(
                    label: 'سعر الوحدة', value: '${bill.unitPrice} ر.س/ك.و.س'),
                _DetailRow(
                    label: 'قيمة الاستهلاك',
                    value:
                        '${(bill.consumption * bill.unitPrice).toStringAsFixed(2)} ر.س'),
                _DetailRow(
                    label: 'رسوم الاشتراك',
                    value: '${bill.subscriptionFee.toStringAsFixed(2)} ر.س'),
                if (bill.prevBalance > 0)
                  _DetailRow(
                      label: 'رصيد سابق',
                      value: '${bill.prevBalance.toStringAsFixed(2)} ر.س',
                      isDebt: true),
                const Divider(),
                _DetailRow(
                    label: 'الإجمالي',
                    value: '${bill.total.toStringAsFixed(2)} ر.س',
                    isBold: true),
              ],
            )
                .animate()
                .slideY(
                    begin: 0.1,
                    delay: 100.ms,
                    duration: 400.ms,
                    curve: Curves.easeOut)
                .fadeIn(delay: 100.ms),
            const SizedBox(height: 16),

            // Payment Progress
            _SectionCard(
              title: 'حالة الدفع',
              isDark: isDark,
              children: [
                _DetailRow(
                    label: 'المدفوع',
                    value: '${bill.paidAmount.toStringAsFixed(2)} ر.س',
                    isPositive: true),
                _DetailRow(
                    label: 'المتبقي',
                    value: '${bill.remaining.toStringAsFixed(2)} ر.س',
                    isDebt: bill.remaining > 0),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  tween: Tween(
                      begin: 0,
                      end: bill.total > 0
                          ? (bill.paidAmount / bill.total).clamp(0.0, 1.0)
                          : 0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (_, val, __) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('نسبة السداد',
                              style: Theme.of(context).textTheme.labelSmall),
                          Text('${(val * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: val,
                          backgroundColor: isDark
                              ? AppColors.darkCard2
                              : AppColors.lightCard2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(statusColor),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
                .animate()
                .slideY(
                    begin: 0.1,
                    delay: 200.ms,
                    duration: 400.ms,
                    curve: Curves.easeOut)
                .fadeIn(delay: 200.ms),

            const SizedBox(height: 24),
            if (bill.status != 'paid')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showPaymentDialog(context, ctrl, bill),
                  icon: const Icon(Icons.payment),
                  label: const Text('تسجيل دفعة'),
                ).animate().slideY(begin: 0.2, delay: 300.ms, duration: 400.ms),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'paid':
        return Icons.check_circle;
      case 'partial':
        return Icons.timelapse;
      default:
        return Icons.error_outline;
    }
  }

  void _showPaymentDialog(
      BuildContext ctx, BillController ctrl, BillModel bill) {
    final amtCtrl =
        TextEditingController(text: bill.remaining.toStringAsFixed(2));
    Get.defaultDialog(
      title: 'تسجيل دفعة',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('المتبقي: ${bill.remaining.toStringAsFixed(2)} ر.س',
              style: const TextStyle(fontSize: 14, color: AppColors.danger)),
          const SizedBox(height: 12),
          TextField(
            controller: amtCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'المبلغ المستلم',
              suffixText: 'ر.س',
            ),
          ),
        ],
      ),
      textConfirm: 'تسجيل',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.success,
      onConfirm: () {
        final amount = double.tryParse(amtCtrl.text) ?? 0;
        if (amount > 0) ctrl.recordPayment(bill.id!, amount);
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;

  const _SectionCard(
      {required this.title, required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final bool highlight, isBold, isDebt, isPositive;

  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.isBold = false,
    this.isDebt = false,
    this.isPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color valColor = isDark ? AppColors.darkText : AppColors.lightText;
    if (isDebt) valColor = AppColors.danger;
    if (isPositive) valColor = AppColors.success;
    if (highlight) valColor = AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                    color: valColor,
                  )),
        ],
      ),
    );
  }
}

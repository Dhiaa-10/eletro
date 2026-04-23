import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/controllers/bill_controller.dart';
import '../../../app/controllers/home_controller.dart';
import '../../../app/controllers/settings_controller.dart';
import '../../../app/data/models/apartment_model.dart';
import '../../../app/data/models/bill_model.dart';
import '../../../app/utils/constants.dart';

class BillHistoryScreen extends StatefulWidget {
  final bool isEmbedded;
  const BillHistoryScreen({super.key, this.isEmbedded = false});

  @override
  State<BillHistoryScreen> createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {
  String selectedFilter = 'الكل';
  final filters = ['الكل', 'غير مدفوع', 'مدفوع جزئياً', 'مدفوع'];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BillController>();
    final apartment = Get.arguments as ApartmentModel?;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeCtrl = Get.find<HomeController>();

    final bgColor =
        isDark ? const Color(0xFF0D1117) : AppColors.lightBackground;
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white54 : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('سجل فواتير الشقة', style: TextStyle(fontSize: 14)),
            if (apartment != null) ...[
              const SizedBox(height: 4),
              Text('شقة ${apartment.number}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text('الدور ${apartment.floor} - ${homeCtrl.buildingName}',
                  style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black54)),
            ]
          ],
        ),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(color: textColor),
      ),
      floatingActionButton: apartment != null
          ? FloatingActionButton(
              onPressed: () => _showAddBillDialog(context, ctrl, apartment),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Obx(() {
        if (ctrl.isLoading)
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));

        // Compute Stats
        double total = 0, paid = 0, remaining = 0;
        for (var b in ctrl.bills) {
          total += b.total;
          paid += b.paidAmount;
          remaining += b.remaining;
        }

        // Apply filters
        final filteredBills = ctrl.bills.where((b) {
          if (selectedFilter == 'الكل') return true;
          if (selectedFilter == 'مدفوع') return b.status == 'paid';
          if (selectedFilter == 'مدفوع جزئياً') return b.status == 'partial';
          if (selectedFilter == 'غير مدفوع') return b.status == 'unpaid';
          return true;
        }).toList();

        return Column(
          children: [
            // Top Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                      child: _buildStatBox('الإجمالي', total, textColor,
                          subTextColor, cardColor, isDark)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildStatBox(
                          'المدفوع',
                          paid,
                          Colors.green,
                          Colors.green.withValues(alpha: 0.7),
                          cardColor,
                          isDark)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildStatBox(
                          'المتبقي',
                          remaining,
                          AppColors.danger,
                          AppColors.danger.withValues(alpha: 0.7),
                          cardColor,
                          isDark)),
                ],
              ),
            ),

            // Segmented Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: filters
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: InkWell(
                            onTap: () => setState(() => selectedFilter = f),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selectedFilter == f
                                    ? AppColors.primary
                                    : (isDark ? cardColor : Colors.white),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: selectedFilter == f
                                        ? AppColors.primary
                                        : (isDark
                                            ? Colors.white12
                                            : Colors.grey[300]!)),
                              ),
                              child: Text(f,
                                  style: TextStyle(
                                    color: selectedFilter == f
                                        ? Colors.white
                                        : textColor,
                                    fontSize: 13,
                                    fontWeight: selectedFilter == f
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  )),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // List of Bills
            Expanded(
              child: filteredBills.isEmpty
                  ? Center(
                      child: Text('لا توجد فواتير',
                          style: TextStyle(color: subTextColor)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredBills.length,
                      itemBuilder: (ctx, i) => _buildDetailBillCard(
                          filteredBills[i],
                          cardColor,
                          textColor,
                          subTextColor,
                          isDark),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatBox(String title, double value, Color mainColor,
      Color titleColor, Color cardColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark
                ? (mainColor == Colors.white
                    ? Colors.white12
                    : mainColor.withValues(alpha: 0.3))
                : (mainColor == Colors.black
                    ? Colors.grey[300]!
                    : mainColor.withValues(alpha: 0.3))),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: titleColor, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value.toStringAsFixed(0),
                  style: TextStyle(
                      color: mainColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text('ر.س', style: TextStyle(color: titleColor, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBillCard(BillModel bill, Color cardColor, Color textColor,
      Color subTextColor, bool isDark) {
    Color statusColor;
    String statusText;
    Color iconBgColor;

    switch (bill.status) {
      case 'paid':
        statusColor = Colors.green;
        statusText = 'مدفوع بالكامل';
        iconBgColor = Colors.green.withValues(alpha: 0.1);
        break;
      case 'partial':
        statusColor = Colors.orange;
        statusText = 'مدفوع جزئياً';
        iconBgColor = Colors.orange.withValues(alpha: 0.1);
        break;
      default:
        statusColor = AppColors.danger;
        statusText = 'غير مدفوع';
        iconBgColor = AppColors.danger.withValues(alpha: 0.1);
        break;
    }

    final dateStr =
        DateFormat('dd MMMM yyyy', 'ar').format(DateTime.parse(bill.cycleDate));

    return InkWell(
      onTap: () {
        Get.find<BillController>().selectBill(bill);
        Get.toNamed(AppRoutes.billDetail, arguments: bill);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            // Right thick border indicator (RTL so Right is logically right)
            Container(
                width: 4,
                height: 160,
                decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Top Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: iconBgColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Icon(
                              bill.status == 'paid'
                                  ? Icons.check_circle
                                  : Icons.receipt_long,
                              color: statusColor,
                              size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bill.cycleLabel,
                                  style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(dateStr,
                                  style: TextStyle(
                                      color: subTextColor, fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: iconBgColor,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(statusText,
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('القراءة السابقة',
                                style: TextStyle(
                                    color: subTextColor, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text('${bill.prevReading.toInt()}',
                                style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ],
                        )),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الاستهلاك',
                                style: TextStyle(
                                    color: subTextColor, fontSize: 11)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${bill.consumption.toInt()}',
                                    style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(width: 4),
                                Text('ك.و.س',
                                    style: TextStyle(
                                        color: subTextColor, fontSize: 10)),
                              ],
                            ),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(
                        height: 1,
                        color: isDark ? Colors.white12 : Colors.grey[200]),
                    const SizedBox(height: 16),
                    // Bottom Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('التفاصيل',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_left,
                                color: AppColors.primary, size: 16),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                bill.status == 'paid'
                                    ? 'قيمة الفاتورة'
                                    : 'المبلغ المتبقي',
                                style: TextStyle(
                                    color: subTextColor, fontSize: 10)),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    bill.status == 'paid'
                                        ? bill.total.toStringAsFixed(0)
                                        : bill.remaining.toStringAsFixed(0),
                                    style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(width: 4),
                                Text('ر.س',
                                    style: TextStyle(
                                        color: statusColor, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBillDialog(
      BuildContext ctx, BillController bCtrl, ApartmentModel apt) {
    // simplified for brevity...
    final sCtrl = Get.find<SettingsController>();
    final prevCtrl = TextEditingController();
    final currCtrl = TextEditingController();

    // Pre-fill prev reading
    Get.find<BillController>().bills.isNotEmpty
        ? prevCtrl.text = bCtrl.bills.first.currReading.toStringAsFixed(0)
        : null;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
            color: Theme.of(ctx).cardColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('فاتورة جديدة - شقة ${apt.number}',
                style: Theme.of(ctx).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
                controller: prevCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'القراءة السابقة', suffixText: 'ك.و.س')),
            const SizedBox(height: 12),
            TextField(
                controller: currCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'القراءة الحالية', suffixText: 'ك.و.س')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final prev = double.tryParse(prevCtrl.text) ?? 0;
                  final curr = double.tryParse(currCtrl.text) ?? 0;
                  if (curr <= prev) {
                    Get.snackbar(
                        'خطأ', 'القراءة الحالية يجب أن تكون أكبر من السابقة',
                        snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  final consumption = curr - prev;
                  final total = sCtrl.calculateBill(consumption);
                  final now = DateTime.now();
                  final monthNames = [
                    '',
                    'يناير',
                    'فبراير',
                    'مارس',
                    'أبريل',
                    'مايو',
                    'يونيو',
                    'يوليو',
                    'أغسطس',
                    'سبتمبر',
                    'أكتوبر',
                    'نوفمبر',
                    'ديسمبر'
                  ];
                  final cycleLabel =
                      '${monthNames[now.month]} ${now.year} - ${now.day <= 15 ? 'الدورة الأولى' : 'الدورة الثانية'}';

                  bCtrl.addBill(BillModel(
                      apartmentId: apt.id!,
                      cycleLabel: cycleLabel,
                      cycleDate: now.toIso8601String(),
                      prevReading: prev,
                      currReading: curr,
                      consumption: consumption,
                      unitPrice: sCtrl.unitPrice,
                      subscriptionFee: sCtrl.subscriptionFee,
                      prevBalance: 0,
                      total: total,
                      paidAmount: 0,
                      status: 'unpaid',
                      createdAt: now.toIso8601String(),
                      apartmentNumber: apt.number,
                      tenantName: apt.tenantName));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                child: const Text('إنشاء الفاتورة'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

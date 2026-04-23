import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/controllers/apartment_controller.dart';
import '../../../app/controllers/home_controller.dart';
import '../../../app/data/models/apartment_model.dart';
import '../../../app/utils/constants.dart';
import '../../../app/controllers/app_controller.dart';

class ApartmentsScreen extends StatefulWidget {
  final bool isEmbedded;
  const ApartmentsScreen({super.key, this.isEmbedded = false});

  @override
  State<ApartmentsScreen> createState() => _ApartmentsScreenState();
}

class _ApartmentsScreenState extends State<ApartmentsScreen> {
  String selectedFilter = 'الكل';
  final filters = ['الكل', 'مدفوع', 'دفع جزئي', 'غير مدفوع'];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ApartmentController>();
    final homeCtrl = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        isDark ? const Color(0xFF0D1117) : AppColors.lightBackground;
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white54 : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Obx(
          () => ctrl.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : RefreshIndicator(
                  onRefresh: ctrl.loadData,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('قائمة الشقق',
                                    style: TextStyle(
                                        color: textColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                Text('حالة الدفع والوحدات السكنية',
                                    style: TextStyle(
                                        color: subTextColor, fontSize: 13)),
                              ],
                            ),
                            InkWell(
                              onTap: () =>
                                  _showAddApartmentDialog(context, ctrl),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle),
                                child:
                                    const Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    isDark ? Colors.white12 : Colors.black12),
                          ),
                          child: TextField(
                            onChanged: ctrl.setSearch,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'بحث عن شقة او مستأجر...',
                              hintStyle: TextStyle(color: subTextColor),
                              border: InputBorder.none,
                              icon: Icon(Icons.search, color: subTextColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: filters
                                .map((f) => Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: InkWell(
                                        onTap: () =>
                                            setState(() => selectedFilter = f),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: selectedFilter == f
                                                ? AppColors.danger
                                                : (isDark
                                                    ? Colors.white
                                                        .withValues(alpha: 0.05)
                                                    : Colors.grey[200]),
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                        const SizedBox(height: 24),

                        // Stats Cards Row
                        Row(
                          children: [
                            Expanded(
                                child: _buildCollectionCard(
                              title: 'تحصيلات الشهر',
                              value: '${homeCtrl.totalCollections.toInt()}',
                              icon: Icons.payments_outlined,
                              color: Colors.green,
                              progress: homeCtrl.totalCollections /
                                  (homeCtrl.totalCollections +
                                              homeCtrl.totalArrears ==
                                          0
                                      ? 1
                                      : homeCtrl.totalCollections +
                                          homeCtrl.totalArrears),
                              cardColor: cardColor,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              isDark: isDark,
                            )),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildCollectionCard(
                              title: 'المتأخرات',
                              value: '${homeCtrl.totalArrears.toInt()}',
                              icon: Icons.warning_amber_rounded,
                              color: AppColors.danger,
                              progress: homeCtrl.totalArrears /
                                  (homeCtrl.totalCollections +
                                              homeCtrl.totalArrears ==
                                          0
                                      ? 1
                                      : homeCtrl.totalCollections +
                                          homeCtrl.totalArrears),
                              cardColor: cardColor,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              isDark: isDark,
                            )),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Apartment List Grouped By Floor
                        ..._buildGroupedApartments(ctrl, homeCtrl, cardColor,
                            textColor, subTextColor, isDark),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCollectionCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color,
      required double progress,
      required Color cardColor,
      required Color textColor,
      required Color subTextColor,
      required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: subTextColor, fontSize: 12)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text('رس', style: TextStyle(color: subTextColor, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.isNaN ? 0 : progress,
            backgroundColor: isDark ? Colors.white12 : Colors.black12,
            color: color,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedApartments(
      ApartmentController ctrl,
      HomeController homeCtrl,
      Color cardColor,
      Color textColor,
      Color subTextColor,
      bool isDark) {
    // 1. Enrich apartments with status
    final enriched = ctrl.apartments.map((a) {
      String status = 'جديد';
      double remaining = 0.0;
      if (a.isVacant) {
        status = 'فارغة';
      } else {
        final bill = homeCtrl.recentBills.firstWhereOrNull((b) =>
            b.apartmentId == a.id && b.cycleLabel == homeCtrl.cycleLabel);
        if (bill != null) {
          if (bill.status == 'paid')
            status = 'مدفوع بالكامل';
          else if (bill.status == 'partial') {
            status = 'دفع جزئي';
            remaining = bill.remaining;
          } else {
            status = 'غير مدفوع';
            remaining = bill.remaining;
          }
        }
      }
      return {'apt': a, 'status': status, 'remaining': remaining};
    }).toList();

    // 2. Filter
    final filtered = enriched.where((item) {
      if (selectedFilter == 'الكل') return true;
      if (selectedFilter == 'مدفوع') return item['status'] == 'مدفوع بالكامل';
      if (selectedFilter == 'دفع جزئي') return item['status'] == 'دفع جزئي';
      if (selectedFilter == 'غير مدفوع') return item['status'] == 'غير مدفوع';
      return true;
    }).toList();

    // 3. Group by floor
    final grouped = <int, List<Map<String, dynamic>>>{};
    for (var item in filtered) {
      final apt = item['apt'] as ApartmentModel;
      grouped.putIfAbsent(apt.floor, () => []).add(item);
    }

    // 4. Build UI
    final floors = grouped.keys.toList()..sort();
    final widgets = <Widget>[];

    for (var floor in floors) {
      final floorName = floor == 1
          ? 'الطابق الأول'
          : (floor == 2 ? 'الطابق الثاني' : 'الطابق $floor');

      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
                child: Container(
                    height: 1,
                    color: isDark ? Colors.white12 : Colors.black12)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(floorName,
                  style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
            Expanded(
                child: Container(
                    height: 1,
                    color: isDark ? Colors.white12 : Colors.black12)),
          ],
        ),
      ));

      for (var item in grouped[floor]!) {
        final apt = item['apt'] as ApartmentModel;
        final status = item['status'] as String;
        final remaining = item['remaining'] as double;

        Color statusColor;
        IconData? icon;
        String bottomText;
        bool isVacant = apt.isVacant;

        switch (status) {
          case 'مدفوع بالكامل':
            statusColor = Colors.green;
            icon = Icons.calendar_today;
            bottomText = DateFormat('dd MMM').format(DateTime.now());
            break;
          case 'دفع جزئي':
            statusColor = Colors.orange;
            bottomText = 'باقي $remaining ر.س';
            break;
          case 'غير مدفوع':
            statusColor = AppColors.danger;
            icon = Icons.warning_amber_rounded;
            bottomText = 'متأخر';
            break;
          case 'فارغة':
            statusColor = Colors.grey;
            icon = Icons.key;
            bottomText = 'شقة للإيجار';
            break;
          default:
            statusColor = Colors.grey;
            bottomText = '-';
        }

        widgets.add(Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: statusColor.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(apt.number,
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  isVacant
                                      ? '-'
                                      : (apt.tenantName ?? 'بدون اسم'),
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color:
                                          statusColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(status,
                                    style: TextStyle(
                                        color: statusColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (icon != null) ...[
                              Icon(icon, color: subTextColor, size: 14),
                              const SizedBox(width: 4),
                            ],
                            Text(bottomText,
                                style: TextStyle(
                                    color: subTextColor, fontSize: 12)),
                          ],
                        ),
                        if (status == 'غير مدفوع')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text('دفع',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          )
                        else if (status == 'دفع جزئي')
                          SizedBox(
                            width: 80,
                            child: LinearProgressIndicator(
                                value: 0.5,
                                color: Colors.orange,
                                backgroundColor:
                                    isDark ? Colors.white12 : Colors.black12),
                          )
                        else if (status == 'مدفوع بالكامل')
                          Text('0.00 SAR',
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))
                        else
                          Text('--',
                              style: TextStyle(
                                  color: subTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Icon(Icons.more_vert, color: subTextColor, size: 20),
                ),
              ],
            ),
          ),
        ));
      }
    }

    if (widgets.isEmpty) {
      widgets.add(Center(
          child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('لا توجد نتائج',
                  style: TextStyle(color: subTextColor)))));
    }

    return widgets;
  }

  void _showAddApartmentDialog(BuildContext context, ApartmentController ctrl) {
    // simplified for brevity
    Get.snackbar('متوفر قريباً', 'نافذة الإضافة ستفتح هنا');
  }
}

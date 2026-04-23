import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/controllers/home_controller.dart';
import '../../../app/utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
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
                        _buildHeader(ctrl, isDark, textColor, subTextColor),
                        const SizedBox(height: 24),

                        // Cycle Selector
                        _buildCycleSelector(ctrl, textColor, subTextColor),
                        const SizedBox(height: 20),

                        // Main Meter Cards
                        _buildMeterCards(ctrl),
                        const SizedBox(height: 12),

                        // Carousel Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.3),
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                    color: AppColors.primaryDark,
                                    shape: BoxShape.circle)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Payment Progress
                        _buildPaymentProgress(
                            ctrl, cardColor, textColor, subTextColor, isDark),
                        const SizedBox(height: 16),

                        // Stats Cards Row
                        Row(
                          children: [
                            Expanded(
                                child: _buildStatCard(
                                    title: 'استهلاك الخدمات',
                                    value:
                                        '${ctrl.totalConsumption.toInt()} ك.و.س',
                                    icon: Icons.bolt,
                                    iconBg: Colors.green.withValues(alpha: 0.1),
                                    iconColor: Colors.green,
                                    footer: Row(children: [
                                      Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle)),
                                      const SizedBox(width: 4),
                                      Text('المعدل الطبيعي',
                                          style: TextStyle(
                                              color: subTextColor,
                                              fontSize: 10))
                                    ]),
                                    cardColor: cardColor,
                                    textColor: textColor,
                                    isDark: isDark)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildStatCard(
                                    title: 'حالة إدخال القراءات',
                                    value:
                                        '${ctrl.paidCount} / ${ctrl.totalApartments}',
                                    icon: Icons.speed,
                                    iconBg: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    iconColor: AppColors.primary,
                                    footer: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${(ctrl.paidCount / (ctrl.totalApartments == 0 ? 1 : ctrl.totalApartments) * 100).toInt()}%',
                                            style: TextStyle(
                                                color: subTextColor,
                                                fontSize: 10)),
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: ctrl.totalApartments == 0
                                              ? 0
                                              : ctrl.paidCount /
                                                  ctrl.totalApartments,
                                          backgroundColor: isDark
                                              ? Colors.white12
                                              : Colors.black12,
                                          color: AppColors.primaryDark,
                                          minHeight: 4,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ],
                                    ),
                                    cardColor: cardColor,
                                    textColor: textColor,
                                    isDark: isDark)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Actionable Apartments
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('شقق تحتاج إجراء',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            Text('عرض الكل',
                                style: TextStyle(
                                    color: subTextColor, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...ctrl.recentBills
                            .where((b) => b.status == 'unpaid')
                            .take(3)
                            .map((b) => _buildActionCard(
                                  title:
                                      'شقة ${b.apartmentNumber} - ${b.tenantName ?? "بدون اسم"}',
                                  subtitle: 'لم يتم السداد',
                                  subtitleColor: AppColors.danger,
                                  badge: b.apartmentNumber ?? '-',
                                  cardColor: cardColor,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                  isDark: isDark,
                                  onTap: () => Get.toNamed(AppRoutes.billDetail,
                                      arguments: b),
                                )),
                        if (ctrl.recentBills
                            .where((b) => b.status == 'unpaid')
                            .isEmpty)
                          Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text('لا توجد شقق تحتاج إجراء',
                                      style: TextStyle(color: subTextColor)))),

                        const SizedBox(height: 24),

                        // Recent Activity
                        Text('تم إكمالها مؤخراً',
                            style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...ctrl.recentBills
                            .where((b) => b.status == 'paid')
                            .take(2)
                            .map((b) => _buildDoneCard(
                                title:
                                    'شقة ${b.apartmentNumber} - ${b.tenantName ?? "بدون اسم"}',
                                subtitle:
                                    'تم السداد ${DateFormat('اليوم hh:mm a').format(DateTime.parse(b.createdAt))}',
                                cardColor: cardColor,
                                textColor: textColor,
                                subTextColor: subTextColor,
                                isDark: isDark)),
                        if (ctrl.recentBills
                            .where((b) => b.status == 'paid')
                            .isEmpty)
                          Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text('لا توجد نشاطات مكتملة مؤخراً',
                                      style: TextStyle(color: subTextColor)))),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      HomeController ctrl, bool isDark, Color textColor, Color subTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.notifications_none, color: textColor),
        Column(
          children: [
            Text(ctrl.buildingName,
                style: TextStyle(color: subTextColor, fontSize: 12)),
            Row(
              children: [
                Text('لوحة التحكم',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: textColor, size: 16),
              ],
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.domain, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildCycleSelector(
      HomeController ctrl, Color textColor, Color subTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.chevron_right, color: subTextColor),
        Column(
          children: [
            Text(ctrl.cycleLabel.split(' - ').first,
                style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            Text(ctrl.cycleLabel.split(' - ').last,
                style: TextStyle(color: subTextColor, fontSize: 11)),
          ],
        ),
        Icon(Icons.chevron_left, color: subTextColor),
      ],
    );
  }

  Widget _buildMeterCards(HomeController ctrl) {
    return SizedBox(
      height: 130,
      child: PageView(
        children: [
          _MeterCard(
              title: 'العداد الرئيسي (1)',
              reading: ctrl.mainMeter1,
              date: '1 نوفمبر 2023'),
        ],
      ),
    );
  }

  Widget _buildPaymentProgress(HomeController ctrl, Color cardColor,
      Color textColor, Color subTextColor, bool isDark) {
    final paidP = ctrl.totalApartments == 0
        ? 0.0
        : (ctrl.paidCount / ctrl.totalApartments);
    final percent = (paidP * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12)),
                child: Text('الدورة الحالية',
                    style: TextStyle(color: subTextColor, fontSize: 10)),
              ),
              Text('متابعة السداد',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Circular Chart
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      color: isDark ? Colors.white12 : Colors.grey[200],
                    ),
                    CircularProgressIndicator(
                      value: paidP,
                      strokeWidth: 8,
                      color: Colors.green,
                      strokeCap: StrokeCap.round,
                    ),
                    Text('$percent%',
                        style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('تم السداد',
                                style: TextStyle(
                                    color: subTextColor, fontSize: 12)),
                          ],
                        ),
                        Text('${ctrl.paidCount}',
                            style: TextStyle(
                                color: textColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.grey[300],
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('لم يتم السداد',
                                style: TextStyle(
                                    color: subTextColor, fontSize: 12)),
                          ],
                        ),
                        Text('${ctrl.unpaidCount}',
                            style: TextStyle(
                                color: textColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('المبلغ المحصل',
                            style:
                                TextStyle(color: subTextColor, fontSize: 12)),
                        Text('${ctrl.totalCollections.toStringAsFixed(0)} ر.س',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color iconBg,
      required Color iconColor,
      required Widget footer,
      required Color cardColor,
      required Color textColor,
      required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value,
              style: TextStyle(
                  color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 12),
          footer,
        ],
      ),
    );
  }

  Widget _buildActionCard(
      {required String title,
      required String subtitle,
      required Color subtitleColor,
      required String badge,
      required Color cardColor,
      required Color textColor,
      required Color subTextColor,
      required bool isDark,
      VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1117) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8)),
              child: Text(badge,
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(color: subtitleColor, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: subTextColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDoneCard(
      {required String title,
      required String subtitle,
      required Color cardColor,
      required Color textColor,
      required Color subTextColor,
      required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.green, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: subTextColor, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeterCard extends StatelessWidget {
  final String title;
  final double reading;
  final String date;

  const _MeterCard(
      {required this.title, required this.reading, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1368C4), // Match exact tone from dashboard.png
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1368C4).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Stack(
        children: [
          // Background graphic
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.bolt,
                size: 120, color: Colors.white.withValues(alpha: 0.1)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.electric_meter,
                        color: Colors.white, size: 20),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(reading.toStringAsFixed(2),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Inter')),
                  const SizedBox(width: 4),
                  const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text('رس',
                          style: TextStyle(color: Colors.white, fontSize: 14))),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(date,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('نشط',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

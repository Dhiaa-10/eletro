import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/models/apartment_model.dart';
import '../../../app/utils/constants.dart';
import '../../../app/controllers/bill_controller.dart';

class ApartmentStatusCard extends StatelessWidget {
  final ApartmentModel apartment;

  const ApartmentStatusCard({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVacant = apartment.isVacant;

    return GestureDetector(
      onTap: () {
        if (!isVacant) {
          Get.find<BillController>().loadBillsForApartment(apartment.id!);
          Get.toNamed(AppRoutes.billHistory, arguments: apartment);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isVacant
                    ? AppColors.darkSubText.withOpacity(0.15)
                    : AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  apartment.number,
                  style: TextStyle(
                    color: isVacant ? AppColors.darkSubText : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVacant ? 'فارغة' : (apartment.tenantName ?? 'بلا مستأجر'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'الدور ${apartment.floor} · ${apartment.meterNumber ?? 'بلا عداد'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (!isVacant)
              const Icon(Icons.chevron_left,
                  color: AppColors.darkSubText, size: 20),
          ],
        ),
      ),
    );
  }
}

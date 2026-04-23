import 'package:get/get.dart';
import '../data/database/database_helper.dart';
import '../data/models/bill_model.dart';

class BillController extends GetxController {
  static BillController get to => Get.find();

  final _bills = <BillModel>[].obs;
  final _isLoading = false.obs;
  final _selectedBill = Rxn<BillModel>();
  int? _currentApartmentId;

  List<BillModel> get bills => _bills;
  bool get isLoading => _isLoading.value;
  BillModel? get selectedBill => _selectedBill.value;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadBillsForApartment(int apartmentId) async {
    _currentApartmentId = apartmentId;
    _isLoading.value = true;
    try {
      final data = await DatabaseHelper.instance.rawQuery('''
        SELECT b.*, a.number as apartment_number, a.tenant_name
        FROM bills b
        LEFT JOIN apartments a ON b.apartment_id = a.id
        WHERE b.apartment_id = ?
        ORDER BY b.cycle_date DESC
      ''', [apartmentId]);
      _bills.value = data.map((e) => BillModel.fromMap(e)).toList();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadAllBills() async {
    _isLoading.value = true;
    try {
      final data = await DatabaseHelper.instance.rawQuery('''
        SELECT b.*, a.number as apartment_number, a.tenant_name
        FROM bills b
        LEFT JOIN apartments a ON b.apartment_id = a.id
        ORDER BY b.created_at DESC
      ''');
      _bills.value = data.map((e) => BillModel.fromMap(e)).toList();
    } finally {
      _isLoading.value = false;
    }
  }

  void selectBill(BillModel bill) => _selectedBill.value = bill;

  Future<void> addBill(BillModel bill) async {
    final id = await DatabaseHelper.instance.insert('bills', bill.toMap());
    // Update meter reading
    final apt = await DatabaseHelper.instance
        .query('apartments', where: 'id = ?', whereArgs: [bill.apartmentId]);
    if (apt.isNotEmpty && apt.first['meter_id'] != null) {
      await DatabaseHelper.instance.update(
          'meters',
          {'current_reading': bill.currReading},
          'id = ?',
          [apt.first['meter_id']]);
    }
    await _logActivity(
        'bill',
        'تم إنشاء فاتورة ${bill.cycleLabel} - ${bill.apartmentNumber ?? ''}',
        bill.total,
        id);
    if (_currentApartmentId != null) {
      await loadBillsForApartment(_currentApartmentId!);
    }
    Get.back();
    Get.snackbar('نجح', 'تم إنشاء الفاتورة بنجاح',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> recordPayment(int billId, double amount) async {
    final bill = _bills.firstWhereOrNull((b) => b.id == billId);
    if (bill == null) return;
    final newPaid = bill.paidAmount + amount;
    final newStatus = newPaid >= bill.total ? 'paid' : 'partial';
    await DatabaseHelper.instance.update(
        'bills',
        {
          'paid_amount': newPaid,
          'status': newStatus,
        },
        'id = ?',
        [billId]);
    await _logActivity(
        'payment',
        'تم استلام دفعة من ${bill.apartmentNumber ?? ''} - ${bill.tenantName ?? ''}',
        amount,
        billId);
    _selectedBill.value = bill.copyWith(paidAmount: newPaid, status: newStatus);
    if (_currentApartmentId != null) {
      await loadBillsForApartment(_currentApartmentId!);
    } else {
      await loadAllBills();
    }
    Get.back();
    Get.snackbar('نجح', 'تم تسجيل الدفعة بنجاح',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> deleteBill(int billId) async {
    await DatabaseHelper.instance.delete('bills', 'id = ?', [billId]);
    if (_currentApartmentId != null) {
      await loadBillsForApartment(_currentApartmentId!);
    }
    Get.snackbar('تم', 'تم حذف الفاتورة', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _logActivity(
      String type, String desc, double? amount, int relatedId) async {
    await DatabaseHelper.instance.insert('activities', {
      'type': type,
      'description': desc,
      'amount': amount,
      'related_id': relatedId,
      'icon': type == 'payment' ? 'payments' : 'receipt_long',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}

import 'package:get/get.dart';
import '../data/database/database_helper.dart';
import '../data/models/apartment_model.dart';
import '../data/models/meter_model.dart';

class ApartmentController extends GetxController {
  static ApartmentController get to => Get.find();

  final _apartments = <ApartmentModel>[].obs;
  final _meters = <MeterModel>[].obs;
  final _isLoading = false.obs;
  final _searchQuery = ''.obs;

  List<ApartmentModel> get apartments => _searchQuery.value.isEmpty
      ? _apartments
      : _apartments
          .where((a) =>
              (a.tenantName ?? '').contains(_searchQuery.value) ||
              a.number.contains(_searchQuery.value))
          .toList();
  List<MeterModel> get meters => _meters;
  bool get isLoading => _isLoading.value;
  List<MeterModel> get unassignedMeters =>
      _meters.where((m) => m.apartmentId == null).toList();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    _isLoading.value = true;
    try {
      await Future.wait([_loadApartments(), _loadMeters()]);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadApartments() async {
    final data = await DatabaseHelper.instance.rawQuery('''
      SELECT a.*, m.meter_number, m.current_reading
      FROM apartments a
      LEFT JOIN meters m ON a.meter_id = m.id
      ORDER BY a.floor, a.number
    ''');
    _apartments.value = data.map((e) => ApartmentModel.fromMap(e)).toList();
  }

  Future<void> _loadMeters() async {
    final data =
        await DatabaseHelper.instance.query('meters', orderBy: 'meter_number');
    _meters.value = data.map((e) => MeterModel.fromMap(e)).toList();
  }

  void setSearch(String q) => _searchQuery.value = q;

  Future<void> addApartment(ApartmentModel apt) async {
    final id = await DatabaseHelper.instance.insert('apartments', apt.toMap());
    await _logActivity('apartment', 'تمت إضافة شقة ${apt.number}', null, id);
    await loadData();
    Get.back();
    Get.snackbar('نجح', 'تمت إضافة الشقة بنجاح',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> updateApartment(ApartmentModel apt) async {
    await DatabaseHelper.instance
        .update('apartments', apt.toMap(), 'id = ?', [apt.id]);
    await loadData();
    Get.back();
    Get.snackbar('نجح', 'تم تحديث بيانات الشقة',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> deleteApartment(int id) async {
    await DatabaseHelper.instance.delete('apartments', 'id = ?', [id]);
    await loadData();
    Get.snackbar('تم', 'تم حذف الشقة', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> addMeter(MeterModel meter) async {
    await DatabaseHelper.instance.insert('meters', meter.toMap());
    await loadData();
    Get.back();
    Get.snackbar('نجح', 'تمت إضافة العداد بنجاح',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> assignMeter(int apartmentId, int? meterId) async {
    // Unassign old meter
    final apt = _apartments.firstWhereOrNull((a) => a.id == apartmentId);
    if (apt?.meterId != null) {
      await DatabaseHelper.instance
          .update('meters', {'apartment_id': null}, 'id = ?', [apt!.meterId]);
    }
    // Assign new meter
    if (meterId != null) {
      await DatabaseHelper.instance
          .update('meters', {'apartment_id': apartmentId}, 'id = ?', [meterId]);
    }
    // Update apartment
    await DatabaseHelper.instance
        .update('apartments', {'meter_id': meterId}, 'id = ?', [apartmentId]);
    await loadData();
    Get.snackbar('نجح', 'تم تعيين العداد بنجاح',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _logActivity(
      String type, String desc, double? amount, int relatedId) async {
    await DatabaseHelper.instance.insert('activities', {
      'type': type,
      'description': desc,
      'amount': amount,
      'related_id': relatedId,
      'icon': 'apartment',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}

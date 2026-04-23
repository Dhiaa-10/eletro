import 'package:get/get.dart';
import '../data/database/database_helper.dart';

class ActivityController extends GetxController {
  final _activities = <Map<String, dynamic>>[].obs;
  final _isLoading = false.obs;
  final _filterType = 'all'.obs;

  List<Map<String, dynamic>> get activities => _filterType.value == 'all'
      ? _activities
      : _activities.where((a) => a['type'] == _filterType.value).toList();

  bool get isLoading => _isLoading.value;
  String get filterType => _filterType.value;

  @override
  void onInit() {
    super.onInit();
    loadActivities();
  }

  Future<void> loadActivities() async {
    _isLoading.value = true;
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'activities',
        orderBy: 'timestamp DESC',
        limit: 200,
      );
      _activities.value = result;
    } catch (e) {
      // ignore
    } finally {
      _isLoading.value = false;
    }
  }

  void setFilter(String type) {
    _filterType.value = type;
  }

  Future<void> logActivity({
    required String type,
    required String description,
    double? amount,
    int? referenceId,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('activities', {
        'type': type,
        'description': description,
        'amount': amount,
        'reference_id': referenceId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      loadActivities();
    } catch (e) {
      // ignore
    }
  }
}

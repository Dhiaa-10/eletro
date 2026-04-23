import 'package:get/get.dart';
import '../data/database/database_helper.dart';
import '../data/models/apartment_model.dart';
import '../data/models/bill_model.dart';
import '../data/models/activity_model.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  final _currentIndex = 0.obs;
  final _apartments = <ApartmentModel>[].obs;
  final _recentBills = <BillModel>[].obs;
  final _recentActivities = <ActivityModel>[].obs;
  final _isLoading = true.obs;

  // Stats
  final _totalApartments = 0.obs;
  final _paidCount = 0.obs;
  final _unpaidCount = 0.obs;
  final _partialCount = 0.obs;
  final _totalCollections = 0.0.obs;
  final _totalArrears = 0.0.obs;
  final _totalConsumption = 0.0.obs;
  final _mainMeter1 = 0.0.obs;
  final _mainMeter2 = 0.0.obs;
  final _cycleLabel = ''.obs;
  final _buildingName = 'برج الغروب'.obs;

  int get currentIndex => _currentIndex.value;
  List<ApartmentModel> get apartments => _apartments;
  List<BillModel> get recentBills => _recentBills;
  List<ActivityModel> get recentActivities => _recentActivities;
  bool get isLoading => _isLoading.value;
  int get totalApartments => _totalApartments.value;
  int get paidCount => _paidCount.value;
  int get unpaidCount => _unpaidCount.value;
  int get partialCount => _partialCount.value;
  double get totalCollections => _totalCollections.value;
  double get totalArrears => _totalArrears.value;
  double get totalConsumption => _totalConsumption.value;
  double get mainMeter1 => _mainMeter1.value;
  double get mainMeter2 => _mainMeter2.value;
  String get cycleLabel => _cycleLabel.value;
  String get buildingName => _buildingName.value;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void setIndex(int i) => _currentIndex.value = i;

  Future<void> loadData() async {
    _isLoading.value = true;
    try {
      await Future.wait([
        _loadApartments(),
        _loadBills(),
        _loadActivities(),
        _loadSettings(),
      ]);
      _computeStats();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadApartments() async {
    final data = await DatabaseHelper.instance.rawQuery('''
      SELECT a.*, m.meter_number, m.current_reading
      FROM apartments a
      LEFT JOIN meters m ON a.meter_id = m.id
      ORDER BY a.number
    ''');
    _apartments.value = data.map((e) => ApartmentModel.fromMap(e)).toList();
  }

  Future<void> _loadBills() async {
    final data = await DatabaseHelper.instance.rawQuery('''
      SELECT b.*, a.number as apartment_number, a.tenant_name
      FROM bills b
      LEFT JOIN apartments a ON b.apartment_id = a.id
      ORDER BY b.created_at DESC
      LIMIT 20
    ''');
    _recentBills.value = data.map((e) => BillModel.fromMap(e)).toList();
  }

  Future<void> _loadActivities() async {
    final data = await DatabaseHelper.instance
        .query('activities', orderBy: 'timestamp DESC', limit: 10);
    _recentActivities.value =
        data.map((e) => ActivityModel.fromMap(e)).toList();
  }

  Future<void> _loadSettings() async {
    final db = DatabaseHelper.instance;
    final m1 = await db.getSetting('main_meter_1_reading');
    final m2 = await db.getSetting('main_meter_2_reading');
    final name = await db.getSetting('building_name');
    _mainMeter1.value = double.tryParse(m1 ?? '0') ?? 0;
    _mainMeter2.value = double.tryParse(m2 ?? '0') ?? 0;
    if (name != null) _buildingName.value = name;
    _cycleLabel.value = _getCurrentCycleLabel();
  }

  String _getCurrentCycleLabel() {
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
    final half = now.day <= 15 ? 'الدورة الأولى' : 'الدورة الثانية';
    return '${monthNames[now.month]} ${now.year} - $half';
  }

  void _computeStats() {
    _totalApartments.value = _apartments.length;
    // Get current cycle bills
    final currentBills =
        _recentBills.where((b) => b.cycleLabel == _cycleLabel.value).toList();
    _paidCount.value = currentBills.where((b) => b.status == 'paid').length;
    _unpaidCount.value = currentBills.where((b) => b.status == 'unpaid').length;
    _partialCount.value =
        currentBills.where((b) => b.status == 'partial').length;
    _totalCollections.value =
        currentBills.fold(0.0, (sum, b) => sum + b.paidAmount);
    _totalArrears.value = currentBills.fold(0.0, (sum, b) => sum + b.remaining);
    _totalConsumption.value =
        currentBills.fold(0.0, (sum, b) => sum + b.consumption);
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('eletro.db');
    return _database!;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Meters table
    await db.execute('''
      CREATE TABLE meters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meter_number TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'sub',
        current_reading REAL NOT NULL DEFAULT 0,
        apartment_id INTEGER,
        created_at TEXT NOT NULL
      )
    ''');

    // Apartments table
    await db.execute('''
      CREATE TABLE apartments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT NOT NULL,
        floor INTEGER NOT NULL DEFAULT 1,
        tenant_name TEXT,
        tenant_phone TEXT,
        meter_id INTEGER,
        is_vacant INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (meter_id) REFERENCES meters(id)
      )
    ''');

    // Bills table
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        apartment_id INTEGER NOT NULL,
        cycle_label TEXT NOT NULL,
        cycle_date TEXT NOT NULL,
        prev_reading REAL NOT NULL DEFAULT 0,
        curr_reading REAL NOT NULL DEFAULT 0,
        consumption REAL NOT NULL DEFAULT 0,
        unit_price REAL NOT NULL DEFAULT 0,
        subscription_fee REAL NOT NULL DEFAULT 0,
        prev_balance REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL DEFAULT 0,
        paid_amount REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'unpaid',
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (apartment_id) REFERENCES apartments(id)
      )
    ''');

    // Activities table
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL,
        related_id INTEGER,
        icon TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL
      )
    ''');

    // Insert default settings
    await db.insert('app_settings', {'key': 'unit_price', 'value': '0.18'});
    await db.insert('app_settings', {
      'key': 'subscription_fee',
      'value': '50.0',
    });
    await db.insert('app_settings', {
      'key': 'building_name',
      'value': 'برج الغروب',
    });
    await db.insert('app_settings', {'key': 'cycle_type', 'value': 'monthly'});
    await db.insert('app_settings', {
      'key': 'main_meter_1_reading',
      'value': '0',
    });
    await db.insert('app_settings', {
      'key': 'main_meter_2_reading',
      'value': '0',
    });
    await db.insert('app_settings', {
      'key': 'biometric_enabled',
      'value': 'false',
    });
    await db.insert('app_settings', {'key': 'dark_mode', 'value': 'true'});

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Insert sample meters
    final meter1Id = await db.insert('meters', {
      'meter_number': 'M-101',
      'type': 'sub',
      'current_reading': 12750,
      'apartment_id': null,
      'created_at': now,
    });
    final meter2Id = await db.insert('meters', {
      'meter_number': 'M-102',
      'type': 'sub',
      'current_reading': 8900,
      'apartment_id': null,
      'created_at': now,
    });
    final meter3Id = await db.insert('meters', {
      'meter_number': 'M-103',
      'type': 'sub',
      'current_reading': 15200,
      'apartment_id': null,
      'created_at': now,
    });
    final meter4Id = await db.insert('meters', {
      'meter_number': 'M-104',
      'type': 'sub',
      'current_reading': 5430,
      'apartment_id': null,
      'created_at': now,
    });

    // Insert sample apartments
    await db.insert('apartments', {
      'number': '101',
      'floor': 1,
      'tenant_name': 'أحمد محمد علي',
      'tenant_phone': '0501234567',
      'meter_id': meter1Id,
      'is_vacant': 0,
      'created_at': now,
    });
    await db.insert('apartments', {
      'number': '102',
      'floor': 1,
      'tenant_name': 'سارة يوسف القحطاني',
      'tenant_phone': '0507654321',
      'meter_id': meter2Id,
      'is_vacant': 0,
      'created_at': now,
    });
    await db.insert('apartments', {
      'number': '103',
      'floor': 1,
      'tenant_name': 'خالد العمري',
      'tenant_phone': '0559876543',
      'meter_id': meter3Id,
      'is_vacant': 0,
      'created_at': now,
    });
    await db.insert('apartments', {
      'number': '104',
      'floor': 1,
      'tenant_name': null,
      'tenant_phone': null,
      'meter_id': meter4Id,
      'is_vacant': 1,
      'created_at': now,
    });
    await db.insert('apartments', {
      'number': '201',
      'floor': 2,
      'tenant_name': 'فيصل الدوسري',
      'tenant_phone': '0561234567',
      'meter_id': null,
      'is_vacant': 0,
      'created_at': now,
    });

    // Insert sample bills
    final cycleDate =
        DateTime.now().subtract(const Duration(days: 5)).toIso8601String();
    await db.insert('bills', {
      'apartment_id': 1,
      'cycle_label': 'أكتوبر 2023 - الدورة الأولى',
      'cycle_date': cycleDate,
      'prev_reading': 12500,
      'curr_reading': 12750,
      'consumption': 250,
      'unit_price': 0.18,
      'subscription_fee': 50,
      'prev_balance': 0,
      'total': 95,
      'paid_amount': 95,
      'status': 'paid',
      'created_at': cycleDate,
    });
    await db.insert('bills', {
      'apartment_id': 2,
      'cycle_label': 'أكتوبر 2023 - الدورة الأولى',
      'cycle_date': cycleDate,
      'prev_reading': 8600,
      'curr_reading': 8900,
      'consumption': 300,
      'unit_price': 0.18,
      'subscription_fee': 50,
      'prev_balance': 200,
      'total': 354,
      'paid_amount': 0,
      'status': 'unpaid',
      'created_at': cycleDate,
    });
    await db.insert('bills', {
      'apartment_id': 3,
      'cycle_label': 'أكتوبر 2023 - الدورة الأولى',
      'cycle_date': cycleDate,
      'prev_reading': 14900,
      'curr_reading': 15200,
      'consumption': 300,
      'unit_price': 0.18,
      'subscription_fee': 50,
      'prev_balance': 0,
      'total': 104,
      'paid_amount': 50,
      'status': 'partial',
      'created_at': cycleDate,
    });

    // Insert sample activities
    await db.insert('activities', {
      'type': 'payment',
      'description': 'تم استلام دفعة من شقة 101 - أحمد محمد',
      'amount': 95.0,
      'related_id': 1,
      'icon': 'payments',
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    });
    await db.insert('activities', {
      'type': 'reading',
      'description': 'تم إدخال قراءة عداد شقة 102',
      'amount': null,
      'related_id': 2,
      'icon': 'electric_meter',
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    });
    await db.insert('activities', {
      'type': 'bill',
      'description': 'تم إنشاء فاتورة لشقة 103 - خالد العمري',
      'amount': 104.0,
      'related_id': 3,
      'icon': 'receipt_long',
      'timestamp':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    });
  }

  // Generic CRUD
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, args);
  }

  Future<String?> getSetting(String key) async {
    final res = await query('app_settings', where: 'key = ?', whereArgs: [key]);
    return res.isNotEmpty ? res.first['value'] as String : null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
        'app_settings',
        {
          'key': key,
          'value': value,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

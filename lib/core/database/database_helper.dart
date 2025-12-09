import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('water_billing.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // ⬅️ زيادة الرقم بسبب التعديلات
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // ⬅️ إضافة دالة التحديث
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // جدول العملاء
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL
      )
    ''');

    // جدول الفواتير (محدث)
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        customer_name TEXT NOT NULL,
        previous_reading REAL NOT NULL,
        current_reading REAL NOT NULL,
        consumption REAL NOT NULL,
        unit_price REAL NOT NULL,
        total_amount REAL NOT NULL,
        bill_date INTEGER NOT NULL,
        is_paid INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
      )
    ''');

    // جدول الإعدادات (جديد)
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL
      )
    ''');

    // إعدادات افتراضية
    await db.insert('settings', {
      'key': 'unit_price',
      'value': '2.0' // سعر افتراضي
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // الترقية من الإصدار 1 إلى 2
      await db.execute('''
        CREATE TABLE new_bills (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customer_id INTEGER NOT NULL,
          customer_name TEXT NOT NULL,
          previous_reading REAL NOT NULL,
          current_reading REAL NOT NULL,
          consumption REAL NOT NULL,
          unit_price REAL NOT NULL,
          total_amount REAL NOT NULL,
          bill_date INTEGER NOT NULL,
          is_paid INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
        )
      ''');

      // نسخ البيانات من الجدول القديم إلى الجديد
      await db.execute('''
        INSERT INTO new_bills (
          id, customer_id, customer_name, previous_reading, 
          current_reading, consumption, unit_price, total_amount, 
          bill_date, is_paid
        )
        SELECT 
          id, 
          customerId as customer_id,
          (SELECT name FROM customers WHERE id = customerId) as customer_name,
          previousReading as previous_reading,
          currentReading as current_reading,
          consumption,
          2.0 as unit_price, -- سعر افتراضي
          total as total_amount,
          strftime('%s', date) * 1000 as bill_date,
          0 as is_paid
        FROM bills
      ''');

      // حذف الجدول القديم وإعادة التسمية
      await db.execute('DROP TABLE bills');
      await db.execute('ALTER TABLE new_bills RENAME TO bills');

      // إنشاء جدول الإعدادات
      await db.execute('''
        CREATE TABLE settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          key TEXT UNIQUE NOT NULL,
          value TEXT NOT NULL
        )
      ''');

      // إعدادات افتراضية
      await db.insert('settings', {
        'key': 'unit_price',
        'value': '2.0'
      });
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
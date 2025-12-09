class AppConstants {
  // اسم قاعدة البيانات
  static const String dbName = 'water_billing.db';

  // جداول
  static const String customersTable = 'customers';
  static const String billsTable = 'bills';

  // مفاتيح SharedPreferences
  static const String keyUnitPrice = 'unit_price';

  // ثوابت عامة
  static const double defaultUnitPrice = 150.0; // السعر الافتراضي للمتر مثلاً
}

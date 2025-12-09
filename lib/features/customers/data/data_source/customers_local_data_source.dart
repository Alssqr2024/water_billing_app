import 'package:water_billing_app/core/database/database_helper.dart';
import 'package:water_billing_app/core/utils/constants/constants.dart';
import '../models/customer_model.dart';

class CustomersLocalDataSource {
  // الحصول على قاعدة البيانات من الـ helper
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // إضافة عميل جديد
  Future<void> addCustomer(CustomerModel customer) async {
    final db = await _dbHelper.database;
    await db.insert(AppConstants.customersTable, customer.toJson());
  }

  // جلب جميع العملاء
  Future<List<CustomerModel>> getCustomers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query(AppConstants.customersTable);

    return maps.map((map) => CustomerModel.fromJson(map)).toList();
  }

  // تحديث بيانات العميل
  Future<void> updateCustomer(CustomerModel customer) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.customersTable,
      customer.toJson(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  // حذف عميل
  Future<void> deleteCustomer(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.customersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

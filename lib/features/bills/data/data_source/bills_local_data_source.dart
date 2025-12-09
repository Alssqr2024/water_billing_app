import 'package:water_billing_app/core/database/database_helper.dart';
import '../models/bill_model.dart';


class BillsLocalDataSource {
  final DatabaseHelper databaseHelper;

  BillsLocalDataSource({required this.databaseHelper});

  Future<List<BillModel>> getBills() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      orderBy: 'bill_date DESC',
    );
    return maps.map((map) => BillModel.fromMap(map)).toList();
  }

  Future<List<BillModel>> getCustomerBills(int customerId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'bill_date DESC',
    );
    return maps.map((map) => BillModel.fromMap(map)).toList();
  }

  Future<BillModel?> getBillById(int id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return BillModel.fromMap(maps.first);
  }

  Future<int> addBill(BillModel bill) async {
    final db = await databaseHelper.database;
    return await db.insert('bills', bill.toMap());
  }

  Future<int> updateBill(BillModel bill) async {
    final db = await databaseHelper.database;
    return await db.update(
      'bills',
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> deleteBill(int id) async {
    final db = await databaseHelper.database;
    return await db.delete(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markAsPaid(int id) async {
    final db = await databaseHelper.database;
    return await db.update(
      'bills',
      {'is_paid': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markAsUnpaid(int id) async {
    final db = await databaseHelper.database;
    return await db.update(
      'bills',
      {'is_paid': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
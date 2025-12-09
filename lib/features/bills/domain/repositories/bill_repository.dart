import '../entities/bill.dart';

abstract class BillRepository {
  Future<List<BillEntity>> getBills();
  Future<List<BillEntity>> getCustomerBills(int customerId);
  Future<BillEntity?> getBillById(int id);
  Future<void> addBill(BillEntity bill);
  Future<void> updateBill(BillEntity bill);
  Future<void> deleteBill(int id);
  Future<void> markAsPaid(int id);
  Future<void> markAsUnpaid(int id);
}
import '../../domain/repositories/bill_repository.dart';
import '../../domain/entities/bill.dart';
import '../data_source/bills_local_data_source.dart';
import '../models/bill_model.dart';

class BillRepositoryImpl implements BillRepository {
  final BillsLocalDataSource localDataSource;

  BillRepositoryImpl({required this.localDataSource});

  @override
  Future<List<BillEntity>> getBills() async {
    final bills = await localDataSource.getBills();
    return bills.map((bill) => bill.toEntity()).toList();
  }

  @override
  Future<List<BillEntity>> getCustomerBills(int customerId) async {
    final bills = await localDataSource.getCustomerBills(customerId);
    return bills.map((bill) => bill.toEntity()).toList();
  }

  @override
  Future<BillEntity?> getBillById(int id) async {
    final bill = await localDataSource.getBillById(id);
    return bill?.toEntity();
  }

  @override
  Future<void> addBill(BillEntity bill) async {
    await localDataSource.addBill(BillModel.fromEntity(bill));
  }

  @override
  Future<void> updateBill(BillEntity bill) async {
    await localDataSource.updateBill(BillModel.fromEntity(bill));
  }

  @override
  Future<void> deleteBill(int id) async {
    await localDataSource.deleteBill(id);
  }

  @override
  Future<void> markAsPaid(int id) async {
    await localDataSource.markAsPaid(id);
  }

  @override
  Future<void> markAsUnpaid(int id) async {
    await localDataSource.markAsUnpaid(id);
  }
}
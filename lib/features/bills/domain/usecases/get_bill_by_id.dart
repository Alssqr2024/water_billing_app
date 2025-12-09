import '../repositories/bill_repository.dart';
import '../entities/bill.dart';

class GetBillById {
  final BillRepository repository;

  GetBillById({required this.repository});

  Future<BillEntity?> call(int id) async {
    return await repository.getBillById(id);
  }
}
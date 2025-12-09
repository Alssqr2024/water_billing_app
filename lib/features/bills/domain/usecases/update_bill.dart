import '../repositories/bill_repository.dart';
import '../entities/bill.dart';

class UpdateBill {
  final BillRepository repository;

  UpdateBill({required this.repository});

  Future<void> call(BillEntity bill) async {
    return await repository.updateBill(bill);
  }
}
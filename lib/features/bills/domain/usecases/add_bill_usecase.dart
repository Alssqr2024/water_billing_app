import '../repositories/bill_repository.dart';
import '../entities/bill.dart';

class AddBill {
  final BillRepository repository;

  AddBill({required this.repository});

  Future<void> call(BillEntity bill) async {
    return await repository.addBill(bill);
  }
}
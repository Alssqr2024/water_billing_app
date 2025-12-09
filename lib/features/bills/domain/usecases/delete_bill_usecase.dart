import '../repositories/bill_repository.dart';

class DeleteBill {
  final BillRepository repository;

  DeleteBill({required this.repository});

  Future<void> call(int id) async {
    return await repository.deleteBill(id);
  }
}
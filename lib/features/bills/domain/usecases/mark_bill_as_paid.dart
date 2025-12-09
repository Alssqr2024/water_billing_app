import '../repositories/bill_repository.dart';

class MarkBillAsPaid {
  final BillRepository repository;

  MarkBillAsPaid({required this.repository});

  Future<void> call(int id) async {
    return await repository.markAsPaid(id);
  }
}
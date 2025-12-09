import '../repositories/bill_repository.dart';

class MarkBillAsUnpaid {
  final BillRepository repository;

  MarkBillAsUnpaid({required this.repository});

  Future<void> call(int id) async {
    return await repository.markAsUnpaid(id);
  }
}
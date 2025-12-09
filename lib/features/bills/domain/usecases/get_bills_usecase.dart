import '../repositories/bill_repository.dart';
import '../entities/bill.dart';

class GetBills {
  final BillRepository repository;

  GetBills({required this.repository});

  Future<List<BillEntity>> call() async {
    return await repository.getBills();
  }
}
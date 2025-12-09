import '../repositories/bill_repository.dart';
import '../entities/bill.dart';

class GetCustomerBills {
  final BillRepository repository;

  GetCustomerBills({required this.repository});

  Future<List<BillEntity>> call(int customerId) async {
    return await repository.getCustomerBills(customerId);
  }
}
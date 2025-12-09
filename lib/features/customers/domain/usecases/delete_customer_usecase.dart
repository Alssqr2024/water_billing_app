import '../repositories/customer_repository.dart';

class DeleteCustomerUseCase {
  final CustomerRepository repository;

  DeleteCustomerUseCase(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteCustomer(id);
  }
}

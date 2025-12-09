import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class AddCustomerUseCase {
  final CustomerRepository repository;

  AddCustomerUseCase(this.repository);

  Future<void> call(CustomerEntity customer) async {
    return await repository.addCustomer(customer);
  }
}

import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<void> addCustomer(CustomerEntity customer);
  Future<List<CustomerEntity>> getCustomers();
  Future<void> deleteCustomer(int id);
  Future<void> updateCustomer(CustomerEntity customer);
}

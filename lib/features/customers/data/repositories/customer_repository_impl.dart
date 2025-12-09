import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../data_source/customers_local_data_source.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomersLocalDataSource localDataSource;

  CustomerRepositoryImpl(this.localDataSource);

  @override
  Future<void> addCustomer(CustomerEntity customer) async {
    await localDataSource.addCustomer(CustomerModel.fromEntity(customer));
  }

  @override
  Future<List<CustomerEntity>> getCustomers() async {
    final models = await localDataSource.getCustomers();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deleteCustomer(int id) async {
    await localDataSource.deleteCustomer(id);
  }

  @override
  Future<void> updateCustomer(CustomerEntity customer) async {
    await localDataSource.updateCustomer(CustomerModel.fromEntity(customer));
  }
}

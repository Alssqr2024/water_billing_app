import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/customer_entity.dart';
import '../../data/data_source/customers_local_data_source.dart';
import '../../data/models/customer_model.dart';

/// ✅ مزود مصدر البيانات المحلي (SQLite)
final customerDataSourceProvider = Provider<CustomersLocalDataSource>((ref) {
  return CustomersLocalDataSource();
});

/// ✅ المزود الرئيسي لحالة العملاء
final customerProvider =
    StateNotifierProvider<CustomerNotifier, AsyncValue<List<CustomerEntity>>>(
  (ref) => CustomerNotifier(ref),
);

class CustomerNotifier extends StateNotifier<AsyncValue<List<CustomerEntity>>> {
  final Ref ref;

  CustomerNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    try {
      final customers = await ref.read(customerDataSourceProvider).getCustomers();
      state = AsyncValue.data(customers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCustomer(CustomerEntity customer) async {
    try {
      final newCustomer = CustomerModel.fromEntity(customer);
      await ref.read(customerDataSourceProvider).addCustomer(newCustomer);
      await loadCustomers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCustomer(CustomerEntity customer) async {
    try {
      final updatedCustomer = CustomerModel.fromEntity(customer);
      await ref.read(customerDataSourceProvider).updateCustomer(updatedCustomer);
      await loadCustomers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await ref.read(customerDataSourceProvider).deleteCustomer(id);
      await loadCustomers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void searchCustomers(String query) async {
    if (query.isEmpty) {
      await loadCustomers();
      return;
    }

    final all = state.value ?? [];
    final filtered = all
        .where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase()) ||
            c.phone.contains(query))
        .toList();

    state = AsyncValue.data(filtered);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_billing_app/features/bills/data/data_source/bills_local_data_source.dart';
import 'package:water_billing_app/features/bills/data/repositories/bill_repository_impl.dart';
import 'package:water_billing_app/features/bills/domain/entities/bill.dart';
import 'package:water_billing_app/features/bills/domain/usecases/add_bill_usecase.dart';
import 'package:water_billing_app/features/bills/domain/usecases/delete_bill_usecase.dart';
import 'package:water_billing_app/features/bills/domain/usecases/get_bills_usecase.dart';
import 'package:water_billing_app/features/bills/domain/usecases/get_customer_bills.dart';
import 'package:water_billing_app/features/bills/domain/usecases/update_bill.dart';
import 'package:water_billing_app/features/bills/domain/usecases/mark_bill_as_paid.dart';
import 'package:water_billing_app/features/bills/domain/usecases/mark_bill_as_unpaid.dart';
import 'package:water_billing_app/core/database/database_helper.dart';

/// ✅ مزود مصدر البيانات المحلي للفواتير
final billsLocalDataSourceProvider = Provider<BillsLocalDataSource>((ref) {
  return BillsLocalDataSource(databaseHelper: DatabaseHelper.instance);
});

/// ✅ مزود الريبوزيتوري
final billRepositoryProvider = Provider<BillRepositoryImpl>((ref) {
  return BillRepositoryImpl(localDataSource: ref.read(billsLocalDataSourceProvider));
});

/// ✅ مزود use cases
final getBillsProvider = Provider<GetBills>((ref) {
  return GetBills(repository: ref.read(billRepositoryProvider));
});

final getCustomerBillsProvider = Provider<GetCustomerBills>((ref) {
  return GetCustomerBills(repository: ref.read(billRepositoryProvider));
});

final addBillProvider = Provider<AddBill>((ref) {
  return AddBill(repository: ref.read(billRepositoryProvider));
});

final updateBillProvider = Provider<UpdateBill>((ref) {
  return UpdateBill(repository: ref.read(billRepositoryProvider));
});

final deleteBillProvider = Provider<DeleteBill>((ref) {
  return DeleteBill(repository: ref.read(billRepositoryProvider));
});

final markBillAsPaidProvider = Provider<MarkBillAsPaid>((ref) {
  return MarkBillAsPaid(repository: ref.read(billRepositoryProvider));
});

final markBillAsUnpaidProvider = Provider<MarkBillAsUnpaid>((ref) {
  return MarkBillAsUnpaid(repository: ref.read(billRepositoryProvider));
});

/// ✅ المزود الرئيسي لحالة الفواتير
final billsProvider = StateNotifierProvider<BillsNotifier, AsyncValue<List<BillEntity>>>(
  (ref) => BillsNotifier(ref),
);

class BillsNotifier extends StateNotifier<AsyncValue<List<BillEntity>>> {
  final Ref ref;

  BillsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadBills();
  }

  Future<void> loadBills() async {
    try {
      state = const AsyncValue.loading();
      final bills = await ref.read(getBillsProvider)();
      state = AsyncValue.data(bills);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addBill(BillEntity bill) async {
    try {
      await ref.read(addBillProvider)(bill);
      await loadBills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateBill(BillEntity bill) async {
    try {
      await ref.read(updateBillProvider)(bill);
      await loadBills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteBill(int id) async {
    try {
      await ref.read(deleteBillProvider)(id);
      await loadBills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsPaid(int id) async {
    try {
      await ref.read(markBillAsPaidProvider)(id);
      await loadBills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsUnpaid(int id) async {
    try {
      await ref.read(markBillAsUnpaidProvider)(id);
      await loadBills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<List<BillEntity>> getCustomerBills(int customerId) async {
    try {
      return await ref.read(getCustomerBillsProvider)(customerId);
    } catch (e) {
      throw Exception('فشل في تحميل فواتير المشترك: $e');
    }
  }

  double? getLastReading(int customerId) {
    final allBills = state.value ?? [];
    final customerBills = allBills.where((bill) => bill.customerId == customerId).toList();
    
    if (customerBills.isEmpty) return null;
    
    // ترتيب الفواتير من الأحدث إلى الأقدم
    customerBills.sort((a, b) => b.billDate.compareTo(a.billDate));
    return customerBills.first.currentReading;
  }

  void searchBills(String query) {
    final allBills = state.value;
    if (allBills == null || query.isEmpty) {
      loadBills();
      return;
    }

    final filteredBills = allBills.where((bill) =>
      bill.customerName.toLowerCase().contains(query.toLowerCase()) ||
      bill.id.toString().contains(query)
    ).toList();

    state = AsyncValue.data(filteredBills);
  }

  List<BillEntity> get paidBills {
    final allBills = state.value ?? [];
    return allBills.where((bill) => bill.isPaid).toList();
  }

  List<BillEntity> get unpaidBills {
    final allBills = state.value ?? [];
    return allBills.where((bill) => !bill.isPaid).toList();
  }

  double get totalPaidAmount {
    return paidBills.fold(0, (sum, bill) => sum + bill.totalAmount);
  }

  double get totalUnpaidAmount {
    return unpaidBills.fold(0, (sum, bill) => sum + bill.totalAmount);
  }
}
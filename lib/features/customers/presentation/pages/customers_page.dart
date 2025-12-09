import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_billing_app/features/customers/domain/entities/customer_entity.dart';
import 'package:water_billing_app/features/customers/presentation/widgets/customer_form.dart';
import 'package:water_billing_app/features/customers/presentation/widgets/customer_list.dart';
import 'package:water_billing_app/features/customers/presentation/widgets/customer_search_bar.dart';
import '../providers/customer_provider.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    ref.read(customerProvider.notifier).searchCustomers(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersState = ref.watch(customerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة المشتركين 💧',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18, // تقليل الحجم
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // بطاقة إضافة عميل جديدة
          Card(
            margin: const EdgeInsets.all(12), // تقليل الـ margin
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(12), // تقليل الـ padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.blue.shade50,
                    Colors.cyan.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'إضافة مشترك جديد',
                    style: TextStyle(
                      fontSize: 14, // تقليل الحجم
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8), // تقليل المسافة
                  CustomerForm(
                    onSubmit: (customer) {
                      ref.read(customerProvider.notifier).addCustomer(customer);
                    },
                  ),
                ],
              ),
            ),
          ),

          // شريط البحث
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12), // تقليل الـ padding
            child: CustomerSearchBar(
              onSearchChanged: (query) {
                ref.read(customerProvider.notifier).searchCustomers(query);
              },
            ),
          ),

          const SizedBox(height: 8), // تقليل المسافة

          // عنوان قائمة العملاء
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12), // تقليل الـ padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'قائمة المشتركين',
                  style: TextStyle(
                    fontSize: 14, // تقليل الحجم
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                customersState.when(
                  loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Icon(Icons.error, size: 16, color: Colors.red),
                  data: (customers) => Text(
                    '(${customers.length})',
                    style: const TextStyle(
                      fontSize: 12, // تقليل الحجم
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4), // تقليل المسافة

          // قائمة العملاء
          Expanded(
            child: customersState.when(
              loading: () => const CustomerList(
                customers: [],
                isLoading: true,
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40, color: Colors.red), // تقليل الحجم
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'حدث خطأ في تحميل البيانات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12, // تقليل الحجم
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(customerProvider.notifier).loadCustomers(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // تقليل الـ padding
                      ),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(fontSize: 12), // تقليل الحجم
                      ),
                    ),
                  ],
                ),
              ),
              data: (customers) => CustomerList(
                customers: customers,
                onEdit: _showEditDialog,
                onDelete: _showDeleteDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(CustomerEntity customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل بيانات المشترك'),
        content: CustomerForm(
          onSubmit: (updatedCustomer) {
            ref.read(customerProvider.notifier).updateCustomer(updatedCustomer);
            Navigator.of(context).pop();
          },
          initialData: customer,
          submitButtonText: 'حفظ التعديلات',
        ),
      ),
    );
  }

  void _showDeleteDialog(CustomerEntity customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('تأكيد الحذف'),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف المشترك "${customer.name}"؟',
          style: const TextStyle(fontSize: 14), // تقليل الحجم
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(customerProvider.notifier).deleteCustomer(customer.id!);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
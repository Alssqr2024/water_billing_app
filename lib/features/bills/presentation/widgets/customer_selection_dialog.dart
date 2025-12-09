import 'package:flutter/material.dart';
import 'package:water_billing_app/features/customers/domain/entities/customer_entity.dart';

class CustomerSelectionDialog extends StatefulWidget {
  final List<CustomerEntity> customers;

  const CustomerSelectionDialog({
    super.key,
    required this.customers,
  });

  @override
  State<CustomerSelectionDialog> createState() => _CustomerSelectionDialogState();
}

class _CustomerSelectionDialogState extends State<CustomerSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<CustomerEntity> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _filteredCustomers = widget.customers;
    _searchController.addListener(_filterCustomers);
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = widget.customers.where((customer) {
        return customer.name.toLowerCase().contains(query) ||
            customer.phone.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر المشترك',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // شريط البحث
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ابحث عن مشترك...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // قائمة المشتركين
            Expanded(
              child: _filteredCustomers.isEmpty
                  ? const Center(
                      child: Text('لا يوجد مشتركين'),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(customer.name),
                          subtitle: Text(customer.phone),
                          onTap: () {
                            Navigator.of(context).pop(customer);
                          },
                        );
                      },
                    ),
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
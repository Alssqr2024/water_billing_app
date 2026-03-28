import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_billing_app/features/bills/domain/entities/bill.dart';
import 'package:water_billing_app/features/bills/presentation/providers/bill_provider.dart';
import 'package:water_billing_app/features/bills/presentation/widgets/bill_form.dart';
import 'package:water_billing_app/features/bills/presentation/widgets/bill_list.dart';
import 'package:water_billing_app/features/bills/presentation/widgets/customer_selection_dialog.dart';
import 'package:water_billing_app/features/customers/domain/entities/customer_entity.dart';
import 'package:water_billing_app/features/customers/presentation/providers/customer_provider.dart';
import 'package:water_billing_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:water_billing_app/core/utils/pdf_service.dart';

class BillsPage extends ConsumerStatefulWidget {
  const BillsPage({super.key});

  @override
  ConsumerState<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends ConsumerState<BillsPage> {
  final TextEditingController _searchController = TextEditingController();
  BillFilter _currentFilter = BillFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    ref.read(billsProvider.notifier).searchBills(_searchController.text);
  }

  void _showCreateBillDialog() async {
    final customers = ref.read(customerProvider).value ?? [];
    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إضافة مشتركين أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selectedCustomer = await showDialog<CustomerEntity>(
      context: context,
      builder: (context) => CustomerSelectionDialog(customers: customers),
    );

    if (selectedCustomer != null && mounted) {
      _showBillFormDialog(customer: selectedCustomer);
    }
  }

  void _showEditBillDialog(BillEntity bill) {
    _showBillFormDialog(bill: bill);
  }

  void _showBillFormDialog({CustomerEntity? customer, BillEntity? bill}) async {
    final unitPrice = ref.read(settingsProvider).value ?? 2.0;
    double? lastReading;

    if (customer != null && bill == null) {
      // حالة إنشاء فاتورة جديدة - جلب آخر قراءة
      lastReading = ref
          .read(billsProvider.notifier)
          .getLastReading(customer.id!);
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          bill == null ? 'إنشاء فاتورة جديدة' : 'تعديل الفاتورة',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: BillForm(
            onSubmit: (newBill) {
              if (bill == null) {
                ref.read(billsProvider.notifier).addBill(newBill);
              } else {
                ref.read(billsProvider.notifier).updateBill(newBill);
              }
              Navigator.of(context).pop();
            },
            initialData: bill,
            selectedCustomer: customer,
            unitPrice: unitPrice,
            lastReading: lastReading,
            submitButtonText: bill == null ? 'إنشاء الفاتورة' : 'حفظ التعديلات',
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BillEntity bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('تأكيد الحذف'),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف فاتورة "${bill.customerName}"؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(billsProvider.notifier).deleteBill(bill.id!);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _togglePaymentStatus(BillEntity bill) {
    if (bill.isPaid) {
      ref.read(billsProvider.notifier).markAsUnpaid(bill.id!);
    } else {
      ref.read(billsProvider.notifier).markAsPaid(bill.id!);
    }
  }

  void _exportToPdf(BillEntity bill) async {
    try {
      // البحث عن بيانات العميل
      final customers = ref.read(customerProvider).value ?? [];

      CustomerEntity customer;

      // البحث عن العميل باستخدام loop بسيط
      CustomerEntity? foundCustomer;
      for (final c in customers) {
        if (c.id == bill.customerId) {
          foundCustomer = c;
          break;
        }
      }

      if (foundCustomer != null) {
        customer = foundCustomer;
      } else {
        // استخدام البيانات من الفاتورة
        customer = CustomerEntity(
          id: bill.customerId,
          name: bill.customerName,
          phone: 'غير متوفر',
        );
      }

      // عرض خيارات المشاركة (بدون await)
      _showPdfOptions(bill, customer);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تصدير الفاتورة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPdfOptions(BillEntity bill, CustomerEntity customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'خيارات تصدير الفاتورة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('مشاركة عامة'),
              subtitle: const Text('مشاركة عبر التطبيقات المتاحة'),
              onTap: () {
                Navigator.pop(context);
                _shareBill(bill, customer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('مشاركة عبر الواتساب'),
              subtitle: const Text('إرسال الفاتورة عبر الواتساب'),
              onTap: () {
                Navigator.pop(context);
                _shareToWhatsApp(bill, customer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print, color: Colors.orange),
              title: const Text('طباعة الفاتورة'),
              subtitle: const Text('إعداد الفاتورة للطباعة'),
              onTap: () {
                Navigator.pop(context);
                _printBill(bill, customer);
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  void _shareBill(BillEntity bill, CustomerEntity customer) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final stampPath = ref.read(stampImageProvider).value;
      await PdfService.shareBill(
        bill: bill,
        customer: customer,
        stampImagePath: stampPath,
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('فشل في مشاركة الفاتورة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareToWhatsApp(BillEntity bill, CustomerEntity customer) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final stampPath = ref.read(stampImageProvider).value;
      await PdfService.shareToWhatsApp(
        bill: bill,
        customer: customer,
        stampImagePath: stampPath,
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('فشل في المشاركة عبر الواتساب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _printBill(BillEntity bill, CustomerEntity customer) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final stampPath = ref.read(stampImageProvider).value;
      await PdfService.printBill(
        bill: bill,
        customer: customer,
        stampImagePath: stampPath,
      );
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم إعداد الفاتورة للطباعة'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('فشل في إعداد الطباعة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<BillEntity> _getFilteredBills(List<BillEntity> bills) {
    switch (_currentFilter) {
      case BillFilter.all:
        return bills;
      case BillFilter.paid:
        return bills.where((bill) => bill.isPaid).toList();
      case BillFilter.unpaid:
        return bills.where((bill) => !bill.isPaid).toList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billsState = ref.watch(billsProvider);
    final billsNotifier = ref.read(billsProvider.notifier);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateBillDialog,
        tooltip: 'فاتورة جديدة',
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // شريط البحث والتصفية
          _buildSearchAndFilterBar(),

          // إحصائيات سريعة
          _buildQuickStats(billsNotifier),

          // قائمة الفواتير
          Expanded(
            child: billsState.when(
              loading: () => const BillList(bills: [], isLoading: true),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ في تحميل الفواتير',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => billsNotifier.loadBills(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
              data: (bills) {
                final filteredBills = _getFilteredBills(bills);
                return BillList(
                  bills: filteredBills,
                  onEdit: _showEditBillDialog,
                  onDelete: _showDeleteDialog,
                  onTogglePayment: _togglePaymentStatus,
                  onExportPdf: _exportToPdf,
                  emptyMessage: _getEmptyMessage(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // شريط البحث
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث باسم العميل أو رقم الفاتورة...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // أزرار التصفية
          Row(
            children: [
              _buildFilterChip('الكل', BillFilter.all),
              const SizedBox(width: 8),
              _buildFilterChip('المدفوعة', BillFilter.paid),
              const SizedBox(width: 8),
              _buildFilterChip('غير المدفوعة', BillFilter.unpaid),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, BillFilter filter) {
    return FilterChip(
      label: Text(label),
      selected: _currentFilter == filter,
      onSelected: (selected) {
        setState(() {
          _currentFilter = filter;
        });
      },
    );
  }

  Widget _buildQuickStats(BillsNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'إجمالي الفواتير',
            notifier.paidBills.length + notifier.unpaidBills.length,
          ),
          _buildStatItem('المدفوعة', notifier.paidBills.length, Colors.green),
          _buildStatItem(
            'غير المدفوعة',
            notifier.unpaidBills.length,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, [Color? color]) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  String _getEmptyMessage() {
    switch (_currentFilter) {
      case BillFilter.all:
        return 'لا توجد فواتير';
      case BillFilter.paid:
        return 'لا توجد فواتير مدفوعة';
      case BillFilter.unpaid:
        return 'لا توجد فواتير غير مدفوعة';
    }
  }
}

enum BillFilter { all, paid, unpaid }

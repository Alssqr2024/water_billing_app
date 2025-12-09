import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_billing_app/features/bills/presentation/pages/bills_page.dart';
import 'package:water_billing_app/features/customers/presentation/pages/customers_page.dart';
import 'package:water_billing_app/features/customers/presentation/providers/customer_provider.dart';
import 'package:water_billing_app/features/bills/presentation/providers/bill_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersState = ref.watch(customerProvider);
    final billsState = ref.watch(billsProvider);

    final totalCustomers = customersState.value?.length ?? 0;
    final totalBills = billsState.value?.length ?? 0;
    final paidBills = billsState.value?.where((bill) => bill.isPaid).length ?? 0;
    final unpaidBills = billsState.value?.where((bill) => !bill.isPaid).length ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'نظام فواتير المياه 💧',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الترحيب
            _buildWelcomeCard(context),
            const SizedBox(height: 24),

            // الإحصائيات السريعة
            _buildStatsSection(totalCustomers, totalBills, paidBills, unpaidBills),
            const SizedBox(height: 24),

            // التنقل السريع
            _buildQuickActionsSection(context),
            const SizedBox(height: 24),

            // الفواتير الحديثة
            _buildRecentBillsSection(billsState),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue.shade700,
            Colors.cyan.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // إضافة هذا
        children: [
          const Text(
            'مرحباً بك 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'إدارة فواتير المياه بكل سهولة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getCurrentDate(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(int totalCustomers, int totalBills, int paidBills, int unpaidBills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // إضافة هذا
      children: [
        const Text(
          'نظرة سريعة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              title: 'المشتركين',
              value: totalCustomers.toString(),
              icon: Icons.people,
              color: Colors.blue,
            ),
            _buildStatCard(
              title: 'إجمالي الفواتير',
              value: totalBills.toString(),
              icon: Icons.receipt,
              color: Colors.green,
            ),
            _buildStatCard(
              title: 'الفواتير المدفوعة',
              value: paidBills.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            _buildStatCard(
              title: 'الفواتير المتأخرة',
              value: unpaidBills.toString(),
              icon: Icons.pending,
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // إضافة هذا
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20, // تقليل الحجم
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4), // إضافة padding
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11, // تقليل الحجم
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // إضافة هذا
      children: [
        const Text(
          'الإجراءات السريعة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4, // تعديل النسبة
          children: [
            _buildActionCard(
              title: 'إدارة المشتركين',
              subtitle: 'إضافة وعرض المشتركين',
              icon: Icons.people_outline,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomersPage()),
                );
              },
            ),
            _buildActionCard(
              title: 'إدارة الفواتير',
              subtitle: 'إنشاء وعرض الفواتير',
              icon: Icons.receipt_long,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BillsPage()),
                );
              },
            ),
            _buildActionCard(
              title: 'إضافة مشترك',
              subtitle: 'إضافة مشترك جديد',
              icon: Icons.person_add,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomersPage()),
                );
              },
            ),
            _buildActionCard(
              title: 'إنشاء فاتورة',
              subtitle: 'فاتورة جديدة',
              icon: Icons.add_chart,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BillsPage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12), // تقليل الـ padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // إضافة هذا
            children: [
              Icon(
                icon,
                color: color,
                size: 24, // تقليل الحجم
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13, // تقليل الحجم
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10, // تقليل الحجم
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentBillsSection(AsyncValue<List<dynamic>> billsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // إضافة هذا
      children: [
        const Text(
          'آخر الفواتير',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: billsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'حدث خطأ في تحميل البيانات',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            data: (bills) {
              final recentBills = bills.take(3).toList();
              
              return recentBills.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد فواتير حديثة',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min, // إضافة هذا
                      children: recentBills.map((bill) => _buildBillListItem(bill)).toList(),
                    );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBillListItem(dynamic bill) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8), // تقليل الـ padding
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36, // تقليل الحجم
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt,
              color: Colors.blue.shade700,
              size: 18, // تقليل الحجم
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // إضافة هذا
              children: [
                Text(
                  'فاتورة #${bill.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13, // تقليل الحجم
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'اسم العميل',
                  style: TextStyle(
                    fontSize: 11, // تقليل الحجم
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min, // إضافة هذا
            children: [
              Text(
                '0.0 ريال',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13, // تقليل الحجم
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), // تقليل الـ padding
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'مدفوعة',
                  style: TextStyle(
                    fontSize: 9, // تقليل الحجم
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
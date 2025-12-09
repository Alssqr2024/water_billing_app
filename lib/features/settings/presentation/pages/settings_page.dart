import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_billing_app/features/settings/presentation/providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _unitPriceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // تحميل سعر الوحدة الحالي عند فتح الصفحة
    _loadCurrentUnitPrice();
  }

  void _loadCurrentUnitPrice() {
    final unitPrice = ref.read(settingsProvider).value;
    if (unitPrice != null) {
      _unitPriceController.text = unitPrice.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _unitPriceController.dispose();
    super.dispose();
  }

  String? _unitPriceValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال سعر الوحدة';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'يرجى إدخال سعر صحيح';
    }
    return null;
  }

  void _saveUnitPrice() {
    if (_formKey.currentState!.validate()) {
      final unitPrice = double.parse(_unitPriceController.text);
      ref.read(settingsProvider.notifier).updateUnitPrice(unitPrice);

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث سعر الوحدة إلى $unitPrice ريال'),
          backgroundColor: Colors.green,
        ),
      );

      // إخفاء الكيبورد
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإعدادات ⚙️',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة إعدادات سعر الوحدة
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Colors.purple.shade50, Colors.purple.shade100],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.monetization_on, color: Colors.purple),
                          SizedBox(width: 8),
                          Text(
                            'سعر الوحدة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'سعر المتر المكعب من المياه (ريال/م³)',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      settingsState.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Column(
                          children: [
                            Text(
                              'حدث خطأ في تحميل الإعدادات',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(settingsProvider.notifier)
                                  .loadUnitPrice(),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                        data: (unitPrice) => Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _unitPriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'سعر الوحدة (ريال/م³)',
                                  prefixIcon: const Icon(Icons.attach_money),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: _unitPriceValidator,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.save),
                                  label: const Text(
                                    'حفظ الإعدادات',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  onPressed: _saveUnitPrice,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    backgroundColor: Colors.purple.shade700,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // معلومات عن الإعدادات
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return const Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات مهمة 💡',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '• سعر الوحدة يستخدم لحساب تكلفة الفواتير تلقائياً\n'
              '• عند تغيير السعر، لا يؤثر على الفواتير السابقة\n'
              '• الفواتير الجديدة تستخدم السعر الجديد',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

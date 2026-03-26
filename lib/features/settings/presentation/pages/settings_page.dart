import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:water_billing_app/features/settings/presentation/providers/settings_provider.dart';

// الثوابت الخاصة بالمطور
class AppInfo {
  static const String developerName = 'ِAhmed Al-Dhuraibi';
  static const String developerEmail = 'alssqr7740@email.com';
  static const String developerWebsite = 'https://ahmedaldhuraibi.kesug.com/';
  static const String developerWhatsapp = '+966501436049';
}

class AppColors {
  static const Color primary = Colors.purple;
}

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث سعر الوحدة إلى $unitPrice ريال'),
          backgroundColor: Colors.green,
        ),
      );

      FocusScope.of(context).unfocus();
    }
  }

  /// فتح منتقي الصورة واختيار الختم الجديد
  Future<void> _pickStampImage() async {
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (pickedFile != null && mounted) {
      await ref
          .read(stampImageProvider.notifier)
          .updateStampImagePath(pickedFile.path);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('تم تحديث ختم الفاتورة بنجاح ✅'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// إزالة الختم المخصص والعودة للافتراضي
  Future<void> _resetStampImage() async {
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة تعيين الختم'),
        content: const Text('هل تريد العودة للختم الافتراضي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('نعم'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // حذف المسار المحفوظ
      final dataSource = ref.read(settingsDataSourceProvider);
      await dataSource.setSetting('stamp_image_path', '');
      ref.read(stampImageProvider.notifier).updateStampImagePath('');

      messenger.showSnackBar(
        const SnackBar(
          content: Text('تمت إعادة تعيين الختم للافتراضي'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final stampState = ref.watch(stampImageProvider);

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

              // ─── بطاقة ختم الفاتورة ───
              _buildStampCard(stampState),
              const SizedBox(height: 24),

              // بطاقة المطور
              _buildDeveloperCard(context),
              const SizedBox(height: 24),

              // معلومات عن الإعدادات
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// بطاقة إعداد ختم الفاتورة
  Widget _buildStampCard(AsyncValue<String?> stampState) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.teal.shade50, Colors.teal.shade100],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            const Row(
              children: [
                Icon(Icons.verified, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'ختم الفاتورة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'الصورة التي تظهر كختم رسمي في أسفل الفاتورة',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // معاينة الختم الحالي
            Center(
              child: stampState.when(
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Icon(
                  Icons.image_not_supported,
                  size: 80,
                  color: Colors.grey,
                ),
                data: (path) {
                  final hasCustomStamp = path != null && path.isNotEmpty;
                  return Column(
                    children: [
                      // صورة الختم
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.teal.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: hasCustomStamp
                              ? Image.file(
                                  File(path),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/seal.png',
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasCustomStamp ? 'ختم مخصص ✅' : 'الختم الافتراضي',
                        style: TextStyle(
                          fontSize: 13,
                          color: hasCustomStamp
                              ? Colors.teal.shade700
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.image_search),
                    label: const Text('تغيير الختم'),
                    onPressed: _pickStampImage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // زر إعادة التعيين — يظهر فقط إذا كان هناك ختم مخصص
                stampState.maybeWhen(
                  data: (path) {
                    final hasCustom = path != null && path.isNotEmpty;
                    if (!hasCustom) return const SizedBox.shrink();
                    return OutlinedButton.icon(
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('افتراضي'),
                      onPressed: _resetStampImage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.orange.shade700,
                        side: BorderSide(color: Colors.orange.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ],
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
              '• الفواتير الجديدة تستخدم السعر الجديد\n'
              '• يمكن تغيير ختم الفاتورة من قسم "ختم الفاتورة" أعلاه',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // --- قسم المطور ---

  Widget _buildDeveloperCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.code, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المطور',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppInfo.developerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactButton(
            context: context,
            icon: Icons.email_outlined,
            label: 'البريد الإلكتروني',
            value: AppInfo.developerEmail,
            onTap: () => _launchEmail(context),
          ),
          const SizedBox(height: 12),
          _buildContactButton(
            context: context,
            icon: Icons.language,
            label: 'الموقع الإلكتروني',
            value: 'زيارة الموقع',
            onTap: () => _launchWebsite(context),
          ),
          const SizedBox(height: 12),
          _buildContactButton(
            context: context,
            icon: Icons.chat,
            label: 'واتساب',
            value: AppInfo.developerWhatsapp,
            onTap: () => _launchWhatsApp(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppInfo.developerEmail,
      query: 'subject=استفسار عن تطبيق فواتير المياه',
    );

    try {
      if (!await launchUrl(emailUri)) {
        throw 'Could not launch $emailUri';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح تطبيق البريد الإلكتروني')),
        );
      }
    }
  }

  Future<void> _launchWebsite(BuildContext context) async {
    final Uri websiteUri = Uri.parse(AppInfo.developerWebsite);

    try {
      if (!await launchUrl(websiteUri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $websiteUri';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح الموقع الإلكتروني')),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    // Format the phone number (remove + or spaces if needed, but standard format is good)
    final whatsappUrl = Uri.parse(
      'https://wa.me/${AppInfo.developerWhatsapp.replaceAll('+', '')}',
    );

    try {
      if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $whatsappUrl';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح تطبيق واتساب')),
        );
      }
    }
  }
}

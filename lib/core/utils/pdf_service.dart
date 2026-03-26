import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:water_billing_app/core/utils/pdf_generator.dart';
import 'package:water_billing_app/features/bills/domain/entities/bill.dart';
import 'package:water_billing_app/features/customers/domain/entities/customer_entity.dart';

class PdfService {
  static Future<File> generateBillPdfFile({
    required BillEntity bill,
    required CustomerEntity customer,
    String? stampImagePath,
  }) async {
    try {
      // إنشاء PDF
      final pdf = await PdfGenerator.generateBillPdf(
        bill: bill,
        customer: customer,
        stampImagePath: stampImagePath,
      );

      // حفظ الملف مؤقتاً
      final bytes = await pdf.save();
      final directory = await getTemporaryDirectory();
      
      // تنظيف اسم الملف من الأحرف الخاصة
      final cleanName = _cleanFileName(customer.name);
      final file = File('${directory.path}/فاتورة_${cleanName}_${bill.id}.pdf');
      
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      throw Exception('فشل في إنشاء ملف PDF: $e');
    }
  }

  static Future<void> shareBill({
    required BillEntity bill,
    required CustomerEntity customer,
    String? subject,
    String? stampImagePath,
  }) async {
    try {
      final file = await generateBillPdfFile(
        bill: bill,
        customer: customer,
        stampImagePath: stampImagePath,
      );
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject ?? 'فاتورة مياه - ${customer.name}',
        text: 'فاتورة مياه للمشترك ${customer.name}\n'
              'المبلغ: ${bill.totalAmount.toStringAsFixed(2)} ريال\n'
              'تاريخ الفاتورة: ${_formatDate(bill.billDate)}',
      );
    } catch (e) {
      throw Exception('فشل في مشاركة الفاتورة: $e');
    }
  }

  static Future<void> shareToWhatsApp({
    required BillEntity bill,
    required CustomerEntity customer,
    String? stampImagePath,
  }) async {
    try {
      final file = await generateBillPdfFile(
        bill: bill,
        customer: customer,
        stampImagePath: stampImagePath,
      );
      
      // نص مخصص للواتساب
      final whatsappText = '''
فاتورة مياه 💧

المشترك: ${customer.name}
رقم الهاتف: ${customer.phone}
المبلغ: ${bill.totalAmount.toStringAsFixed(2)} ريال
تاريخ الفاتورة: ${_formatDate(bill.billDate)}
حالة الدفع: ${bill.isPaid ? 'مدفوعة' : 'غير مدفوعة'}

شكراً لاستخدامكم خدماتنا 🌟
      ''';

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'فاتورة مياه - ${customer.name}',
        text: whatsappText,
      );
    } catch (e) {
      throw Exception('فشل في المشاركة عبر الواتساب: $e');
    }
  }

  static Future<void> printBill({
    required BillEntity bill,
    required CustomerEntity customer,
    String? stampImagePath,
  }) async {
    try {
      // بديل: حفظ ومشاركة للطباعة
      final file = await generateBillPdfFile(
        bill: bill,
        customer: customer,
        stampImagePath: stampImagePath,
      );
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'طباعة فاتورة - ${customer.name}',
        text: 'فاتورة مياه جاهزة للطباعة',
      );
    } catch (e) {
      throw Exception('فشل في إعداد الطباعة: $e');
    }
  }

  static String _formatDate(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _cleanFileName(String name) {
    // إزالة الأحرف الخاصة من اسم الملف
    return name.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '')
              .replaceAll(' ', '_')
              .replaceAll('/', '_')
              .replaceAll('\\', '_');
  }
}
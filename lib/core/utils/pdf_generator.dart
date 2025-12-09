import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:water_billing_app/features/bills/domain/entities/bill.dart';
import 'package:water_billing_app/features/customers/domain/entities/customer_entity.dart';

class PdfGenerator {
  static Future<pw.Document> generateBillPdf({
    required BillEntity bill,
    required CustomerEntity customer,
  }) async {
    final pdf = pw.Document();

    // تحميل الخط العربي
    final arabicFont = await _loadArabicFont();

    final ByteData bytes = await rootBundle.load('assets/images/seal.png');
    final Uint8List imageBytes = bytes.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // الهيدر - Header
                _buildHeader(arabicFont),
                pw.SizedBox(height: 20),

                // معلومات العميل
                _buildCustomerInfo(customer, arabicFont),
                pw.SizedBox(height: 25),

                // تفاصيل الفاتورة
                _buildBillDetails(bill, arabicFont),

                pw.Footer(
                  trailing: pw.Row(
                    children: [
                      pw.Text(
                        "لجنة مشروع مياة أدمة",
                        style: pw.TextStyle(font: arabicFont),
                      ),
                      pw.Image(
                        pw.MemoryImage(imageBytes),
                        width: 60, // Optional: set width
                        height: 60, // Optional: set height
                      ),
                    ],
                  ),

                  leading: pw.Row(
                    children: [
                      pw.Text(
                        "ملاحظة: ",
                        style: pw.TextStyle(
                          color: PdfColors.red,
                          font: arabicFont,
                        ),
                      ),
                      pw.Text(
                        "الرجاء تسديد الفاتورة خلال مدة اقصاها 5 ايام",
                        style: pw.TextStyle(font: arabicFont),
                      ),
                    ],
                  ),
                ),

                // الفوتر - Footer
                // _buildFooter(arabicFont),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(pw.Font arabicFont) {
    return pw.Column(
      children: [
        pw.Text(
          'فاتورة مياه',
          style: pw.TextStyle(
            font: arabicFont,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.Text(
          'مشروع مياة أدمة ',
          style: pw.TextStyle(
            fontSize: 16,
            color: PdfColors.grey,
            font: arabicFont,
          ),
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildCustomerInfo(
    CustomerEntity customer,
    pw.Font arabicFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.lightBlue,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'بيانات المشترك',
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(thickness: 2, color: PdfColors.white),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoRow('رقم المشترك:', customer.id.toString(), arabicFont),
              _buildInfoRow('الاسم:', customer.name, arabicFont),
              _buildInfoRow('رقم الهاتف:', customer.phone, arabicFont),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBillDetails(BillEntity bill, pw.Font arabicFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'تفاصيل الفاتورة',
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 15),
          _buildDetailRow('رقم الفاتورة', '#${bill.id}', arabicFont),
          _buildDetailRow(
            'تاريخ الإصدار',
            _formatDate(bill.billDate),
            arabicFont,
          ),
          _buildDetailRow(
            'القراءة السابقة',
            '${bill.previousReading} م³',
            arabicFont,
          ),
          _buildDetailRow(
            'القراءة الحالية',
            '${bill.currentReading} م³',
            arabicFont,
          ),
          _buildDetailRow(
            'كمية الاستهلاك',
            '${bill.consumption.toStringAsFixed(2)} م³',
            arabicFont,
          ),
          _buildDetailRow(
            'سعر الوحدة',
            '${bill.unitPrice.toStringAsFixed(2)} ريال/م³',
            arabicFont,
          ),
          pw.Divider(color: PdfColors.grey),
          _buildDetailRow(
            'المبلغ الإجمالي',
            '${bill.totalAmount.toStringAsFixed(2)} ريال',
            arabicFont,
            isBold: true,
            color: PdfColors.green,
          ),
          pw.SizedBox(height: 10),
          _buildPaymentStatus(bill.isPaid, arabicFont),
        ],
      ),
    );
  }

  static pw.Widget _buildDetailRow(
    String label,
    String value,
    pw.Font arabicFont, {
    bool isBold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: arabicFont,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: 14,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: arabicFont,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(
    String label,
    String value,
    pw.Font arabicFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: arabicFont,
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Text(value, style: pw.TextStyle(font: arabicFont, fontSize: 14)),
        ],
      ),
    );
  }

  static pw.Widget _buildPaymentStatus(bool isPaid, pw.Font arabicFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: pw.BoxDecoration(
        color: isPaid ? PdfColors.lightGreen : PdfColors.orange,
        borderRadius: pw.BorderRadius.circular(20),
        border: pw.Border.all(
          color: isPaid ? PdfColors.green : PdfColors.orange,
        ),
      ),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            isPaid ? '✓' : '!',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Text(
            isPaid ? 'مدفوعة' : 'غير مدفوعة',
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 12,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font arabicFont) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            pw.Row(
              children: [
                pw.Text(
                  'شكراً لاستخدامكم خدماتنا',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 12,
                    color: PdfColors.blue,
                  ),
                ),
                pw.SizedBox(height: 25),
                pw.Text(
                  'التوقيع',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Container(
                  width: 150,
                  height: 1,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            'للاستفسار: 0551234567',
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 10,
              color: PdfColors.grey,
            ),
          ),
        ),
      ],
    );
  }

  static Future<pw.Font> _loadArabicFont() async {
    try {
      // تحميل الخط العربي من assets
      final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      final font = pw.Font.ttf(fontData);
      return font;
    } catch (e) {
      // استخدام الخط الافتراضي كبديل
      return pw.Font.courier();
    }
  }

  static String _formatDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

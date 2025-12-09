import 'package:flutter/material.dart';
import 'package:water_billing_app/features/bills/domain/entities/bill.dart';

class BillCard extends StatelessWidget {
  final BillEntity bill;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTogglePayment;
  final VoidCallback? onExportPdf;

  const BillCard({
    super.key,
    required this.bill,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onTogglePayment,
    this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: bill.isPaid ? Colors.green.shade200 : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bill.isPaid
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                bill.isPaid ? Icons.check_circle : Icons.receipt,
                color: bill.isPaid ? Colors.green : Colors.orange,
                size: 24,
              ),
            ),
            title: Text(
              bill.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'الاستهلاك: ${bill.consumption.toStringAsFixed(2)} م³',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  'المبلغ: ${bill.totalAmount.toStringAsFixed(2)} ريال',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  'التاريخ: ${_formatDate(bill.billDate)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            onTap: onTap,
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: bill.isPaid ? Colors.green.shade200 : Colors.grey.shade300,

            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onExportPdf != null)
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  onPressed: onExportPdf,
                  tooltip: 'تصدير PDF',
                ),
              if (onTogglePayment != null)
                IconButton(
                  icon: Icon(
                    bill.isPaid ? Icons.cancel : Icons.payment,
                    color: bill.isPaid ? Colors.orange : Colors.green,
                  ),
                  onPressed: onTogglePayment,
                  tooltip: bill.isPaid ? 'إلغاء الدفع' : 'تم الدفع',
                ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                  tooltip: 'تعديل',
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'حذف',
                ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}

import 'package:flutter/material.dart';
import 'package:water_billing_app/features/bills/domain/entities/bill.dart';
import 'bill_card.dart';

class BillList extends StatelessWidget {
  final List<BillEntity> bills;
  final Function(BillEntity)? onEdit;
  final Function(BillEntity)? onDelete;
  final Function(BillEntity)? onTogglePayment;
  final Function(BillEntity)? onExportPdf;
  final bool isLoading;
  final String emptyMessage;

  const BillList({
    super.key,
    required this.bills,
    this.onEdit,
    this.onDelete,
    this.onTogglePayment,
    this.onExportPdf,
    this.isLoading = false,
    this.emptyMessage = 'لا توجد فواتير',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل الفواتير...'),
          ],
        ),
      );
    }

    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return BillCard(
          bill: bill,
          onEdit: onEdit != null ? () => onEdit!(bill) : null,
          onDelete: onDelete != null ? () => onDelete!(bill) : null,
          onTogglePayment: onTogglePayment != null ? () => onTogglePayment!(bill) : null,
          onExportPdf: onExportPdf != null ? () => onExportPdf!(bill) : null,
        );
      },
    );
  }
}
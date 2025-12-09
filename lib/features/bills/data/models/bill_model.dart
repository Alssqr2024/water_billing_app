import '../../domain/entities/bill.dart';

class BillModel extends BillEntity {
  const BillModel({
    super.id,
    required super.customerId,
    required super.customerName,
    required super.previousReading,
    required super.currentReading,
    required super.consumption,
    required super.unitPrice,
    required super.totalAmount,
    required super.billDate,
    super.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'previous_reading': previousReading,
      'current_reading': currentReading,
      'consumption': consumption,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'bill_date': billDate.millisecondsSinceEpoch,
      'is_paid': isPaid ? 1 : 0,
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      previousReading: map['previous_reading']?.toDouble() ?? 0.0,
      currentReading: map['current_reading']?.toDouble() ?? 0.0,
      consumption: map['consumption']?.toDouble() ?? 0.0,
      unitPrice: map['unit_price']?.toDouble() ?? 0.0,
      totalAmount: map['total_amount']?.toDouble() ?? 0.0,
      billDate: DateTime.fromMillisecondsSinceEpoch(map['bill_date']),
      isPaid: map['is_paid'] == 1,
    );
  }

  BillEntity toEntity() => BillEntity(
        id: id,
        customerId: customerId,
        customerName: customerName,
        previousReading: previousReading,
        currentReading: currentReading,
        consumption: consumption,
        unitPrice: unitPrice,
        totalAmount: totalAmount,
        billDate: billDate,
        isPaid: isPaid,
      );

  factory BillModel.fromEntity(BillEntity entity) => BillModel(
        id: entity.id,
        customerId: entity.customerId,
        customerName: entity.customerName,
        previousReading: entity.previousReading,
        currentReading: entity.currentReading,
        consumption: entity.consumption,
        unitPrice: entity.unitPrice,
        totalAmount: entity.totalAmount,
        billDate: entity.billDate,
        isPaid: entity.isPaid,
      );
}
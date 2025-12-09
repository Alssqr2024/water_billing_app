class BillEntity {
  final int? id;
  final int customerId;
  final String customerName;
  final double previousReading;
  final double currentReading;
  final double consumption;
  final double unitPrice;
  final double totalAmount;
  final DateTime billDate;
  final bool isPaid;

  const BillEntity({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.previousReading,
    required this.currentReading,
    required this.consumption,
    required this.unitPrice,
    required this.totalAmount,
    required this.billDate,
    this.isPaid = false,
  });

  BillEntity copyWith({
    int? id,
    int? customerId,
    String? customerName,
    double? previousReading,
    double? currentReading,
    double? consumption,
    double? unitPrice,
    double? totalAmount,
    DateTime? billDate,
    bool? isPaid,
  }) {
    return BillEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      previousReading: previousReading ?? this.previousReading,
      currentReading: currentReading ?? this.currentReading,
      consumption: consumption ?? this.consumption,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      billDate: billDate ?? this.billDate,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  @override
  String toString() {
    return 'BillEntity(id: $id, customerId: $customerId, customerName: $customerName, consumption: $consumption, totalAmount: $totalAmount, isPaid: $isPaid)';
  }
}
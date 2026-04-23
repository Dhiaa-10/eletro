class BillModel {
  final int? id;
  final int apartmentId;
  final String cycleLabel;
  final String cycleDate;
  final double prevReading;
  final double currReading;
  final double consumption;
  final double unitPrice;
  final double subscriptionFee;
  final double prevBalance;
  final double total;
  final double paidAmount;
  final String status; // paid, unpaid, partial
  final String? notes;
  final String createdAt;

  // From join
  final String? apartmentNumber;
  final String? tenantName;

  BillModel({
    this.id,
    required this.apartmentId,
    required this.cycleLabel,
    required this.cycleDate,
    required this.prevReading,
    required this.currReading,
    required this.consumption,
    required this.unitPrice,
    required this.subscriptionFee,
    required this.prevBalance,
    required this.total,
    required this.paidAmount,
    required this.status,
    this.notes,
    required this.createdAt,
    this.apartmentNumber,
    this.tenantName,
  });

  double get remaining => (total - paidAmount).clamp(0.0, double.infinity);
  bool get isPaid => status == 'paid';
  bool get isUnpaid => status == 'unpaid';
  bool get isPartial => status == 'partial';

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as int?,
      apartmentId: map['apartment_id'] as int,
      cycleLabel: map['cycle_label'] as String,
      cycleDate: map['cycle_date'] as String,
      prevReading: (map['prev_reading'] as num).toDouble(),
      currReading: (map['curr_reading'] as num).toDouble(),
      consumption: (map['consumption'] as num).toDouble(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      subscriptionFee: (map['subscription_fee'] as num).toDouble(),
      prevBalance: (map['prev_balance'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num).toDouble(),
      status: map['status'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
      apartmentNumber: map['apartment_number'] as String?,
      tenantName: map['tenant_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'apartment_id': apartmentId,
      'cycle_label': cycleLabel,
      'cycle_date': cycleDate,
      'prev_reading': prevReading,
      'curr_reading': currReading,
      'consumption': consumption,
      'unit_price': unitPrice,
      'subscription_fee': subscriptionFee,
      'prev_balance': prevBalance,
      'total': total,
      'paid_amount': paidAmount,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  BillModel copyWith({
    int? id,
    int? apartmentId,
    String? cycleLabel,
    String? cycleDate,
    double? prevReading,
    double? currReading,
    double? consumption,
    double? unitPrice,
    double? subscriptionFee,
    double? prevBalance,
    double? total,
    double? paidAmount,
    String? status,
    String? notes,
    String? createdAt,
    String? apartmentNumber,
    String? tenantName,
  }) {
    return BillModel(
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      cycleLabel: cycleLabel ?? this.cycleLabel,
      cycleDate: cycleDate ?? this.cycleDate,
      prevReading: prevReading ?? this.prevReading,
      currReading: currReading ?? this.currReading,
      consumption: consumption ?? this.consumption,
      unitPrice: unitPrice ?? this.unitPrice,
      subscriptionFee: subscriptionFee ?? this.subscriptionFee,
      prevBalance: prevBalance ?? this.prevBalance,
      total: total ?? this.total,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      tenantName: tenantName ?? this.tenantName,
    );
  }
}

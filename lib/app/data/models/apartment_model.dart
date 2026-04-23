class ApartmentModel {
  final int? id;
  final String number;
  final int floor;
  final String? tenantName;
  final String? tenantPhone;
  final int? meterId;
  final bool isVacant;
  final String? notes;
  final String createdAt;

  // From join
  final String? meterNumber;
  final double? currentReading;

  ApartmentModel({
    this.id,
    required this.number,
    required this.floor,
    this.tenantName,
    this.tenantPhone,
    this.meterId,
    this.isVacant = false,
    this.notes,
    required this.createdAt,
    this.meterNumber,
    this.currentReading,
  });

  factory ApartmentModel.fromMap(Map<String, dynamic> map) {
    return ApartmentModel(
      id: map['id'] as int?,
      number: map['number'] as String,
      floor: map['floor'] as int,
      tenantName: map['tenant_name'] as String?,
      tenantPhone: map['tenant_phone'] as String?,
      meterId: map['meter_id'] as int?,
      isVacant: (map['is_vacant'] as int) == 1,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
      meterNumber: map['meter_number'] as String?,
      currentReading: map['current_reading'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'number': number,
      'floor': floor,
      'tenant_name': tenantName,
      'tenant_phone': tenantPhone,
      'meter_id': meterId,
      'is_vacant': isVacant ? 1 : 0,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  ApartmentModel copyWith({
    int? id,
    String? number,
    int? floor,
    String? tenantName,
    String? tenantPhone,
    int? meterId,
    bool? isVacant,
    String? notes,
    String? createdAt,
    String? meterNumber,
    double? currentReading,
  }) {
    return ApartmentModel(
      id: id ?? this.id,
      number: number ?? this.number,
      floor: floor ?? this.floor,
      tenantName: tenantName ?? this.tenantName,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      meterId: meterId ?? this.meterId,
      isVacant: isVacant ?? this.isVacant,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      meterNumber: meterNumber ?? this.meterNumber,
      currentReading: currentReading ?? this.currentReading,
    );
  }
}

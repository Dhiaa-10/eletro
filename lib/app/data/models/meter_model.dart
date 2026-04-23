class MeterModel {
  final int? id;
  final String meterNumber;
  final String type; // main, sub
  final double currentReading;
  final int? apartmentId;
  final String createdAt;

  MeterModel({
    this.id,
    required this.meterNumber,
    this.type = 'sub',
    this.currentReading = 0,
    this.apartmentId,
    required this.createdAt,
  });

  factory MeterModel.fromMap(Map<String, dynamic> map) {
    return MeterModel(
      id: map['id'] as int?,
      meterNumber: map['meter_number'] as String,
      type: map['type'] as String,
      currentReading: (map['current_reading'] as num).toDouble(),
      apartmentId: map['apartment_id'] as int?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'meter_number': meterNumber,
      'type': type,
      'current_reading': currentReading,
      'apartment_id': apartmentId,
      'created_at': createdAt,
    };
  }
}

class ActivityModel {
  final int? id;
  final String type; // payment, reading, bill, setting
  final String description;
  final double? amount;
  final int? relatedId;
  final String? icon;
  final String timestamp;

  ActivityModel({
    this.id,
    required this.type,
    required this.description,
    this.amount,
    this.relatedId,
    this.icon,
    required this.timestamp,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      description: map['description'] as String,
      amount: map['amount'] != null ? (map['amount'] as num).toDouble() : null,
      relatedId: map['related_id'] as int?,
      icon: map['icon'] as String?,
      timestamp: map['timestamp'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'description': description,
      'amount': amount,
      'related_id': relatedId,
      'icon': icon,
      'created_at': timestamp,
      'timestamp': timestamp,
    };
  }
}

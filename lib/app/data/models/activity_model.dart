class ActivityModel {
  final int? id;
  final String type;
  final String description;
  final double? amount;
  final int? referenceId;
  final String timestamp;

  ActivityModel({
    this.id,
    required this.type,
    required this.description,
    this.amount,
    this.referenceId,
    required this.timestamp,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) => ActivityModel(
        id: map['id'] as int?,
        type: map['type'] as String? ?? 'general',
        description: map['description'] as String? ?? '',
        amount: (map['amount'] as num?)?.toDouble(),
        referenceId: map['reference_id'] as int?,
        timestamp:
            map['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'type': type,
        'description': description,
        if (amount != null) 'amount': amount,
        if (referenceId != null) 'reference_id': referenceId,
        'timestamp': timestamp,
      };
}

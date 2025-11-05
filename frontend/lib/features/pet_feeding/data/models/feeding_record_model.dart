import '../../../../../features/pet_feeding/domain/entities/feeding_record_entity.dart';

/// 급여 기록 모델 (Data Layer)
/// JSON 변환 및 Entity 변환을 담당
class FeedingRecordModel {
  final String id;
  final String petId;
  final String petName;
  final DateTime fedTime;
  final double amount;
  final String foodType;
  final String foodBrand;
  final FeedingStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FeedingRecordModel({
    required this.id,
    required this.petId,
    required this.petName,
    required this.fedTime,
    required this.amount,
    required this.foodType,
    required this.foodBrand,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// JSON에서 FeedingRecordModel 생성
  factory FeedingRecordModel.fromJson(Map<String, dynamic> json) {
    return FeedingRecordModel(
      id: json['id'] as String? ?? '',
      petId: json['petId'] as String? ?? '',
      petName: json['petName'] as String? ?? '',
      fedTime: DateTime.parse(json['fedTime'] as String),
      amount: (json['amount'] as num).toDouble(),
      foodType: json['foodType'] as String? ?? '',
      foodBrand: json['foodBrand'] as String? ?? '',
      status: _statusFromString(json['status'] as String?),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'petName': petName,
      'fedTime': fedTime.toIso8601String(),
      'amount': amount,
      'foodType': foodType,
      'foodBrand': foodBrand,
      'status': _statusToString(status),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Entity로 변환
  FeedingRecordEntity toEntity() {
    return FeedingRecordEntity(
      id: id,
      petId: petId,
      petName: petName,
      fedTime: fedTime,
      amount: amount,
      foodType: foodType,
      foodBrand: foodBrand,
      status: status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Entity에서 Model 생성
  factory FeedingRecordModel.fromEntity(FeedingRecordEntity entity) {
    return FeedingRecordModel(
      id: entity.id,
      petId: entity.petId,
      petName: entity.petName,
      fedTime: entity.fedTime,
      amount: entity.amount,
      foodType: entity.foodType,
      foodBrand: entity.foodBrand,
      status: entity.status,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// FeedingStatus를 문자열로 변환
  static String _statusToString(FeedingStatus status) {
    switch (status) {
      case FeedingStatus.completed:
        return 'completed';
      case FeedingStatus.skipped:
        return 'skipped';
      case FeedingStatus.partial:
        return 'partial';
    }
  }

  /// 문자열을 FeedingStatus로 변환
  static FeedingStatus _statusFromString(String? status) {
    switch (status) {
      case 'completed':
        return FeedingStatus.completed;
      case 'skipped':
        return FeedingStatus.skipped;
      case 'partial':
        return FeedingStatus.partial;
      default:
        return FeedingStatus.completed;
    }
  }

  FeedingRecordModel copyWith({
    String? id,
    String? petId,
    String? petName,
    DateTime? fedTime,
    double? amount,
    String? foodType,
    String? foodBrand,
    FeedingStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedingRecordModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      fedTime: fedTime ?? this.fedTime,
      amount: amount ?? this.amount,
      foodType: foodType ?? this.foodType,
      foodBrand: foodBrand ?? this.foodBrand,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FeedingRecordModel(id: $id, petId: $petId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedingRecordModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';

/// AI 즐겨찾기 질문-답변 쌍 엔티티
class AiFavoriteQaEntity {
  final String id;
  final String question; // 사용자의 질문
  final String answer; // AI의 답변
  final PetProfileEntity? pet; // 관련 펫 정보
  final String? categoryId; // 관련 카테고리 ID
  final String? categoryName; // 관련 카테고리 이름
  final DateTime createdAt; // 즐겨찾기 등록일
  final DateTime originalTimestamp; // 원본 대화 시간

  const AiFavoriteQaEntity({
    required this.id,
    required this.question,
    required this.answer,
    this.pet,
    this.categoryId,
    this.categoryName,
    required this.createdAt,
    required this.originalTimestamp,
  });

  /// JSON으로 변환
  ///
  /// 즐겨찾기 QA 엔티티를 JSON 형태로 직렬화합니다.
  /// 로컬 저장소나 API 통신 시 사용됩니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'petId': pet?.id,
      'petName': pet?.name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'createdAt': createdAt.toIso8601String(),
      'originalTimestamp': originalTimestamp.toIso8601String(),
    };
  }

  /// JSON에서 생성
  ///
  /// JSON 데이터로부터 즐겨찾기 QA 엔티티를 생성합니다.
  /// 로컬 저장소나 API 응답에서 데이터를 복원할 때 사용됩니다.
  factory AiFavoriteQaEntity.fromJson(Map<String, dynamic> json) {
    // petId가 있으면 펫 정보를 복원
    PetProfileEntity? pet;
    if (json['petId'] != null) {
      // TODO: Repository를 통해 펫 정보 조회 로직 구현 필요
      // pet = petRepository.findById(json['petId']);
    }

    return AiFavoriteQaEntity(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      pet: pet,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      originalTimestamp: DateTime.parse(json['originalTimestamp'] as String),
    );
  }

  /// 펫별로 그룹화할 때 사용할 키
  String get petGroupKey {
    if (pet != null) {
      return '${pet!.id}_${pet!.name}';
    }
    return 'general_一般的なペット相談';
  }

  /// 펫별로 그룹화할 때 사용할 표시 이름
  String get petDisplayName {
    if (pet != null) {
      return '${pet!.name} (${pet!.breed ?? pet!.type})';
    }
    return '一般的なペット相談';
  }

  /// 복사 생성자
  AiFavoriteQaEntity copyWith({
    String? id,
    String? question,
    String? answer,
    PetProfileEntity? pet,
    String? categoryId,
    String? categoryName,
    DateTime? createdAt,
    DateTime? originalTimestamp,
  }) {
    return AiFavoriteQaEntity(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      pet: pet ?? this.pet,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt ?? this.createdAt,
      originalTimestamp: originalTimestamp ?? this.originalTimestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiFavoriteQaEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AiFavoriteQaEntity(id: $id, question: ${question.substring(0, question.length > 20 ? 20 : question.length)}..., pet: ${pet?.name})';
  }
}

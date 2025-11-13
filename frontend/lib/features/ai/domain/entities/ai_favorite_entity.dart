import 'ai_message_entity.dart';

/// AI 즐겨찾기 엔티티
class AiFavoriteEntity {
  final String id;
  final AiMessageEntity message;
  final String? petId;
  final String? petName;
  final String category; // 건강, 식사, 배변, 생식레시피 등
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userNote; // 유저가 추가한 메모

  const AiFavoriteEntity({
    required this.id,
    required this.message,
    this.petId,
    this.petName,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.userNote,
  });

  AiFavoriteEntity copyWith({
    String? id,
    AiMessageEntity? message,
    String? petId,
    String? petName,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userNote,
  }) {
    return AiFavoriteEntity(
      id: id ?? this.id,
      message: message ?? this.message,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userNote: userNote ?? this.userNote,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiFavoriteEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AiFavoriteEntity(id: $id, category: $category, petName: $petName)';
}

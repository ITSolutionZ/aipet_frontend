import 'ai_message_entity.dart';

/// AI 채팅 요약 엔티티
class AiChatSummaryEntity {
  final String id;
  final String title; // 자동 생성된 제목
  final String summary; // AI가 생성한 요약
  final String category; // 상담 카테고리
  final String? petId;
  final String? petName;
  final List<AiMessageEntity> messages; // 전체 대화 내용
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount; // 메시지 수
  final bool hasFavorites; // 즐겨찾기가 있는지 여부

  const AiChatSummaryEntity({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    this.petId,
    this.petName,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    this.hasFavorites = false,
  });

  AiChatSummaryEntity copyWith({
    String? id,
    String? title,
    String? summary,
    String? category,
    String? petId,
    String? petName,
    List<AiMessageEntity>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
    bool? hasFavorites,
  }) {
    return AiChatSummaryEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      category: category ?? this.category,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
      hasFavorites: hasFavorites ?? this.hasFavorites,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatSummaryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

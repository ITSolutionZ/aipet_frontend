import '../../../pet_registor/pet_registor.dart';
import 'ai_category_entity.dart';
import 'ai_message_entity.dart';

/// AI 채팅 히스토리 엔티티
class AiChatHistoryEntity {
  final String id;
  final String title;
  final String summary;
  final List<AiMessageEntity> messages;
  final PetProfileEntity? pet;
  final AiCategoryEntity? category;
  final DateTime createdAt;
  final bool isManualSaved;
  final int messageCount;

  const AiChatHistoryEntity({
    required this.id,
    required this.title,
    required this.summary,
    required this.messages,
    this.pet,
    this.category,
    required this.createdAt,
    this.isManualSaved = false,
    required this.messageCount,
  });

  AiChatHistoryEntity copyWith({
    String? id,
    String? title,
    String? summary,
    List<AiMessageEntity>? messages,
    PetProfileEntity? pet,
    AiCategoryEntity? category,
    DateTime? createdAt,
    bool? isManualSaved,
    int? messageCount,
  }) {
    return AiChatHistoryEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      messages: messages ?? this.messages,
      pet: pet ?? this.pet,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isManualSaved: isManualSaved ?? this.isManualSaved,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatHistoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
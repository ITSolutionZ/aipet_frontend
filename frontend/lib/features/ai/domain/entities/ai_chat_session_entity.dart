import 'ai_message_entity.dart';

/// AI 채팅 세션 엔티티
class AiChatSessionEntity {
  final String id;
  final String title;
  final List<AiMessageEntity> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? petId;
  final String? petName;

  const AiChatSessionEntity({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.petId,
    this.petName,
  });

  AiChatSessionEntity copyWith({
    String? id,
    String? title,
    List<AiMessageEntity>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? petId,
    String? petName,
  }) {
    return AiChatSessionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatSessionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AiChatSessionEntity(id: $id, title: $title, messages: ${messages.length})';
}

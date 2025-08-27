import 'package:flutter/material.dart';

/// AI 채팅 메시지 타입
enum MessageType {
  user, // 사용자 메시지
  assistant, // AI 어시스턴트 메시지
  system, // 시스템 메시지
}

/// AI 채팅 메시지 엔티티
class AiMessageEntity {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isTyping;
  final String? petId;
  final String? petName;
  final Map<String, dynamic>? metadata; // 추가 메타데이터

  const AiMessageEntity({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isTyping = false,
    this.petId,
    this.petName,
    this.metadata,
  });

  AiMessageEntity copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isTyping,
    String? petId,
    String? petName,
    Map<String, dynamic>? metadata,
  }) {
    return AiMessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 사용자 메시지인지 확인
  bool get isUser => type == MessageType.user;

  /// AI 어시스턴트 메시지인지 확인
  bool get isAssistant => type == MessageType.assistant;

  /// 시스템 메시지인지 확인
  bool get isSystem => type == MessageType.system;
}

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

  /// 메시지 추가
  AiChatSessionEntity addMessage(AiMessageEntity message) {
    final updatedMessages = List<AiMessageEntity>.from(messages)..add(message);
    return copyWith(messages: updatedMessages, updatedAt: DateTime.now());
  }

  /// 마지막 메시지
  AiMessageEntity? get lastMessage {
    return messages.isNotEmpty ? messages.last : null;
  }

  /// 총 메시지 수
  int get messageCount => messages.length;
}

/// AI 추천 질문 엔티티
class AiSuggestedQuestionEntity {
  final String id;
  final String question;
  final String category;
  final IconData icon;
  final String? description;

  const AiSuggestedQuestionEntity({
    required this.id,
    required this.question,
    required this.category,
    required this.icon,
    this.description,
  });
}

/// AI 응답 타입
enum AiResponseType {
  text, // 텍스트 응답
  recommendation, // 추천 사항
  warning, // 경고
  information, // 정보 제공
}

/// AI 응답 메타데이터
class AiResponseMetadata {
  final AiResponseType responseType;
  final double? confidence;
  final List<String>? sources;
  final Map<String, dynamic>? additionalData;

  const AiResponseMetadata({
    required this.responseType,
    this.confidence,
    this.sources,
    this.additionalData,
  });
}

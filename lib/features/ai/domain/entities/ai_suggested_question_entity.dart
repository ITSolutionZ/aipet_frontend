import 'package:flutter/material.dart';

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

  AiSuggestedQuestionEntity copyWith({
    String? id,
    String? question,
    String? category,
    IconData? icon,
    String? description,
  }) {
    return AiSuggestedQuestionEntity(
      id: id ?? this.id,
      question: question ?? this.question,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiSuggestedQuestionEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AiSuggestedQuestionEntity(id: $id, question: $question, category: $category)';
}

/// AI 채팅 요약 결과
class AiChatSummary {
  final String title;
  final String content;

  const AiChatSummary({required this.title, required this.content});

  AiChatSummary copyWith({String? title, String? content}) {
    return AiChatSummary(
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiChatSummary &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          content == other.content;

  @override
  int get hashCode => title.hashCode ^ content.hashCode;

  @override
  String toString() => 'AiChatSummary(title: $title, content: $content)';
}

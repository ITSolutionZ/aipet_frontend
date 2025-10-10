import 'package:flutter/material.dart';

/// YouTube 태그 관리 헬퍼
class YouTubeTagManager {
  /// 태그 추가 검증
  static bool canAddTag(String tag, List<String> existingTags) {
    return tag.isNotEmpty &&
        tag.length <= 20 &&
        !existingTags.contains(tag) &&
        !tag.contains(' ');
  }

  /// 태그 제거
  static List<String> removeTag(String tag, List<String> tags) {
    return tags.where((t) => t != tag).toList();
  }

  /// 태그 추가
  static List<String> addTag(String tag, List<String> tags) {
    if (canAddTag(tag, tags)) {
      return [...tags, tag];
    }
    return tags;
  }

  /// 태그 정렬 (알파벳 순)
  static List<String> sortTags(List<String> tags) {
    final sortedTags = List<String>.from(tags);
    sortedTags.sort();
    return sortedTags;
  }

  /// 태그 중복 제거
  static List<String> removeDuplicates(List<String> tags) {
    return tags.toSet().toList();
  }

  /// 태그 유효성 검사
  static String validateTag(String tag) {
    if (tag.isEmpty) {
      return 'タグを入力してください';
    }

    if (tag.length > 20) {
      return 'タグは20文字以内で入力してください';
    }

    if (tag.contains(' ')) {
      return 'タグにスペースは使用できません';
    }

    return '';
  }

  /// 태그 입력 필드 위젯
  static Widget buildTagInputField({
    required TextEditingController controller,
    required VoidCallback onAdd,
    required String errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'タグを追加',
            hintText: '例: しつけ, トレーニング',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
            ),
            errorText: errorText.isNotEmpty ? errorText : null,
          ),
          onSubmitted: (_) => onAdd(),
        ),
        const SizedBox(height: 8),
        Text(
          'タグは20文字以内で、スペースは使用できません',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  /// 태그 칩 목록 위젯
  static Widget buildTagChips({
    required List<String> tags,
    required Function(String) onRemove,
  }) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map(
            (tag) => Chip(
              label: Text(tag),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => onRemove(tag),
            ),
          )
          .toList(),
    );
  }

  /// 태그 통계 정보
  static Map<String, int> getTagStats(List<String> tags) {
    return {
      'total': tags.length,
      'unique': tags.toSet().length,
      'duplicates': tags.length - tags.toSet().length,
    };
  }

  /// 인기 태그 추천
  static List<String> getPopularTags() {
    return ['しつけ', 'トレーニング', '散歩', '遊び', '健康', '食事', 'グルーミング', 'コミュニケーション'];
  }
}

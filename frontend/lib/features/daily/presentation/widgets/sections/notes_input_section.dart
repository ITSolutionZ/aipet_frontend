import 'package:aipet_frontend/shared/widgets/forms/common_form_field.dart';
import 'package:aipet_frontend/shared/widgets/layout/card_container.dart';
import 'package:flutter/material.dart';

/// 메모 입력 섹션 위젯
class NotesInputSection extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final int maxLines;

  const NotesInputSection({
    super.key,
    required this.controller,
    this.hint,
    this.maxLines = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCardContainer(
      title: 'メモ',
      child: CommonFormField(
        controller: controller,
        label: '',
        hint: hint ?? '追加の詳細や気になる点があれば記録してください...',
        maxLines: maxLines,
      ),
    );
  }
}

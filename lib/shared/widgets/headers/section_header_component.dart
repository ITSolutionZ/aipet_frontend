import 'package:flutter/material.dart';

/// 섹션 헤더 컴포넌트 (범용)
class SectionHeaderComponent extends StatelessWidget {
  final String title;
  final TextStyle? style;

  const SectionHeaderComponent({super.key, required this.title, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style:
          style ??
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
    );
  }
}

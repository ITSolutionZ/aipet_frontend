import 'package:flutter/material.dart';

/// 공통 위젯들
///
/// 프로젝트 전반에서 사용되는 공통 위젯들을 정의합니다.
class CommonWidgets {
  /// 폼 필드 위젯
  static Widget formField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: validator,
        ),
      ],
    );
  }

  /// 섹션 헤더 위젯
  static Widget sectionHeader({required String title, Widget? action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  /// 설정 타일 위젯
  static Widget settingsTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

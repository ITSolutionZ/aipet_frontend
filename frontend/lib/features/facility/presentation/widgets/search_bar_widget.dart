import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';


class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onSearch;
  final VoidCallback? onClear;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onSearch,
    this.onClear,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: '検索',
      hintText: hintText,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: controller.text.isNotEmpty ? const Icon(Icons.clear) : null,
    );
  }
}

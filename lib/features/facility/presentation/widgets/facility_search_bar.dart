import 'package:flutter/material.dart';

class FacilitySearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final String? hintText;

  const FacilitySearchBar({
    super.key,
    this.controller,
    this.onChanged,
    required this.onSearch,
    required this.onClear,
    this.hintText = '施設名で検索...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    controller?.clear();
                    onClear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

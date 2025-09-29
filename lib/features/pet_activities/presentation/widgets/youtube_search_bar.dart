import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// YouTube 검색 바
class YouTubeSearchBar extends StatelessWidget {
  final Function(String) onSearchChanged;

  const YouTubeSearchBar({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const const const EdgeInsets.all(AppSpacing.lg),
      color: Colors.white,
      child: TextField(
        onChanged: onSearchChanged,
        decoration: const InputDecoration(
          hintText: 'ビデオを検索...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: Icon(Icons.filter_list),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppSpacing.md)),
            borderSide: BorderSide(color: AppColors.borderGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppSpacing.md)),
            borderSide: BorderSide(color: AppColors.pointBlue),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }
}

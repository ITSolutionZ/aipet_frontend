import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// YouTube 영상 추가 버튼
class AddYouTubeVideoButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddYouTubeVideoButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: const Text('新しいビデオを追加'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.md)),
        ),
      ),
    );
  }
}

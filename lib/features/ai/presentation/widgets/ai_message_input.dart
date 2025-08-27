import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// AI 메시지 입력 위젯
class AiMessageInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final bool isLoading;

  const AiMessageInput({
    super.key,
    required this.controller,
    required this.onSendMessage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isLoading,
              decoration: InputDecoration(
                hintText: 'あなたのペットについての質問をしてください...',
                hintStyle: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointGray,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  borderSide: BorderSide(
                    color: AppColors.pointGray.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  borderSide: const BorderSide(color: AppColors.pointBrown),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: isLoading ? null : onSendMessage,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: isLoading ? AppColors.pointGray : AppColors.pointBrown,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: isLoading
                  ? null
                  : () => onSendMessage(controller.text),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              splashRadius: 24,
            ),
          ),
        ],
      ),
    );
  }
}

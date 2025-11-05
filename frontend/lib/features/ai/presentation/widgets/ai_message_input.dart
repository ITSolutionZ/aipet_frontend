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
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                ),
                child: TextField(
                  controller: controller,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'ペットについて質問してください...',
                    hintStyle: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointGray,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: isLoading ? null : onSendMessage,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLoading ? AppColors.pointGray : AppColors.pointBrown,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
                splashRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

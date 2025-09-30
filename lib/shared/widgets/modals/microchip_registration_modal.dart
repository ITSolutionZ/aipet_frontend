import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 마이크로칩 등록 권고 모달
class MicrochipRegistrationModal extends StatelessWidget {
  const MicrochipRegistrationModal({
    super.key,
    required this.petName,
    this.onRegisterTap,
    this.onRemindLater,
    this.onDismiss,
  });

  final String petName;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onRemindLater;
  final VoidCallback? onDismiss;

  /// 모달 표시 헬퍼 메소드
  static Future<void> show(
    BuildContext context, {
    required String petName,
    VoidCallback? onRegisterTap,
    VoidCallback? onRemindLater,
    VoidCallback? onDismiss,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MicrochipRegistrationModal(
          petName: petName,
          onRegisterTap: onRegisterTap,
          onRemindLater: onRemindLater,
          onDismiss: onDismiss,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              // 마이크로칩 이미지 - 전체 크기로 표시 (확장)
              Expanded(
                flex: 4,
                child: SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/modal/microchip.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.pointOffWhite.withValues(alpha: 0.3),
                        child: const Center(
                          child: Icon(Icons.pets, size: 100, color: AppColors.pointBlue),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 버튼들
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 등록하기 버튼 (메인 액션)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.pop();
                          onRegisterTap?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pointBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.medium),
                          ),
                        ),
                        child: Text(
                          '今すぐ登録',
                          style: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // 나중에 등록 버튼
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.pop();
                          onRemindLater?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.pointBlue,
                          side: const BorderSide(color: AppColors.pointBlue, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.medium),
                          ),
                        ),
                        child: Text(
                          '後で登録',
                          style: AppFonts.bodyMedium.copyWith(
                            color: AppColors.pointBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // 1주일 후 다시 보기 버튼
                    TextButton(
                      onPressed: () {
                        context.pop();
                        onDismiss?.call();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.pointGray.withValues(alpha: 0.7),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      ),
                      child: Text(
                        '1週間後に再表示',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointGray.withValues(alpha: 0.7),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../shared/shared.dart';

/// 마이크로칩 등록 배너 위젯
class MicrochipRegistrationBanner extends StatelessWidget {
  final VoidCallback? onRegisterTap;
  final VoidCallback? onDismiss;
  final String? petType;
  final bool isModal;

  const MicrochipRegistrationBanner({
    super.key,
    this.onRegisterTap,
    this.onDismiss,
    this.petType,
    this.isModal = false,
  });

  /// 모달로 표시하는 정적 메서드
  static Future<void> showModal(
    BuildContext context, {
    String? petType,
    VoidCallback? onRegisterTap,
    VoidCallback? onDismiss,
  }) {
    // 마이크로칩 의무는 개와 고양이만 해당하므로, 다른 동물일 때는 모달을 표시하지 않음
    if (petType != 'dog' && petType != 'cat') {
      return Future.value();
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MicrochipRegistrationBanner(
          petType: petType,
          onRegisterTap: onRegisterTap,
          onDismiss: onDismiss,
          isModal: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 마이크로칩 의무는 개와 고양이만 해당하므로, 다른 동물일 때는 표시하지 않음
    if (!_shouldShowMicrochipBanner()) {
      return const SizedBox.shrink();
    }

    if (isModal) {
      return _buildModalContent(context);
    } else {
      return _buildBannerContent();
    }
  }

  /// 모달 콘텐츠 빌드
  Widget _buildModalContent(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 이미지 섹션
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(),
                  child: Image.asset(
                    _getMicrochipImagePath(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.pointOffWhite,
                        child: const Icon(
                          Icons.pets,
                          size: 60,
                          color: AppColors.pointBrown,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 하단 버튼 섹션
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 등록 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onRegisterTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pointBrown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.medium,
                              ),
                            ),
                          ),
                          child: Text(
                            '登録する',
                            style: AppFonts.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // 닫기 버튼
                      if (onDismiss != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onDismiss?.call();
                            },
                            child: Text(
                              '後で',
                              style: AppFonts.bodyMedium.copyWith(
                                color: AppColors.pointGray,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 배너 콘텐츠 빌드
  Widget _buildBannerContent() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상단 이미지 섹션
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.large),
                topRight: Radius.circular(AppRadius.large),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.large),
                topRight: Radius.circular(AppRadius.large),
              ),
              child: Image.asset(
                _getMicrochipImagePath(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.pointOffWhite,
                    child: const Icon(
                      Icons.pets,
                      size: 60,
                      color: AppColors.pointBrown,
                    ),
                  );
                },
              ),
            ),
          ),

          // 하단 버튼 섹션
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // 등록 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRegisterTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    child: Text(
                      '登録する',
                      style: AppFonts.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // 닫기 버튼
                if (onDismiss != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: TextButton(
                      onPressed: onDismiss,
                      child: Text(
                        '後で',
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.pointGray,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 마이크로칩 배너를 표시해야 하는지 확인
  bool _shouldShowMicrochipBanner() {
    // 마이크로칩 의무는 개와 고양이만 해당
    return petType == 'dog' || petType == 'cat';
  }

  /// 펫 타입에 따른 마이크로칩 이미지 경로 반환
  String _getMicrochipImagePath() {
    switch (petType) {
      case 'dog':
        return 'assets/images/modal/microchip_dog.png';
      case 'cat':
        return 'assets/images/modal/microchip_cat.png';
      default:
        // 이 경우는 더 이상 발생하지 않음 (개/고양이만 표시)
        return 'assets/images/modal/microchip_dog.png';
    }
  }
}

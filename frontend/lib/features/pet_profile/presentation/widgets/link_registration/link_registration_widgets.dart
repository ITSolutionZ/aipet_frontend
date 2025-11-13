import 'package:aipet_frontend/features/pet_profile/presentation/controllers/link_registration_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 링크 등록 화면의 UI 위젯들
/// 로직과 UI 완전 분리

/// 안내 텍스트 카드
class LinkRegistrationInfoCard extends StatelessWidget {
  const LinkRegistrationInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pointBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: AppColors.pointBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.pointBlue, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              '他のユーザーが共有したペットプロフィールリンクを入力して追加できます。',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
            ),
          ),
        ],
      ),
    );
  }
}

/// 링크 입력 필드
class LinkInputField extends ConsumerWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const LinkInputField({super.key, required this.controller, this.validator});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '共有リンク',
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'https://aipet.app/share/...',
            hintStyle: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              borderSide: BorderSide(
                color: AppColors.pointDark.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              borderSide: BorderSide(
                color: AppColors.pointDark.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              borderSide: const BorderSide(
                color: AppColors.pointBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              borderSide: const BorderSide(color: Colors.red),
            ),
            suffixIcon: IconButton(
              onPressed: () => _pasteFromClipboard(controller, ref),
              icon: const Icon(Icons.paste, color: AppColors.pointBlue),
            ),
          ),
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'クリップボードから貼り付け',
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _pasteFromClipboard(
    TextEditingController controller,
    WidgetRef ref,
  ) async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      controller.text = clipboardData!.text!;
      ref
          .read(linkRegistrationControllerProvider.notifier)
          .updateLink(clipboardData.text!);
    }
  }
}

/// 예시 링크 카드
class ExampleLinksCard extends StatelessWidget {
  const ExampleLinksCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.toneOffWhite,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '例リンク',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...[
            'https://example.com/mydog',
            'https://petagram.com/fluffy',
            'https://instagram.com/my_cat_photos',
          ].map(
            (link) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                link,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointDark.withValues(alpha: 0.7),
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 등록 버튼
class LinkRegistrationButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const LinkRegistrationButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkState = ref.watch(linkRegistrationControllerProvider);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: linkState.isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
          disabledBackgroundColor: AppColors.pointDark.withValues(alpha: 0.3),
        ),
        child: linkState.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'ペットプロフィール追加',
                style: AppFonts.fredoka(
                  fontSize: AppFonts.lg,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

/// 성공 다이얼로그
class LinkRegistrationSuccessDialog extends StatelessWidget {
  final Map<String, dynamic>? petData;

  const LinkRegistrationSuccessDialog({super.key, this.petData});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.pointGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          const Text('登録成功'),
        ],
      ),
      content: const Text('ペットプロフィールが正常に追加されました。\nペットの情報を確認できます。'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('確認'),
        ),
      ],
    );
  }
}

/// 에러 다이얼로그
class LinkRegistrationErrorDialog extends StatelessWidget {
  final String error;

  const LinkRegistrationErrorDialog({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          const Text('登録失敗'),
        ],
      ),
      content: Text('リンク登録に失敗しました。\n$error'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('確認'),
        ),
      ],
    );
  }
}

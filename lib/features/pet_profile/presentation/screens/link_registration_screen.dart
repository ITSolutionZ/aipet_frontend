import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/services/link_registration_service.dart';
import '../../../../shared/shared.dart';

/// 링크 등록 화면
///
/// 사용자가 직접 링크를 입력하여 펫 프로필을 추가할 수 있는 화면입니다.
class LinkRegistrationScreen extends StatefulWidget {
  const LinkRegistrationScreen({super.key});

  @override
  State<LinkRegistrationScreen> createState() => _LinkRegistrationScreenState();
}

class _LinkRegistrationScreenState extends State<LinkRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _linkController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  /// 링크 검증
  String? _validateLink(String? value) {
    if (value == null || value.isEmpty) {
      return 'リンクを入力してください';
    }

    // URL 형식 검증
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      return '正しいリンク形式ではありません';
    }

    // aipet.app 도메인 검증
    if (!LinkRegistrationService.isValidLink(value)) {
      return 'AI Petアプリの共有リンクではありません';
    }

    return null;
  }

  /// 링크 등록 처리
  Future<void> _registerLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 링크 등록 서비스 호출
      final result = await LinkRegistrationService.registerLink(
        _linkController.text,
      );

      if (mounted) {
        if (result['success'] == true) {
          _showSuccessDialog(result['petData']);
        } else {
          _showErrorDialog('リンクの処理に失敗しました');
        }
      }
    } catch (error) {
      if (mounted) {
        _showErrorDialog(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 성공 다이얼로그 표시
  void _showSuccessDialog([Map<String, dynamic>? petData]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
            const Text('등록 성공'),
          ],
        ),
        content: const Text('ペットプロフィールが正常に追加されました。\nペットの情報を確認できます。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }

  /// 에러 다이얼로그 표시
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  /// 클립보드에서 링크 붙여넣기
  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      setState(() {
        _linkController.text = clipboardData!.text!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointOffWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.pointDark,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'リンクで登録',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 안내 텍스트
              Container(
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
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.pointBlue,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        '他のユーザーが共有したペットプロフィールリンクを入力して追加できます。',
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.pointDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 링크 입력 필드
              Text(
                '共有リンク',
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _linkController,
                validator: _validateLink,
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
                    onPressed: _pasteFromClipboard,
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
              const SizedBox(height: AppSpacing.xl),

              // 예시 링크
              Container(
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
                    ...MockDataService.getMockExampleLinks().map(
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
              ),
              const SizedBox(height: AppSpacing.xl * 2),

              // 등록 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    disabledBackgroundColor: AppColors.pointDark.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

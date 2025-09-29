import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 🎯 Link Registration State Provider
final linkRegistrationProvider =
    StateNotifierProvider<LinkRegistrationController, LinkRegistrationState>(
      (ref) => LinkRegistrationController(),
    );

class LinkRegistrationController extends StateNotifier<LinkRegistrationState> {
  LinkRegistrationController() : super(const LinkRegistrationState());

  void updateLink(String link) {
    state = state.copyWith(link: link);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// 링크 검증
  String? validateLink(String? value) {
    if (value == null || value.isEmpty) {
      return 'リンクを入力してください';
    }

    // URL 형식 검증
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      return '正しいリンク形式ではありません';
    }

    // aipet.app 도메인 검증 - Mock implementation since service is missing
    if (!value.contains('aipet.app') && !value.contains('example.com')) {
      return 'AI Petアプリの共有リンクではありません';
    }

    return null;
  }

  /// 링크 등록 처리
  Future<Map<String, dynamic>> registerLink(String link) async {
    setLoading(true);

    try {
      // Mock implementation since LinkRegistrationService is not available
      await Future.delayed(const Duration(seconds: 1));

      // Simulate success
      return {
        'success': true,
        'petData': {'name': 'Test Pet', 'type': 'dog'},
      };
    } catch (error) {
      return {'success': false, 'error': error.toString()};
    } finally {
      setLoading(false);
    }
  }
}

class LinkRegistrationState {
  final String link;
  final bool isLoading;

  const LinkRegistrationState({this.link = '', this.isLoading = false});

  LinkRegistrationState copyWith({String? link, bool? isLoading}) {
    return LinkRegistrationState(
      link: link ?? this.link,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 링크 등록 화면
///
/// 사용자가 직접 링크를 입력하여 펫 프로필을 추가할 수 있는 화면입니다.
class LinkRegistrationScreen extends ConsumerStatefulWidget {
  const LinkRegistrationScreen({super.key});

  @override
  ConsumerState<LinkRegistrationScreen> createState() =>
      _LinkRegistrationScreenState();
}

class _LinkRegistrationScreenState
    extends ConsumerState<LinkRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _linkController.addListener(() {
      ref
          .read(linkRegistrationProvider.notifier)
          .updateLink(_linkController.text);
    });
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  /// 링크 검증
  String? _validateLink(String? value) {
    return ref.read(linkRegistrationProvider.notifier).validateLink(value);
  }

  /// 링크 등록 처리
  Future<void> _registerLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final result = await ref
          .read(linkRegistrationProvider.notifier)
          .registerLink(_linkController.text);

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
            const Text('登録成功'),
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
      _linkController.text = clipboardData!.text!;
      ref
          .read(linkRegistrationProvider.notifier)
          .updateLink(clipboardData.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkState = ref.watch(linkRegistrationProvider);
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientBackAppBar(title: 'リンクで登録'),
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
              ),
              const SizedBox(height: AppSpacing.xl * 2),

              // 등록 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: linkState.isLoading ? null : _registerLink,
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
                  child: linkState.isLoading
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

import 'package:aipet_frontend/shared/core/services/snackbar_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// お問い合わせフォーム画面
/// ユーザーからの問い合わせを受け付ける
class ContactFormScreen extends ConsumerStatefulWidget {
  const ContactFormScreen({super.key});

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedCategory = 'general';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SoftGradientAppBar(
        title: 'お問い合わせ',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー説明
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.pointBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  border: Border.all(
                    color: AppColors.pointBlue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.support_agent,
                          color: AppColors.pointBlue,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'お問い合わせフォーム',
                          style: AppFonts.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.pointBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'ご質問やサポートが必要な場合は、以下のフォームからお気軽にお問い合わせください。',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // カテゴリ選択
              Text(
                'お問い合わせカテゴリ',
                style: AppFonts.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildCategoryDropdown(),

              const SizedBox(height: AppSpacing.lg),

              // お名前
              CommonFormField(
                controller: _nameController,
                label: 'お名前',
                hint: '例：田中太郎',
                validator: _validateName,
              ),

              const SizedBox(height: AppSpacing.lg),

              // メールアドレス
              CommonFormField(
                controller: _emailController,
                label: 'メールアドレス',
                hint: '例：tanaka@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),

              const SizedBox(height: AppSpacing.lg),

              // 件名
              CommonFormField(
                controller: _subjectController,
                label: '件名',
                hint: '例：アプリの使い方について',
                validator: _validateSubject,
              ),

              const SizedBox(height: AppSpacing.lg),

              // メッセージ
              CommonFormField(
                controller: _messageController,
                label: 'メッセージ',
                hint: 'お問い合わせ内容を詳しくお書きください',
                maxLines: 5,
                validator: _validateMessage,
              ),

              const SizedBox(height: AppSpacing.xl),

              // 送信ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
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
                          '送信する',
                          style: AppFonts.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 連絡先情報
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(
                    color: AppColors.borderGray.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'その他の連絡方法',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'メール: support@aipet.com\n電話: 03-1234-5678\n営業時間: 平日 9:00-18:00',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
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

  /// カテゴリ選択ドロップダウン
  Widget _buildCategoryDropdown() {
    final categories = {
      'general': '一般的なお問い合わせ',
      'technical': '技術的な問題',
      'billing': '料金・請求について',
      'feature': '機能の要望',
      'bug': 'バグ報告',
      'other': 'その他',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          items: categories.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
      ),
    );
  }

  /// 名前検証
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'お名前を入力してください';
    }
    if (value.trim().length < 2) {
      return 'お名前は2文字以上で入力してください';
    }
    return null;
  }

  /// メール検証
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'メールアドレスを入力してください';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return '正しいメールアドレスを入力してください';
    }
    return null;
  }

  /// 件名検証
  String? _validateSubject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '件名を入力してください';
    }
    if (value.trim().length < 5) {
      return '件名は5文字以上で入力してください';
    }
    return null;
  }

  /// メッセージ検証
  String? _validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'メッセージを入力してください';
    }
    if (value.trim().length < 10) {
      return 'メッセージは10文字以上で入力してください';
    }
    return null;
  }

  /// フォーム送信
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: 実際の送信処理を実装
      await Future.delayed(const Duration(seconds: 2)); // シミュレーション

      if (mounted) {
        // ✅ Shared SnackBarService 사용
        SnackBarService.showSuccess(context, 'お問い合わせを送信しました');

        // フォームをリセット
        _formKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
        setState(() {
          _selectedCategory = 'general';
        });
      }
    } catch (e) {
      if (mounted) {
        // ✅ Shared SnackBarService 사용
        SnackBarService.showError(
          context,
          '送信に失敗しました。もう一度お試しください',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

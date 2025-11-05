import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../../shared/shared.dart';
import '../../../data/data.dart';
import '../../state/auth_form_state.dart';
import '../error_message.dart' as auth_error;


/// ログインフォームセクション
///
/// メールアドレスとパスワード入力フォーム
class LoginFormSection extends ConsumerStatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const LoginFormSection({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  ConsumerState<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends ConsumerState<LoginFormSection> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authFormStateNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // メールアドレス入力
        _buildEmailField(authState),
        const SizedBox(height: AppSpacing.md),

        // パスワード入力
        _buildPasswordField(),
        const SizedBox(height: AppSpacing.md),

        // Remember Me チェックボックス
        _buildRememberMeCheckbox(authState),
        const SizedBox(height: AppSpacing.lg),

        // エラーメッセージ表示
        if (authState.error != null) ...[
          auth_error.ErrorMessage(
            message: authState.error!,
            type: auth_error.ErrorType.error,
            onDismiss: () {
              ref.read(authFormStateNotifierProvider.notifier).clearError();
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ログインボタン
        _buildLoginButton(),
      ],
    );
  }

  /// メールアドレス入力フィールド
  Widget _buildEmailField(AuthFormState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'メールアドレス',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !widget.isLoading,
          decoration: const InputDecoration(
            hintText: 'メールアドレスを入力してください',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'メールアドレスを入力してください';
            }
            if (!_isValidEmail(value)) {
              return '有効なメールアドレスを入力してください';
            }
            return null;
          },
          onChanged: (value) {
            ref.read(authFormStateNotifierProvider.notifier).updateEmail(value);
          },
        ),
      ],
    );
  }

  /// パスワード入力フィールド
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'パスワード',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.passwordController,
          obscureText: !_isPasswordVisible,
          enabled: !widget.isLoading,
          decoration: InputDecoration(
            hintText: 'パスワードを入力してください',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'パスワードを入力してください';
            }
            if (value.length < 6) {
              return 'パスワードは6文字以上で入力してください';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Remember Me チェックボックス
  Widget _buildRememberMeCheckbox(AuthFormState authState) {
    return Row(
      children: [
        Checkbox(
          value: authState.rememberMe,
          onChanged: widget.isLoading
              ? null
              : (value) {
                  ref
                      .read(authFormStateNotifierProvider.notifier)
                      .toggleRememberMe();
                },
        ),
        const Text('ログイン情報を保存'),
      ],
    );
  }

  /// ログインボタン
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'ログイン',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// メールアドレス有効性検査
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }
}

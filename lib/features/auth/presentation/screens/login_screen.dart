import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/auth/data/auth_providers.dart';
import 'package:aipet_frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:aipet_frontend/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:aipet_frontend/features/auth/presentation/widgets/error_message.dart'
    as auth_error;
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 로그인 화면
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 저장된 로그인 정보 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authFormStateNotifierProvider.notifier).loadSavedCredentials();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authFormStateNotifierProvider);

    // 저장된 이메일이 있으면 컨트롤러에 설정
    if (authState.email.isNotEmpty && _emailController.text.isEmpty) {
      _emailController.text = authState.email;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 로고 섹션
                const Column(
                  children: [
                    SizedBox(height: AppSpacing.lg),
                    AuthLogo(),
                    SizedBox(height: AppSpacing.lg),
                    Divider(),
                    SizedBox(height: AppSpacing.lg),
                  ],
                ),

                // 입력 섹션
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이메일 입력
                    Text(
                      'メールアドレス',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
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
                        ref
                            .read(authFormStateNotifierProvider.notifier)
                            .updateEmail(value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 패스워드 입력
                    Text(
                      'パスワード',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: 'パスワードを入力してください',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
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
                    const SizedBox(height: AppSpacing.md),

                    // Remember Me 체크박스
                    Row(
                      children: [
                        Checkbox(
                          value: authState.rememberMe,
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  ref
                                      .read(
                                        authFormStateNotifierProvider.notifier,
                                      )
                                      .toggleRememberMe();
                                },
                        ),
                        const Text('ログイン情報を保存'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 에러 메시지 표시
                    if (authState.error != null) ...[
                      auth_error.ErrorMessage(
                        message: authState.error!,
                        type: auth_error.ErrorType.error,
                        onDismiss: () {
                          ref
                              .read(authFormStateNotifierProvider.notifier)
                              .clearError();
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pointBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
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
                            : Text(
                                'ログイン',
                                style: AppFonts.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 소셜 로그인 섹션
                    const AuthDivider(text: 'または'),
                    const SizedBox(height: AppSpacing.md),

                    // Google 로그인 버튼
                    SocialLoginButton(
                      onPressed: _isLoading ? null : () => _handleGoogleLogin(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login),
                          SizedBox(width: AppSpacing.sm),
                          Text('Googleでログイン'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Apple 로그인 버튼
                    SocialLoginButton(
                      onPressed: _isLoading ? null : () => _handleAppleLogin(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.apple),
                          SizedBox(width: AppSpacing.sm),
                          Text('Appleでログイン'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // LINE 로그인 버튼
                    SocialLoginButton(
                      onPressed: _isLoading ? null : () => _handleLineLogin(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat),
                          SizedBox(width: AppSpacing.sm),
                          Text('LINEでログイン'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 회원가입 링크
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'アカウントをお持ちでない方は',
                          style: AppFonts.bodySmall.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  context.go(AppRouter.signupRoute);
                                },
                          child: Text(
                            '新規登録',
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 이메일/패스워드 로그인 처리
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = AuthController(ref);
      final result = await authController.login(
        password: _passwordController.text,
      );

      if (result.isSuccess) {
        // 로그인 성공
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
          context.go(AppRouter.homeRoute);
        }
      } else {
        // 로그인 실패
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ログインに失敗しました: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Google 로그인 처리
  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authController = AuthController(ref);
      final result = await authController.loginWithGoogle();

      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
          context.go(AppRouter.homeRoute);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Googleログインに失敗しました: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Apple 로그인 처리
  Future<void> _handleAppleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authController = AuthController(ref);
      final result = await authController.loginWithApple();

      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
          context.go(AppRouter.homeRoute);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appleログインに失敗しました: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// LINE 로그인 처리
  Future<void> _handleLineLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authController = AuthController(ref);
      final result = await authController.loginWithLine();

      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
          context.go(AppRouter.homeRoute);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('LINEログインに失敗しました: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 이메일 유효성 검사
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }
}

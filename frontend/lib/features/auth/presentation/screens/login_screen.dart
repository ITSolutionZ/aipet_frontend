import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../data/data.dart';
import '../../data/services/firebase_token_service.dart';
import '../controllers/auth_controller.dart';
import '../widgets/login/login_form_section.dart';
import '../widgets/login/login_logo_section.dart';
import '../widgets/login/social_login_section.dart';



/// ログイン画面
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 保存されたログイン情報を読み込む
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authFormStateNotifierProvider.notifier).loadSavedCredentials();

      // アプリロックが設定されている場合、ロック解除ダイアログを表示
      _checkAppLock();
    });
  }

  Future<void> _checkAppLock() async {
    // ✅ SecureStorageService 使用でClean Architecture準拠
    final pinEnabled =
        await SecureStorageService.getBool('pin_enabled') ?? false;
    final biometricEnabled =
        await SecureStorageService.getBool('biometric_enabled') ?? false;

    if ((pinEnabled || biometricEnabled) && mounted) {
      unawaited(
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AppLockDialog(
            enablePin: pinEnabled,
            enableBiometric: biometricEnabled,
            onSuccess: () {
              // PIN/生体認証成功 - 自動ログイン実行
              _autoLogin();
            },
          ),
        ),
      );
    }
  }

  /// PIN/生体認証成功時の自動ログイン
  Future<void> _autoLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);
      final result = await authController.login(
        password: '', // 開発用 空値で自動ログイン
      );

      if (result.isSuccess) {
        if (mounted) {
          SnackBarService.showSuccess(context, 'ログインしました');
          context.go(AppRouter.homeRoute);
        }
      } else {
        if (mounted) {
          SnackBarService.showError(context, result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, 'ログインに失敗しました: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

    // 保存されたメールアドレスがあればコントローラーに設定
    if (authState.email.isNotEmpty && _emailController.text.isEmpty) {
      _emailController.text = authState.email;
    }

    // メディアクエリで画面サイズを取得
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    // 画面サイズに応じた動的サイズ計算
    final logoSize = isSmallScreen ? 100.0 : 120.0;
    final verticalSpacing = isSmallScreen ? AppSpacing.md : AppSpacing.lg;

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
                // ロゴセクション
                LoginLogoSection(
                  logoSize: logoSize,
                  verticalSpacing: verticalSpacing,
                ),

                // ログインフォームセクション
                LoginFormSection(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isLoading: _isLoading,
                  onSubmit: _handleLogin,
                ),
                const SizedBox(height: AppSpacing.md),

                // ソーシャルログインセクション
                SocialLoginSection(
                  isLoading: _isLoading,
                  onGoogleLogin: _handleGoogleLogin,
                  onAppleLogin: _handleAppleLogin,
                  onLineLogin: _handleLineLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// メールアドレス/パスワードログイン処理
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);
      final result = await authController.login(
        password: _passwordController.text,
      );

      if (result.isSuccess) {
        // ログイン成功
        LoggerService.debug('🎯 メールログイン成功！トークンデバッグ開始...');

        // Firebase Authの状態が更新されるまで少し待機
        await Future.delayed(const Duration(milliseconds: 500));

        // 🧪 テスト用：Firebase トークンをデバッグプリント
        try {
          LoggerService.debug('🔍 debugFullToken()を呼び出します...');
          await FirebaseTokenService.debugFullToken();
          LoggerService.debug('✅ debugFullToken()完了');
        } catch (e) {
          LoggerService.debug('❌ debugFullToken エラー: $e');
          // エラーでもスタックトレースを表示
          LoggerService.debug('スタックトレース: ${StackTrace.current}');
        }

        if (mounted) {
          SnackBarService.showSuccess(context, result.data ?? 'ログインしました');
          context.go(AppRouter.homeRoute);
        }
      } else {
        // ログイン失敗
        if (mounted) {
          SnackBarService.showError(context, result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, 'ログインに失敗しました: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Google ログイン処理
  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);
      final result = await authController.loginWithGoogle();

      if (result.isSuccess) {
        LoggerService.debug('🎯 Googleログイン成功！トークンデバッグ開始...');

        // Firebase Authの状態が更新されるまで少し待機
        await Future.delayed(const Duration(milliseconds: 500));

        // 🧪 テスト用：Firebase トークンをデバッグプリント
        try {
          LoggerService.debug('🔍 debugFullToken()を呼び出します...');
          await FirebaseTokenService.debugFullToken();
          LoggerService.debug('✅ debugFullToken()完了');
        } catch (e) {
          LoggerService.debug('❌ debugFullToken エラー: $e');
        }

        if (mounted) {
          SnackBarService.showSuccess(context, result.data ?? 'ログインしました');
          context.go(AppRouter.homeRoute);
        }
      } else {
        if (mounted) {
          SnackBarService.showError(context, result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          'Googleログインに失敗しました: ${e.toString()}',
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

  /// Apple ログイン処理
  Future<void> _handleAppleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);
      final result = await authController.loginWithApple();

      if (result.isSuccess) {
        LoggerService.debug('🎯 Appleログイン成功！トークンデバッグ開始...');

        // Firebase Authの状態が更新されるまで少し待機
        await Future.delayed(const Duration(milliseconds: 500));

        // 🧪 テスト用：Firebase トークンをデバッグプリント
        try {
          LoggerService.debug('🔍 debugFullToken()を呼び出します...');
          await FirebaseTokenService.debugFullToken();
          LoggerService.debug('✅ debugFullToken()完了');
        } catch (e) {
          LoggerService.debug('❌ debugFullToken エラー: $e');
        }

        if (mounted) {
          SnackBarService.showSuccess(context, result.data ?? 'ログインしました');
          context.go(AppRouter.homeRoute);
        }
      } else {
        if (mounted) {
          SnackBarService.showError(context, result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, 'Appleログインに失敗しました: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// LINE ログイン処理
  Future<void> _handleLineLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);
      final result = await authController.loginWithLine();

      if (result.isSuccess) {
        if (mounted) {
          SnackBarService.showSuccess(context, result.data ?? 'ログインしました');
          context.go(AppRouter.homeRoute);
        }
      } else {
        if (mounted) {
          SnackBarService.showError(context, result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, 'LINEログインに失敗しました: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../shared/shared.dart';
import '../application/auth_controller.dart';
import 'api_connection_checker.dart';
import 'firebase_login_button.dart';
import 'widgets/token/token_action_buttons.dart';
import 'widgets/token/token_exchange_status_card.dart';
import 'widgets/token/token_status_card.dart';


/// 拡張トークン交換ボタン - 有効期限表示と自動更新通知
class EnhancedExchangeTokenButton extends ConsumerStatefulWidget {
  const EnhancedExchangeTokenButton({super.key});

  @override
  ConsumerState<EnhancedExchangeTokenButton> createState() =>
      _EnhancedExchangeTokenButtonState();
}

class _EnhancedExchangeTokenButtonState
    extends ConsumerState<EnhancedExchangeTokenButton> {
  DateTime? _tokenExpiry;
  bool _isExpired = false;
  bool _isExpiringSoon = false;

  @override
  void initState() {
    super.initState();
    _checkTokenStatus();
  }

  Future<void> _checkTokenStatus() async {
    final controller = ref.read(authControllerProvider.notifier);

    final expiry = await controller.getTokenExpiry();
    final expired = await controller.isTokenExpired();
    final expiringSoon = await controller.isTokenExpiringSoon();

    if (mounted) {
      setState(() {
        _tokenExpiry = expiry;
        _isExpired = expired;
        _isExpiringSoon = expiringSoon;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 Enhanced Token Exchange'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.grey.shade100, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // API 接続状態確認
              const ApiConnectionChecker(),
              const SizedBox(height: 24),

              // Firebase ログインボタン
              FirebaseLoginButton(
                onLoginSuccess: () {
                  // ログイン成功時にトークンステータスを更新
                  _checkTokenStatus();
                },
              ),
              const SizedBox(height: 24),

              // トークンステータスカード
              TokenStatusCard(
                tokenExpiry: _tokenExpiry,
                isExpired: _isExpired,
                isExpiringSoon: _isExpiringSoon,
              ),
              const SizedBox(height: 24),

              // トークン交換ステータスカード
              TokenExchangeStatusCard(state: tokenState),
              const SizedBox(height: 32),

              // トークン交換ボタン
              TokenExchangeButton(
                isLoading: tokenState.isLoading,
                onPressed: () => _handleTokenExchange(context),
              ),
              const SizedBox(height: 16),

              // トークンリフレッシュボタン
              TokenRefreshButton(
                onPressed: _checkTokenStatus,
              ),
              const SizedBox(height: 16),

              // リセットボタン
              if (tokenState.isSuccess || tokenState.errorMessage != null)
                TokenResetButton(
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).reset();
                    _checkTokenStatus();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// トークン交換処理
  Future<void> _handleTokenExchange(BuildContext context) async {
    await ref.read(authControllerProvider.notifier).exchangeServerToken();

    // トークンステータス更新
    await _checkTokenStatus();

    if (context.mounted) {
      final newState = ref.read(authControllerProvider);
      if (newState.isSuccess) {
        SnackBarService.showSuccess(context, '✅ サーバーJWT保存完了!');
      } else if (newState.errorMessage != null) {
        SnackBarService.showError(context, '❌ ${newState.errorMessage}');
      }
    }
  }
}

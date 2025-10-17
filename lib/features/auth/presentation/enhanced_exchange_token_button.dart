import 'package:aipet_frontend/features/auth/application/auth_controller.dart';
import 'package:aipet_frontend/shared/widgets/layout/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_connection_checker.dart'; // Changed
import 'firebase_login_button.dart'; // Changed

/// 개선된 토큰 교환 버튼 - 만료 시간 표시 및 자동 갱신 알림
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
              // API 연결 상태 확인 // Changed
              const ApiConnectionChecker(),
              const SizedBox(height: 24),

              // Firebase 로그인 버튼 // Changed
              FirebaseLoginButton(
                onLoginSuccess: () {
                  // 로그인 성공 시 토큰 상태 새로고침
                  _checkTokenStatus();
                },
              ),
              const SizedBox(height: 24),

              // 토큰 상태 카드 // Changed
              _buildTokenStatusCard(),
              const SizedBox(height: 24),

              // 기존 상태 표시 카드
              _buildStatusCard(tokenState),
              const SizedBox(height: 32),

              // 교환 버튼
              _buildExchangeButton(context, ref, tokenState),
              const SizedBox(height: 16),

              // 상태 새로고침 버튼 // Changed
              _buildRefreshButton(),
              const SizedBox(height: 16),

              // 리셋 버튼
              if (tokenState.isSuccess || tokenState.errorMessage != null)
                _buildResetButton(ref),
            ],
          ),
        ),
      ),
    );
  }

  /// 토큰 상태 카드 // Changed
  Widget _buildTokenStatusCard() {
    IconData icon;
    String title;
    String subtitle;
    Color iconColor;
    Gradient cardGradient;

    if (_tokenExpiry == null) {
      icon = Icons.help_outline;
      title = '토큰 없음';
      subtitle = '아직 토큰이 저장되지 않았습니다';
      iconColor = Colors.grey.shade600;
      cardGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.grey.withAlpha(40), Colors.grey.withAlpha(20)],
      );
    } else if (_isExpired) {
      icon = Icons.timer_off;
      title = '토큰 만료됨';
      subtitle = '토큰이 만료되었습니다. 다시 교환해주세요';
      iconColor = Colors.red.shade600;
      cardGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.red.withAlpha(60), Colors.red.withAlpha(30)],
      );
    } else if (_isExpiringSoon) {
      icon = Icons.warning;
      title = '토큰 곧 만료';
      subtitle = '5분 내에 토큰이 만료됩니다';
      iconColor = Colors.orange.shade600;
      cardGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.orange.withAlpha(60), Colors.orange.withAlpha(30)],
      );
    } else {
      icon = Icons.check_circle;
      title = '토큰 유효';
      subtitle = '만료: ${_formatExpiry(_tokenExpiry!)}';
      iconColor = Colors.green.shade600;
      cardGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.green.withAlpha(60), Colors.green.withAlpha(30)],
      );
    }

    return GlassCard(
      gradient: cardGradient,
      child: Row(
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 상태 새로고침 버튼 // Changed
  Widget _buildRefreshButton() {
    return GlassCard(
      onTap: _checkTokenStatus,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.cyan.withAlpha(40), Colors.cyan.withAlpha(20)],
      ),
      borderColor: Colors.cyan.shade300,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, color: Colors.cyan.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              '토큰 상태 새로고침',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.cyan.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatExpiry(DateTime expiry) {
    final now = DateTime.now();
    final difference = expiry.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 후';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 후';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 후';
    } else {
      return '곧 만료';
    }
  }

  // 기존 메서드들 유지
  Widget _buildStatusCard(TokenExchangeState state) {
    IconData icon;
    String title;
    String? subtitle;
    Color iconColor;
    Gradient cardGradient;

    if (state.isLoading) {
      icon = Icons.sync;
      title = '토큰 교환 중...';
      subtitle = '서버와 통신 중입니다';
      iconColor = Colors.orange.shade600;
      cardGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.orange.withAlpha(60), Colors.orange.withAlpha(30)],
      );
    } else if (state.isSuccess) {
      icon = Icons.check_circle;
      title = '토큰 저장 완료';
      subtitle = '서버 JWT가 안전하게 저장되었습니다';
      iconColor = Colors.green.shade600;
      cardGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.green.withAlpha(60), Colors.green.withAlpha(30)],
      );
    } else if (state.errorMessage != null) {
      icon = Icons.error;
      title = '실패';
      subtitle = state.errorMessage;
      iconColor = Colors.red.shade600;
      cardGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.red.withAlpha(60), Colors.red.withAlpha(30)],
      );
    } else {
      icon = Icons.info;
      title = '준비 완료';
      subtitle = 'Firebase 로그인 후 버튼을 눌러주세요';
      iconColor = Colors.blue.shade600;
      cardGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.blue.withAlpha(40), Colors.blue.withAlpha(20)],
      );
    }

    return GlassCard.panel(
      gradient: cardGradient,
      child: Column(
        children: [
          if (state.isLoading)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            )
          else
            Icon(icon, size: 48, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExchangeButton(
    BuildContext context,
    WidgetRef ref,
    TokenExchangeState state,
  ) {
    return GlassCard(
      onTap: state.isLoading
          ? null
          : () async {
              await ref
                  .read(authControllerProvider.notifier)
                  .exchangeServerToken();

              // 토큰 상태 새로고침 // Changed
              await _checkTokenStatus();

              if (context.mounted) {
                final newState = ref.read(authControllerProvider);
                if (newState.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ 서버 JWT 저장 완료!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (newState.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ ${newState.errorMessage}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: state.isLoading
            ? [Colors.grey.withAlpha(40), Colors.grey.withAlpha(20)]
            : [Colors.blue.withAlpha(80), Colors.blue.withAlpha(40)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: state.isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '교환 중...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Firebase → Server 토큰 교환',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildResetButton(WidgetRef ref) {
    return GlassCard.dense(
      onTap: () {
        ref.read(authControllerProvider.notifier).reset();
        _checkTokenStatus(); // Changed: 상태 새로고침
      },
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.grey.withAlpha(30), Colors.grey.withAlpha(15)],
      ),
      borderColor: Colors.grey.shade400,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(
            '다시 시도',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

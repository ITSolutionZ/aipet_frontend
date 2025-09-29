import 'package:aipet_frontend/features/auth/application/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서버 토큰 교환 버튼 위젯
///
/// Firebase Auth 로그인 완료 후 서버 JWT로 교환하는 UI
class ExchangeTokenButton extends ConsumerWidget {
  const ExchangeTokenButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase → Server Token 교환'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상태 표시 카드
            _buildStatusCard(tokenState),
            const SizedBox(height: 32),

            // 교환 버튼
            _buildExchangeButton(context, ref, tokenState),
            const SizedBox(height: 16),

            // 리셋 버튼
            if (tokenState.isSuccess || tokenState.errorMessage != null)
              _buildResetButton(ref),
            const SizedBox(height: 32),

            // 설명 텍스트
            _buildInstructionText(),
          ],
        ),
      ),
    );
  }

  /// 상태 표시 카드
  Widget _buildStatusCard(TokenExchangeState state) {
    Color cardColor;
    IconData icon;
    String title;
    String? subtitle;

    if (state.isLoading) {
      cardColor = Colors.orange.shade100;
      icon = Icons.sync;
      title = '토큰 교환 중...';
      subtitle = '서버와 통신 중입니다';
    } else if (state.isSuccess) {
      cardColor = Colors.green.shade100;
      icon = Icons.check_circle;
      title = '토큰 저장 완료';
      subtitle = '서버 JWT가 안전하게 저장되었습니다';
    } else if (state.errorMessage != null) {
      cardColor = Colors.red.shade100;
      icon = Icons.error;
      title = '실패';
      subtitle = state.errorMessage;
    } else {
      cardColor = Colors.grey.shade100;
      icon = Icons.info;
      title = '준비 완료';
      subtitle = 'Firebase 로그인 후 버튼을 눌러주세요';
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (state.isLoading)
              const CircularProgressIndicator()
            else
              Icon(icon, size: 48, color: Colors.grey.shade700),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...[
              const SizedBox(height: 8),
              Text(
                subtitle ?? '',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 교환 버튼
  Widget _buildExchangeButton(
    BuildContext context,
    WidgetRef ref,
    TokenExchangeState state,
  ) {
    return ElevatedButton(
      onPressed: state.isLoading
          ? null
          : () async {
              // Changed: async 추가
              await ref
                  .read(authControllerProvider.notifier)
                  .exchangeServerToken();

              // Changed: 성공/실패 토스트 표시
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
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        state.isLoading ? '교환 중...' : 'Firebase → Server 토큰 교환',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// 리셋 버튼
  Widget _buildResetButton(WidgetRef ref) {
    return OutlinedButton(
      onPressed: () {
        ref.read(authControllerProvider.notifier).reset();
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        '다시 시도',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// 설명 텍스트
  Widget _buildInstructionText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '사용 방법:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '1. Firebase Auth로 먼저 로그인하세요\n'
            '2. "Firebase → Server 토큰 교환" 버튼을 누르세요\n'
            '3. 성공 시 서버 JWT가 자동으로 저장됩니다\n'
            '4. 이후 모든 API 요청에 자동으로 Authorization 헤더가 추가됩니다',
            style: TextStyle(fontSize: 14, color: Colors.blue, height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// 간단한 데모용 화면
class AuthDemoScreen extends StatelessWidget {
  const AuthDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: ExchangeTokenButton());
  }
}

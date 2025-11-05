import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_config.dart';
import '../../../app/services/dio_client.dart';
import '../../../shared/shared.dart';


/// API 연결 상태 데이터 클래스
class ApiConnectionState {
  final bool isChecking;
  final String status;
  final Color statusColor;
  final String? errorMessage;

  const ApiConnectionState({
    required this.isChecking,
    required this.status,
    required this.statusColor,
    this.errorMessage,
  });

  ApiConnectionState copyWith({
    bool? isChecking,
    String? status,
    Color? statusColor,
    String? errorMessage,
  }) {
    return ApiConnectionState(
      isChecking: isChecking ?? this.isChecking,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// API 연결 상태 관리 Notifier
class ApiConnectionNotifier extends Notifier<ApiConnectionState> {
  @override
  ApiConnectionState build() {
    // 위젯이 빌드될 때 자동으로 연결 확인
    Future.microtask(() => checkApiConnection());
    return const ApiConnectionState(
      isChecking: false,
      status: 'Unknown',
      statusColor: Colors.grey,
    );
  }

  Future<void> checkApiConnection() async {
    if (state.isChecking) return;

    state = state.copyWith(
      isChecking: true,
      status: 'Checking...',
      statusColor: Colors.orange,
      errorMessage: null,
    );

    try {
      final dio = DioClient.instance;

      // 1. 기본 연결 확인
      final response = await dio.get(
        '/health', // 일반적인 헬스체크 엔드포인트
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(
          status: 'Connected ✅',
          statusColor: Colors.green,
        );
      } else {
        state = state.copyWith(
          status: 'Unexpected Response',
          statusColor: Colors.orange,
          errorMessage: 'Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            state = state.copyWith(
              status: 'Timeout ⏱️',
              statusColor: Colors.orange,
              errorMessage: 'Server response timeout',
            );
            break;
          case DioExceptionType.connectionError:
            state = state.copyWith(
              status: 'Connection Failed ❌',
              statusColor: Colors.red,
              errorMessage: 'Cannot reach server',
            );
            break;
          default:
            state = state.copyWith(
              status: 'Server Error 🚫',
              statusColor: Colors.red,
              errorMessage: 'HTTP ${e.response?.statusCode ?? 'Unknown'}',
            );
        }
      } else {
        state = state.copyWith(
          status: 'Error ❌',
          statusColor: Colors.red,
          errorMessage: e.toString(),
        );
      }
    } finally {
      state = state.copyWith(isChecking: false);
    }
  }
}

/// API 연결 상태 확인 위젯
class ApiConnectionChecker extends ConsumerWidget {
  const ApiConnectionChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(apiConnectionProvider);
    final baseUrl = AppConfig.current.apiBaseUrl;

    return GlassCard(
      borderColor: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.api, color: connectionState.statusColor, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'API 연결 상태',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (connectionState.isChecking)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => ref
                        .read(apiConnectionProvider.notifier)
                        .checkApiConnection(),
                    tooltip: '다시 확인',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: connectionState.statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: connectionState.statusColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'URL: $baseUrl',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${connectionState.status}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: connectionState.statusColor,
                    ),
                  ),
                  if (connectionState.errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Error: ${connectionState.errorMessage}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '💡 팁: API 서버가 실행 중인지 확인하세요',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// API 연결 상태 Provider
final apiConnectionProvider =
    NotifierProvider<ApiConnectionNotifier, ApiConnectionState>(
      ApiConnectionNotifier.new,
    );

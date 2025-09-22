import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../app/config/app_config.dart';
import '../../../app/services/dio_client.dart';

/// API 연결 상태 확인 위젯
class ApiConnectionChecker extends StatefulWidget {
  const ApiConnectionChecker({super.key});

  @override
  State<ApiConnectionChecker> createState() => _ApiConnectionCheckerState();
}

class _ApiConnectionCheckerState extends State<ApiConnectionChecker> {
  bool _isChecking = false;
  String _status = 'Unknown';
  Color _statusColor = Colors.grey;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkApiConnection();
  }

  Future<void> _checkApiConnection() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
      _status = 'Checking...';
      _statusColor = Colors.orange;
      _errorMessage = null;
    });

    try {
      final dio = DioClient.instance;
      final baseUrl = AppConfig.current.apiBaseUrl;

      // 1. 기본 연결 확인
      final response = await dio.get(
        '/health', // 일반적인 헬스체크 엔드포인트
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _status = 'Connected ✅';
          _statusColor = Colors.green;
        });
      } else {
        setState(() {
          _status = 'Unexpected Response';
          _statusColor = Colors.orange;
          _errorMessage = 'Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            setState(() {
              _status = 'Timeout ⏱️';
              _statusColor = Colors.orange;
              _errorMessage = 'Server response timeout';
            });
            break;
          case DioExceptionType.connectionError:
            setState(() {
              _status = 'Connection Failed ❌';
              _statusColor = Colors.red;
              _errorMessage = 'Cannot reach server';
            });
            break;
          default:
            setState(() {
              _status = 'Server Error 🚫';
              _statusColor = Colors.red;
              _errorMessage = 'HTTP ${e.response?.statusCode ?? 'Unknown'}';
            });
        }
      } else {
        setState(() {
          _status = 'Error ❌';
          _statusColor = Colors.red;
          _errorMessage = e.toString();
        });
      }
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = AppConfig.current.apiBaseUrl;

    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.api,
                  color: _statusColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'API 연결 상태',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isChecking)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _checkApiConnection,
                    tooltip: '다시 확인',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
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
                    'Status: $_status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _statusColor,
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Error: $_errorMessage',
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
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 동기화 작업 타입
enum SyncOperationType { create, update, delete }

/// 동기화 작업 엔티티
class SyncOperation {
  final String id;
  final SyncOperationType type;
  final String entityType; // 'walk', 'pet', 'feeding' 등
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  const SyncOperation({
    required this.id,
    required this.type,
    required this.entityType,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'entityType': entityType,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'retryCount': retryCount,
  };

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: SyncOperationType.values.firstWhere((e) => e.name == json['type']),
      entityType: json['entityType'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: (json['retryCount'] as int?) ?? 0,
    );
  }

  SyncOperation copyWith({
    String? id,
    SyncOperationType? type,
    String? entityType,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      entityType: entityType ?? this.entityType,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// 동기화 큐 서비스
/// 오프라인 상태에서 실패한 작업들을 저장하고 온라인 복귀 시 재시도
class SyncQueueService {
  static const String _queueKey = 'pending_sync_operations';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  static SyncQueueService? _instance;
  static SyncQueueService get instance => _instance ??= SyncQueueService._();

  SyncQueueService._();

  /// 동기화 대기 작업 추가
  Future<void> addToQueue(SyncOperation operation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey) ?? '[]';
      final List<dynamic> queue = jsonDecode(queueJson);

      // 중복 체크 (같은 ID와 타입이면 최신 것으로 교체)
      queue.removeWhere((item) {
        final existingOp = SyncOperation.fromJson(item as Map<String, dynamic>);
        return existingOp.id == operation.id &&
            existingOp.type == operation.type &&
            existingOp.entityType == operation.entityType;
      });

      queue.add(operation.toJson());
      await prefs.setString(_queueKey, jsonEncode(queue));

      debugPrint(
        '📥 SyncQueue: 큐에 추가 - ${operation.entityType}:${operation.type.name}:${operation.id}',
      );
    } catch (e) {
      debugPrint('❌ SyncQueue: 큐 추가 실패 - $e');
    }
  }

  /// 대기 중인 작업 목록 조회
  Future<List<SyncOperation>> getPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);

      if (queueJson == null || queueJson == '[]') {
        return [];
      }

      final List<dynamic> queue = jsonDecode(queueJson);
      return queue
          .map((json) => SyncOperation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ SyncQueue: 큐 조회 실패 - $e');
      return [];
    }
  }

  /// 동기화 처리 (핸들러 함수 제공 필요)
  Future<void> processPendingOperations({
    required Future<bool> Function(SyncOperation) handler,
  }) async {
    try {
      final operations = await getPendingOperations();

      if (operations.isEmpty) {
        debugPrint('ℹ️ SyncQueue: 대기 중인 작업 없음');
        return;
      }

      debugPrint('🔄 SyncQueue: ${operations.length}개 작업 처리 시작');

      final failedOperations = <SyncOperation>[];

      for (final operation in operations) {
        try {
          // 재시도 횟수 확인
          if (operation.retryCount >= _maxRetries) {
            debugPrint(
              '⚠️ SyncQueue: 최대 재시도 횟수 초과 - ${operation.entityType}:${operation.id}',
            );
            // TODO: 에러 로깅 또는 사용자에게 알림
            continue;
          }

          // 재시도 지연
          if (operation.retryCount > 0) {
            await Future.delayed(_retryDelay * operation.retryCount);
          }

          // 핸들러 실행
          final success = await handler(operation);

          if (success) {
            debugPrint(
              '✅ SyncQueue: 동기화 완료 - ${operation.entityType}:${operation.type.name}:${operation.id}',
            );
          } else {
            // 실패 시 재시도 횟수 증가
            failedOperations.add(
              operation.copyWith(retryCount: operation.retryCount + 1),
            );
            debugPrint(
              '⚠️ SyncQueue: 동기화 실패 (재시도 ${operation.retryCount + 1}/$_maxRetries) - ${operation.entityType}:${operation.id}',
            );
          }
        } catch (e) {
          debugPrint(
            '❌ SyncQueue: 동기화 에러 - ${operation.entityType}:${operation.id}: $e',
          );
          failedOperations.add(
            operation.copyWith(retryCount: operation.retryCount + 1),
          );
        }
      }

      // 실패한 작업만 큐에 다시 저장
      await _saveQueue(failedOperations);

      final successCount = operations.length - failedOperations.length;
      debugPrint(
        '✅ SyncQueue: 처리 완료 - 성공: $successCount, 실패: ${failedOperations.length}',
      );
    } catch (e) {
      debugPrint('❌ SyncQueue: 처리 중 에러 - $e');
    }
  }

  /// 특정 작업 제거
  Future<void> removeOperation(String id, SyncOperationType type) async {
    try {
      final operations = await getPendingOperations();
      final filtered = operations
          .where((op) => !(op.id == id && op.type == type))
          .toList();

      await _saveQueue(filtered);

      debugPrint('🗑️ SyncQueue: 작업 제거 - $id:${type.name}');
    } catch (e) {
      debugPrint('❌ SyncQueue: 작업 제거 실패 - $e');
    }
  }

  /// 모든 대기 작업 제거
  Future<void> clearQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_queueKey);
      debugPrint('🗑️ SyncQueue: 큐 초기화 완료');
    } catch (e) {
      debugPrint('❌ SyncQueue: 큐 초기화 실패 - $e');
    }
  }

  /// 큐 통계
  Future<Map<String, dynamic>> getQueueStats() async {
    try {
      final operations = await getPendingOperations();

      final byType = <String, int>{};
      final byEntityType = <String, int>{};

      for (final op in operations) {
        // 타입별 카운트
        final typeKey = op.type.name;
        byType[typeKey] = (byType[typeKey] ?? 0) + 1;

        // 엔티티 타입별 카운트
        byEntityType[op.entityType] = (byEntityType[op.entityType] ?? 0) + 1;
      }

      return {
        'total': operations.length,
        'byType': byType,
        'byEntityType': byEntityType,
        'oldestTimestamp': operations.isNotEmpty
            ? operations
                  .map((op) => op.timestamp)
                  .reduce((a, b) => a.isBefore(b) ? a : b)
                  .toIso8601String()
            : null,
      };
    } catch (e) {
      debugPrint('❌ SyncQueue: 통계 조회 실패 - $e');
      return {'total': 0, 'byType': {}, 'byEntityType': {}};
    }
  }

  /// 큐 저장 (내부 메서드)
  Future<void> _saveQueue(List<SyncOperation> operations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = operations.map((op) => op.toJson()).toList();
      await prefs.setString(_queueKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('❌ SyncQueue: 큐 저장 실패 - $e');
    }
  }
}

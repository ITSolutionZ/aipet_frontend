import 'package:aipet_frontend/shared/core/api/api_constants.dart';
import 'package:aipet_frontend/shared/testing/mock_server/walk_mock_server.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Mock API Interceptor
/// 개발 환경에서 실제 API 서버 대신 Mock 응답을 반환
class MockApiInterceptor extends Interceptor {
  final bool enabled;
  final WalkMockServer _walkMockServer = WalkMockServer.instance;

  MockApiInterceptor({this.enabled = false}) {
    if (enabled) {
      _walkMockServer.initialize();
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!enabled) {
      return handler.next(options);
    }

    debugPrint('🔶 MockAPI: ${options.method} ${options.path}');

    // Walk API Mock 처리
    if (options.path.startsWith(ApiEndpoints.walks)) {
      final mockResponse = _handleWalkApi(options);
      if (mockResponse != null) {
        return handler.resolve(mockResponse);
      }
    }

    // Mock이 없으면 실제 요청 진행
    return handler.next(options);
  }

  /// Walk API Mock 응답 처리
  Response? _handleWalkApi(RequestOptions options) {
    final method = options.method;
    final path = options.path;

    try {
      // GET /walks - 전체 산책 기록 조회
      if (method == 'GET' && path == ApiEndpoints.walks) {
        final petId = options.queryParameters['petId'] as String?;

        if (petId != null) {
          // 펫별 산책 기록
          final response = _walkMockServer.getWalkRecordsByPetId(petId);
          return _createResponse(options, response);
        } else {
          // 전체 산책 기록
          final response = _walkMockServer.getAllWalkRecords();
          return _createResponse(options, response);
        }
      }

      // GET /walks/current - 현재 진행 중인 산책
      if (method == 'GET' && path == '${ApiEndpoints.walks}/current') {
        final response = _walkMockServer.getCurrentWalk();
        return _createResponse(options, response);
      }

      // GET /walks/statistics - 산책 통계
      if (method == 'GET' && path == '${ApiEndpoints.walks}/statistics') {
        final petId = options.queryParameters['petId'] as String?;
        final startDateStr = options.queryParameters['startDate'] as String?;
        final endDateStr = options.queryParameters['endDate'] as String?;

        final startDate = startDateStr != null
            ? DateTime.parse(startDateStr)
            : null;
        final endDate = endDateStr != null ? DateTime.parse(endDateStr) : null;

        final response = _walkMockServer.getWalkStatistics(
          petId: petId,
          startDate: startDate,
          endDate: endDate,
        );
        return _createResponse(options, response);
      }

      // GET /walks/:id - 특정 산책 기록 조회
      if (method == 'GET' && path.startsWith('${ApiEndpoints.walks}/')) {
        final walkId = path.split('/').last;
        final response = _walkMockServer.getWalkRecordById(walkId);
        return _createResponse(options, response);
      }

      // POST /walks - 산책 시작
      if (method == 'POST' && path == ApiEndpoints.walks) {
        final walkData = options.data as Map<String, dynamic>;
        final response = _walkMockServer.startWalk(walkData);
        return _createResponse(options, response, statusCode: 201);
      }

      // PUT /walks/:id - 산책 기록 업데이트
      if (method == 'PUT' && path.startsWith('${ApiEndpoints.walks}/')) {
        final walkId = path.split('/').last;
        final updateData = options.data as Map<String, dynamic>;

        // endTime이 있으면 산책 종료
        if (updateData.containsKey('endTime')) {
          final response = _walkMockServer.endWalk(walkId, updateData);
          return _createResponse(options, response);
        } else {
          final response = _walkMockServer.updateWalkRecord(walkId, updateData);
          return _createResponse(options, response);
        }
      }

      // DELETE /walks/:id - 산책 기록 삭제
      if (method == 'DELETE' && path.startsWith('${ApiEndpoints.walks}/')) {
        final walkId = path.split('/').last;
        final response = _walkMockServer.deleteWalkRecord(walkId);
        return _createResponse(options, response, statusCode: 204);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ MockAPI: 에러 - $e');
      debugPrint('StackTrace: $stackTrace');
      return _createErrorResponse(options, e.toString());
    }

    return null;
  }

  /// Mock 응답 생성
  Response _createResponse(
    RequestOptions options,
    Map<String, dynamic> data, {
    int statusCode = 200,
  }) {
    // 약간의 지연 시뮬레이션 (200-500ms)
    Future.delayed(
      Duration(milliseconds: 200 + (DateTime.now().millisecond % 300)),
    );

    return Response(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
      headers: Headers.fromMap({
        'content-type': ['application/json'],
      }),
    );
  }

  /// 에러 응답 생성
  Response _createErrorResponse(RequestOptions options, String errorMessage) {
    return Response(
      requestOptions: options,
      statusCode: 500,
      data: {'success': false, 'error': errorMessage},
    );
  }
}

import 'package:aipet_frontend/features/walk/data/services/walk_api_service.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/core/api/api_client.dart';
import 'package:aipet_frontend/shared/core/api/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'walk_api_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ApiClient>()])
void main() {
  late WalkApiService walkApiService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    walkApiService = WalkApiService(mockApiClient);
  });

  group('WalkApiService - getAllWalkRecords', () {
    test('성공 시 산책 기록 목록 반환', () async {
      // Arrange
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.walks),
        statusCode: 200,
        data: {
          'walks': [
            {
              'id': 'walk-1',
              'petId': 'pet-1',
              'petName': 'Test Pet',
              'startTime': DateTime.now().toIso8601String(),
              'status': 'completed',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ],
        },
      );

      when(
        mockApiClient.get(ApiEndpoints.walks),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await walkApiService.getAllWalkRecords();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data!.length, 1);
      expect(result.data!.first.id, 'walk-1');
    });

    test('API 실패 시 Failure 결과 반환', () async {
      // Arrange
      when(mockApiClient.get(ApiEndpoints.walks)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.walks),
          error: 'Network error',
        ),
      );

      // Act
      final result = await walkApiService.getAllWalkRecords();

      // Assert
      expect(result.isSuccess, false);
      expect(result.message, contains('실패'));
    });
  });

  group('WalkApiService - startWalk', () {
    test('산책 시작 성공', () async {
      // Arrange
      final walkRecord = WalkRecordEntity(
        id: 'walk-1',
        petId: 'pet-1',
        petName: 'Test Pet',
        startTime: DateTime.now(),
        status: WalkStatus.inProgress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.walks),
        statusCode: 201,
        data: walkRecord.toJson(),
      );

      when(
        mockApiClient.post(ApiEndpoints.walks, data: anyNamed('data')),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await walkApiService.startWalk(walkRecord);

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data!.status, WalkStatus.inProgress);
    });
  });

  group('WalkApiService - endWalk', () {
    test('산책 종료 성공', () async {
      // Arrange
      const walkId = 'walk-1';
      const distance = 3.5;
      const notes = 'Good walk';

      final completedRecord = WalkRecordEntity(
        id: walkId,
        petId: 'pet-1',
        petName: 'Test Pet',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now(),
        distance: distance,
        notes: notes,
        status: WalkStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.walkById(walkId)),
        statusCode: 200,
        data: completedRecord.toJson(),
      );

      when(
        mockApiClient.put(
          ApiEndpoints.walkById(walkId),
          data: anyNamed('data'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await walkApiService.endWalk(
        walkId,
        distance: distance,
        notes: notes,
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data!.status, WalkStatus.completed);
      expect(result.data!.distance, distance);
    });
  });

  group('WalkApiService - updateWalkRecord', () {
    test('산책 기록 업데이트 성공', () async {
      // Arrange
      final walkRecord = WalkRecordEntity(
        id: 'walk-1',
        petId: 'pet-1',
        petName: 'Test Pet',
        startTime: DateTime.now(),
        distance: 5.0,
        status: WalkStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.walkById('walk-1')),
        statusCode: 200,
        data: walkRecord.toJson(),
      );

      when(
        mockApiClient.put(
          ApiEndpoints.walkById('walk-1'),
          data: anyNamed('data'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await walkApiService.updateWalkRecord(walkRecord);

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data!.distance, 5.0);
    });
  });

  group('WalkApiService - deleteWalkRecord', () {
    test('산책 기록 삭제 성공 (200 응답)', () async {
      // Arrange
      const walkId = 'walk-1';

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.walkById(walkId)),
        statusCode: 200,
        data: {'message': 'Deleted'},
      );

      when(
        mockApiClient.delete(ApiEndpoints.walkById(walkId)),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await walkApiService.deleteWalkRecord(walkId);

      // Assert
      expect(result.isSuccess, true);
    });

    test('산책 기록 삭제 성공 (204 응답)', () async {
      // Arrange
      const walkId = 'walk-1';

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.walkById(walkId)),
        statusCode: 204,
      );

      when(
        mockApiClient.delete(ApiEndpoints.walkById(walkId)),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await walkApiService.deleteWalkRecord(walkId);

      // Assert
      expect(result.isSuccess, true);
    });
  });

  group('WalkApiService - getWalkRecordsByPetId', () {
    test('펫별 산책 기록 조회 성공', () async {
      // Arrange
      const petId = 'pet-1';

      final mockResponse = Response(
        requestOptions: RequestOptions(path: ApiEndpoints.walks),
        statusCode: 200,
        data: {
          'walks': [
            {
              'id': 'walk-1',
              'petId': petId,
              'petName': 'Test Pet',
              'startTime': DateTime.now().toIso8601String(),
              'status': 'completed',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ],
        },
      );

      when(
        mockApiClient.get(
          ApiEndpoints.walks,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await walkApiService.getWalkRecordsByPetId(petId);

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data!.every((r) => r.petId == petId), true);
    });
  });

  group('WalkApiService - getCurrentWalk', () {
    test('진행 중인 산책이 있을 때', () async {
      // Arrange
      final mockWalk = WalkRecordEntity(
        id: 'current-1',
        petId: 'pet-1',
        petName: 'Test Pet',
        startTime: DateTime.now(),
        status: WalkStatus.inProgress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockResponse = Response(
        requestOptions: RequestOptions(path: '${ApiEndpoints.walks}/current'),
        statusCode: 200,
        data: mockWalk.toJson(),
      );

      when(
        mockApiClient.get('${ApiEndpoints.walks}/current'),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await walkApiService.getCurrentWalk();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data!.status, WalkStatus.inProgress);
    });

    test('진행 중인 산책이 없을 때 (204)', () async {
      // Arrange
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '${ApiEndpoints.walks}/current'),
        statusCode: 204,
      );

      when(
        mockApiClient.get('${ApiEndpoints.walks}/current'),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await walkApiService.getCurrentWalk();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isNull);
    });
  });
}

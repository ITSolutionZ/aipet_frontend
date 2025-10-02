import 'dart:convert';

import 'package:aipet_frontend/features/walk/data/repositories/hybrid_walk_repository.dart';
import 'package:aipet_frontend/features/walk/data/services/walk_api_service.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hybrid_walk_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<WalkApiService>()])
void main() {
  late HybridWalkRepository repository;
  late MockWalkApiService mockApiService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockApiService = MockWalkApiService();
  });

  group('HybridWalkRepository - API 비활성화 모드', () {
    setUp(() {
      repository = HybridWalkRepository(
        apiService: mockApiService,
        useApi: false, // API 비활성화
      );
    });

    test('getAllWalkRecords - 로컬 데이터가 없으면 Mock 데이터 반환', () async {
      // Act
      final result = await repository.getAllWalkRecords();

      // Assert
      expect(result, isNotEmpty);
      expect(result, isA<List<WalkRecordEntity>>());
      verifyNever(mockApiService.getAllWalkRecords()); // API 호출 안 됨
    });

    test('saveWalkRecord - API 호출하지 않고 로컬만 저장', () async {
      // Arrange
      final walkRecord = WalkRecordEntity(
        id: 'test-1',
        petId: 'pet-1',
        petName: 'Test Pet',
        startTime: DateTime.now(),
        status: WalkStatus.inProgress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await repository.saveWalkRecord(walkRecord);

      // Assert
      verifyNever(mockApiService.startWalk(any)); // API 호출 안 됨
    });
  });

  group('HybridWalkRepository - API 활성화 모드', () {
    setUp(() {
      repository = HybridWalkRepository(
        apiService: mockApiService,
        useApi: true, // API 활성화
      );
    });

    test('getAllWalkRecords - API 성공 시 API 데이터 반환', () async {
      // Arrange
      final mockRecords = [
        WalkRecordEntity(
          id: 'api-1',
          petId: 'pet-1',
          petName: 'API Pet',
          startTime: DateTime.now(),
          status: WalkStatus.completed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(
        mockApiService.getAllWalkRecords(),
      ).thenAnswer((_) async => Result.success('성공', mockRecords));

      // Act
      final result = await repository.getAllWalkRecords();

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 'api-1');
      verify(mockApiService.getAllWalkRecords()).called(1);
    });

    test('getAllWalkRecords - API 실패 시 로컬 또는 Mock 데이터 Fallback', () async {
      // Arrange
      when(
        mockApiService.getAllWalkRecords(),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await repository.getAllWalkRecords();

      // Assert
      expect(result, isNotEmpty); // 로컬 또는 Mock 데이터 반환
      verify(mockApiService.getAllWalkRecords()).called(1);
    });

    test('startWalk - API 성공 시 동기화된 데이터 반환', () async {
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

      final syncedRecord = walkRecord.copyWith(id: 'synced-1');

      when(
        mockApiService.startWalk(walkRecord),
      ).thenAnswer((_) async => Result.success('성공', syncedRecord));

      // Act
      final result = await repository.startWalk(walkRecord);

      // Assert
      expect(result.id, 'synced-1'); // API에서 반환된 ID
      verify(mockApiService.startWalk(walkRecord)).called(1);
    });

    test('startWalk - API 실패 시 로컬 데이터 반환 및 큐 추가', () async {
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

      when(
        mockApiService.startWalk(walkRecord),
      ).thenThrow(Exception('API Error'));

      // Act
      final result = await repository.startWalk(walkRecord);

      // Assert
      expect(result.id, 'walk-1'); // 로컬 데이터 반환
      verify(mockApiService.startWalk(walkRecord)).called(1);
      // 동기화 큐에 추가되었는지 확인 (별도 테스트 필요)
    });

    test('updateWalkRecord - API 성공 시 동기화', () async {
      // Arrange
      final walkRecord = WalkRecordEntity(
        id: 'walk-1',
        petId: 'pet-1',
        petName: 'Test Pet',
        startTime: DateTime.now(),
        status: WalkStatus.completed,
        distance: 5.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        mockApiService.updateWalkRecord(walkRecord),
      ).thenAnswer((_) async => Result.success('성공', walkRecord));

      // Act
      await repository.updateWalkRecord(walkRecord);

      // Assert
      verify(mockApiService.updateWalkRecord(walkRecord)).called(1);
    });

    test('deleteWalkRecord - API 성공 시 삭제', () async {
      // Arrange
      const walkId = 'walk-1';

      when(
        mockApiService.deleteWalkRecord(walkId),
      ).thenAnswer((_) async => Result.success('삭제 성공'));

      // Act
      await repository.deleteWalkRecord(walkId);

      // Assert
      verify(mockApiService.deleteWalkRecord(walkId)).called(1);
    });
  });

  group('HybridWalkRepository - 특수 케이스', () {
    setUp(() {
      repository = HybridWalkRepository(
        apiService: mockApiService,
        useApi: true,
      );
    });

    test('getWalkRecordById - API 성공 시 로컬 캐시 업데이트', () async {
      // Arrange
      final mockRecord = WalkRecordEntity(
        id: 'walk-1',
        petId: 'pet-1',
        petName: 'Test Pet',
        startTime: DateTime.now(),
        status: WalkStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        mockApiService.getWalkRecordById('walk-1'),
      ).thenAnswer((_) async => Result.success('성공', mockRecord));

      // Act
      final result = await repository.getWalkRecordById('walk-1');

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'walk-1');
      verify(mockApiService.getWalkRecordById('walk-1')).called(1);
    });

    test('getWalkRecordsByPetId - 펫별 필터링', () async {
      // Arrange
      final mockRecords = [
        WalkRecordEntity(
          id: 'walk-1',
          petId: 'pet-1',
          petName: 'Test Pet',
          startTime: DateTime.now(),
          status: WalkStatus.completed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(
        mockApiService.getWalkRecordsByPetId('pet-1'),
      ).thenAnswer((_) async => Result.success('성공', mockRecords));

      // Act
      final result = await repository.getWalkRecordsByPetId('pet-1');

      // Assert
      expect(result.length, 1);
      expect(result.first.petId, 'pet-1');
      verify(mockApiService.getWalkRecordsByPetId('pet-1')).called(1);
    });

    test('getCurrentWalk - 진행 중인 산책 조회', () async {
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

      when(
        mockApiService.getCurrentWalk(),
      ).thenAnswer((_) async => Result.success('성공', mockWalk));

      // Act
      final result = await repository.getCurrentWalk();

      // Assert
      expect(result, isNotNull);
      expect(result!.status, WalkStatus.inProgress);
      verify(mockApiService.getCurrentWalk()).called(1);
    });

    test('endWalk - 산책 종료 및 로컬 동기화', () async {
      // Arrange
      const walkId = 'walk-1';
      const distance = 3.5;
      const notes = 'Good walk';

      // 로컬에 초기 산책 기록 저장
      final initialRecord = WalkRecordEntity(
        id: walkId,
        petId: 'pet-1',
        petName: 'Test Pet',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        status: WalkStatus.inProgress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Mock SharedPreferences에 초기 데이터 설정
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'walk_records',
        '[${jsonEncode(initialRecord.toJson())}]',
      );

      final completedRecord = initialRecord.copyWith(
        endTime: DateTime.now(),
        distance: distance,
        notes: notes,
        status: WalkStatus.completed,
      );

      when(
        mockApiService.endWalk(walkId, distance: distance, notes: notes),
      ).thenAnswer((_) async => Result.success('성공', completedRecord));

      // Act
      final result = await repository.endWalk(
        walkId,
        distance: distance,
        notes: notes,
      );

      // Assert
      expect(result.status, WalkStatus.completed);
      expect(result.distance, distance);
      verify(
        mockApiService.endWalk(walkId, distance: distance, notes: notes),
      ).called(1);
    });
  });
}

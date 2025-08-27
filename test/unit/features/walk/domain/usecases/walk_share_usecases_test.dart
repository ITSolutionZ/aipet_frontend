import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/domain/repositories/walk_share_repository.dart';
import 'package:aipet_frontend/features/walk/domain/usecases/walk_share_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'walk_share_usecases_test.mocks.dart';

@GenerateMocks([WalkShareRepository])
void main() {
  group('WalkShareUseCases Tests', () {
    late MockWalkShareRepository mockRepository;
    late CopyToClipboardUseCase copyToClipboardUseCase;
    late SaveAsImageUseCase saveAsImageUseCase;
    late SystemShareUseCase systemShareUseCase;
    late GenerateShareTextUseCase generateShareTextUseCase;

    setUp(() {
      mockRepository = MockWalkShareRepository();
      copyToClipboardUseCase = CopyToClipboardUseCase(mockRepository);
      saveAsImageUseCase = SaveAsImageUseCase(mockRepository);
      systemShareUseCase = SystemShareUseCase(mockRepository);
      generateShareTextUseCase = GenerateShareTextUseCase(mockRepository);
    });

    group('CopyToClipboardUseCase', () {
      test('should copy text to clipboard successfully', () async {
        // Arrange
        const text = 'Test share text';
        final expectedResult = WalkShareResult.success('텍스트가 클립보드에 복사되었습니다');

        when(
          mockRepository.copyToClipboard(text),
        ).thenAnswer((_) async => expectedResult);

        // Act
        final result = await copyToClipboardUseCase(text);

        // Assert
        expect(result, equals(expectedResult));
        expect(result.isSuccess, isTrue);
        expect(result.message, equals('텍스트가 클립보드에 복사되었습니다'));
        verify(mockRepository.copyToClipboard(text)).called(1);
      });

      test('should handle clipboard copy failure', () async {
        // Arrange
        const text = 'Test share text';
        final expectedResult = WalkShareResult.failure('클립보드 복사에 실패했습니다');

        when(
          mockRepository.copyToClipboard(text),
        ).thenAnswer((_) async => expectedResult);

        // Act
        final result = await copyToClipboardUseCase(text);

        // Assert
        expect(result, equals(expectedResult));
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('클립보드 복사에 실패했습니다'));
        verify(mockRepository.copyToClipboard(text)).called(1);
      });
    });

    group('SaveAsImageUseCase', () {
      test('should save walk record as image successfully', () async {
        // Arrange
        final walkRecord = WalkRecordEntity(
          id: 'test-id',
          title: 'Test Walk',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          distance: 5.0,
          duration: const Duration(hours: 1),
          route: [],
        );

        final expectedResult = WalkShareResult.success(
          '산책 기록 이미지가 저장되었습니다',
          imagePath: '/storage/emulated/0/Pictures/walk_test-id.png',
        );

        when(
          mockRepository.saveAsImage(walkRecord),
        ).thenAnswer((_) async => expectedResult);

        // Act
        final result = await saveAsImageUseCase(walkRecord);

        // Assert
        expect(result, equals(expectedResult));
        expect(result.isSuccess, isTrue);
        expect(result.message, equals('산책 기록 이미지가 저장되었습니다'));
        expect(
          result.imagePath,
          equals('/storage/emulated/0/Pictures/walk_test-id.png'),
        );
        verify(mockRepository.saveAsImage(walkRecord)).called(1);
      });

      test('should handle image save failure', () async {
        // Arrange
        final walkRecord = WalkRecordEntity(
          id: 'test-id',
          title: 'Test Walk',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          distance: 5.0,
          duration: const Duration(hours: 1),
          route: [],
        );

        final expectedResult = WalkShareResult.failure('이미지 저장에 실패했습니다');

        when(
          mockRepository.saveAsImage(walkRecord),
        ).thenAnswer((_) async => expectedResult);

        // Act
        final result = await saveAsImageUseCase(walkRecord);

        // Assert
        expect(result, equals(expectedResult));
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('이미지 저장에 실패했습니다'));
        verify(mockRepository.saveAsImage(walkRecord)).called(1);
      });
    });

    group('SystemShareUseCase', () {
      test('should share text via system successfully', () async {
        // Arrange
        const text = 'Test share text';
        const subject = '산책 기록 공유';
        final expectedResult = WalkShareResult.success('시스템 공유가 실행되었습니다');

        when(
          mockRepository.systemShare(text, subject: subject),
        ).thenAnswer((_) async => expectedResult);

        // Act
        final result = await systemShareUseCase(text, subject: subject);

        // Assert
        expect(result, equals(expectedResult));
        expect(result.isSuccess, isTrue);
        expect(result.message, equals('시스템 공유가 실행되었습니다'));
        verify(mockRepository.systemShare(text, subject: subject)).called(1);
      });

      test('should handle system share failure', () async {
        // Arrange
        const text = 'Test share text';
        final expectedResult = WalkShareResult.failure('시스템 공유에 실패했습니다');

        when(
          mockRepository.systemShare(text, subject: null),
        ).thenAnswer((_) async => expectedResult);

        // Act
        final result = await systemShareUseCase(text);

        // Assert
        expect(result, equals(expectedResult));
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('시스템 공유에 실패했습니다'));
        verify(mockRepository.systemShare(text, subject: null)).called(1);
      });
    });

    group('GenerateShareTextUseCase', () {
      test('should generate share text correctly', () {
        // Arrange
        final walkRecord = WalkRecordEntity(
          id: 'test-id',
          title: 'Test Walk',
          startTime: DateTime(2024, 1, 15, 10, 0),
          endTime: DateTime(2024, 1, 15, 11, 0),
          distance: 5.0,
          duration: const Duration(hours: 1),
          route: [],
        );

        const expectedText = '''🐕 산책 기록 공유

제목: Test Walk
날짜: 2024-01-15 10:00
시간: 1시간 0분
거리: 5.0 km

#AIペット #산책기록 #Test Walk''';

        when(
          mockRepository.generateShareText(walkRecord),
        ).thenReturn(expectedText);

        // Act
        final result = generateShareTextUseCase(walkRecord);

        // Assert
        expect(result, equals(expectedText));
        verify(mockRepository.generateShareText(walkRecord)).called(1);
      });
    });
  });
}

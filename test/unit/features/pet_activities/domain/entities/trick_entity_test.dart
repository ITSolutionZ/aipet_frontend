import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrickEntity', () {
    late TrickEntity trickEntity;
    final testCreatedAt = DateTime(2024, 1, 15);

    setUp(() {
      trickEntity = TrickEntity(
        id: 'trick_1',
        name: 'Sit',
        petId: 'pet_1',
        date: DateTime(2024, 1, 16),
        progress: 50,
        imagePath: 'assets/images/sit.png',
        isCompleted: false,
        isVideo: false,
        difficulty: 'easy',
        duration: '5 minutes',
        youtubeUrl: 'https://youtube.com/watch?v=abc123',
        description: 'Basic sit trick',
        createdAt: testCreatedAt,
        lastPlayedTimeInSeconds: 120,
      );
    });

    group('Constructor and Properties', () {
      test('should create TrickEntity with all properties', () {
        expect(trickEntity.id, 'trick_1');
        expect(trickEntity.name, 'Sit');
        expect(trickEntity.petId, 'pet_1');
        expect(trickEntity.progress, 50);
        expect(trickEntity.imagePath, 'assets/images/sit.png');
        expect(trickEntity.isCompleted, false);
        expect(trickEntity.isVideo, false);
        expect(trickEntity.difficulty, 'easy');
        expect(trickEntity.duration, '5 minutes');
        expect(trickEntity.youtubeUrl, 'https://youtube.com/watch?v=abc123');
        expect(trickEntity.description, 'Basic sit trick');
        expect(trickEntity.createdAt, testCreatedAt);
        expect(trickEntity.lastPlayedTimeInSeconds, 120);
      });

      test('should create TrickEntity with minimal required properties', () {
        final minimalTrick = TrickEntity(
          id: 'trick_2',
          name: 'Stay',
          imagePath: 'assets/images/stay.png',
          createdAt: testCreatedAt,
        );

        expect(minimalTrick.id, 'trick_2');
        expect(minimalTrick.name, 'Stay');
        expect(minimalTrick.imagePath, 'assets/images/stay.png');
        expect(minimalTrick.isCompleted, false);
        expect(minimalTrick.isVideo, false);
        expect(minimalTrick.createdAt, testCreatedAt);
        expect(minimalTrick.petId, null);
        expect(minimalTrick.progress, null);
      });
    });

    group('copyWith', () {
      test('should create new instance with updated properties', () {
        final updated = trickEntity.copyWith(
          name: 'Updated Sit',
          progress: 75,
          isCompleted: true,
        );

        expect(updated.name, 'Updated Sit');
        expect(updated.progress, 75);
        expect(updated.isCompleted, true);
        // Original properties should remain
        expect(updated.id, trickEntity.id);
        expect(updated.petId, trickEntity.petId);
        expect(updated.imagePath, trickEntity.imagePath);
      });

      test(
        'should return identical instance when no parameters are provided',
        () {
          final copied = trickEntity.copyWith();

          expect(copied.id, trickEntity.id);
          expect(copied.name, trickEntity.name);
          expect(copied.progress, trickEntity.progress);
          expect(copied.isCompleted, trickEntity.isCompleted);
        },
      );
    });

    group('markAsCompleted', () {
      test('should mark trick as completed with 100% progress', () {
        final completed = trickEntity.markAsCompleted();

        expect(completed.isCompleted, true);
        expect(completed.progress, 100);
        expect(completed.date, isNotNull);
        expect(completed.date!.isAfter(trickEntity.date!), true);
      });

      test('should preserve other properties when marking as completed', () {
        final completed = trickEntity.markAsCompleted();

        expect(completed.id, trickEntity.id);
        expect(completed.name, trickEntity.name);
        expect(completed.petId, trickEntity.petId);
        expect(completed.imagePath, trickEntity.imagePath);
      });
    });

    group('updateProgress', () {
      test('should update progress within valid range', () {
        final updated = trickEntity.updateProgress(75);

        expect(updated.progress, 75);
        expect(updated.isCompleted, false);
        expect(updated.date, trickEntity.date);
      });

      test('should mark as completed when progress reaches 100', () {
        final updated = trickEntity.updateProgress(100);

        expect(updated.progress, 100);
        expect(updated.isCompleted, true);
        expect(updated.date, isNotNull);
        expect(updated.date!.isAfter(trickEntity.date!), true);
      });

      test('should clamp progress to minimum 0', () {
        final updated = trickEntity.updateProgress(-10);

        expect(updated.progress, 0);
        expect(updated.isCompleted, false);
      });

      test('should clamp progress to maximum 100', () {
        final updated = trickEntity.updateProgress(150);

        expect(updated.progress, 100);
        expect(updated.isCompleted, true);
      });
    });

    group('difficultyLevel', () {
      test('should return correct level for easy difficulty', () {
        final easy = trickEntity.copyWith(difficulty: 'easy');
        expect(easy.difficultyLevel, 1);
      });

      test('should return correct level for medium difficulty', () {
        final medium = trickEntity.copyWith(difficulty: 'medium');
        expect(medium.difficultyLevel, 3);
      });

      test('should return correct level for hard difficulty', () {
        final hard = trickEntity.copyWith(difficulty: 'hard');
        expect(hard.difficultyLevel, 5);
      });

      test('should return default level for unknown difficulty', () {
        final unknown = trickEntity.copyWith(difficulty: 'unknown');
        expect(unknown.difficultyLevel, 2);
      });

      test('should return default level for null difficulty', () {
        final nullDifficulty = trickEntity.copyWith(difficulty: null);
        expect(nullDifficulty.difficultyLevel, 2);
      });

      test('should be case insensitive', () {
        final upperCase = trickEntity.copyWith(difficulty: 'EASY');
        expect(upperCase.difficultyLevel, 1);
      });
    });

    group('isRecentlyCompleted', () {
      test('should return true for recently completed trick', () {
        final recentDate = DateTime.now().subtract(const Duration(days: 3));
        final recentTrick = trickEntity.copyWith(
          isCompleted: true,
          date: recentDate,
        );

        expect(recentTrick.isRecentlyCompleted, true);
      });

      test('should return false for old completed trick', () {
        final oldDate = DateTime.now().subtract(const Duration(days: 10));
        final oldTrick = trickEntity.copyWith(isCompleted: true, date: oldDate);

        expect(oldTrick.isRecentlyCompleted, false);
      });

      test('should return false for uncompleted trick', () {
        final uncompleted = trickEntity.copyWith(isCompleted: false);
        expect(uncompleted.isRecentlyCompleted, false);
      });

      test('should return false when date is null', () {
        final noDate = trickEntity.copyWith(isCompleted: true, date: null);
        expect(noDate.isRecentlyCompleted, false);
      });
    });

    group('progressPercentage', () {
      test('should return correct percentage for valid progress', () {
        final trick75 = trickEntity.copyWith(progress: 75);
        expect(trick75.progressPercentage, 0.75);
      });

      test('should return 0.0 for null progress', () {
        final noProgress = trickEntity.copyWith(progress: null);
        expect(noProgress.progressPercentage, 0.0);
      });

      test('should clamp to 1.0 for progress over 100', () {
        final overProgress = trickEntity.copyWith(progress: 150);
        expect(overProgress.progressPercentage, 1.0);
      });

      test('should clamp to 0.0 for negative progress', () {
        final negativeProgress = trickEntity.copyWith(progress: -10);
        expect(negativeProgress.progressPercentage, 0.0);
      });
    });

    group('YouTube URL validation', () {
      test('should validate correct youtube.com URL', () {
        const youtubeUrl = 'https://youtube.com/watch?v=abc123';
        final trick = trickEntity.copyWith(youtubeUrl: youtubeUrl);
        expect(trick.hasValidYoutubeUrl, true);
      });

      test('should validate correct youtu.be URL', () {
        const shortUrl = 'https://youtu.be/abc123';
        final trick = trickEntity.copyWith(youtubeUrl: shortUrl);
        expect(trick.hasValidYoutubeUrl, true);
      });

      test('should reject invalid URL', () {
        const invalidUrl = 'https://example.com/video';
        final trick = trickEntity.copyWith(youtubeUrl: invalidUrl);
        expect(trick.hasValidYoutubeUrl, false);
      });

      test('should reject null URL', () {
        final trick = trickEntity.copyWith(youtubeUrl: null);
        expect(trick.hasValidYoutubeUrl, false);
      });
    });

    group('YouTube video ID extraction', () {
      test('should extract video ID from youtube.com URL', () {
        const youtubeUrl = 'https://youtube.com/watch?v=abc123&t=60s';
        final trick = trickEntity.copyWith(youtubeUrl: youtubeUrl);
        expect(trick.youtubeVideoId, 'abc123');
      });

      test('should extract video ID from youtu.be URL', () {
        const shortUrl = 'https://youtu.be/xyz789';
        final trick = trickEntity.copyWith(youtubeUrl: shortUrl);
        expect(trick.youtubeVideoId, 'xyz789');
      });

      test('should return null for invalid URL', () {
        const invalidUrl = 'https://example.com/video';
        final trick = trickEntity.copyWith(youtubeUrl: invalidUrl);
        expect(trick.youtubeVideoId, null);
      });
    });

    group('YouTube thumbnail URL', () {
      test('should generate correct thumbnail URL', () {
        const youtubeUrl = 'https://youtube.com/watch?v=abc123';
        final trick = trickEntity.copyWith(youtubeUrl: youtubeUrl);
        expect(
          trick.youtubeThumbnailUrl,
          'https://img.youtube.com/vi/abc123/hqdefault.jpg',
        );
      });

      test('should return null for invalid video ID', () {
        const invalidUrl = 'https://example.com/video';
        final trick = trickEntity.copyWith(youtubeUrl: invalidUrl);
        expect(trick.youtubeThumbnailUrl, null);
      });
    });

    group('Last played time formatting', () {
      test('should check if has last played time', () {
        expect(trickEntity.hasLastPlayedTime, true);

        final noTime = TrickEntity(
          id: 'test',
          name: 'Test',
          imagePath: 'test.png',
          createdAt: DateTime.now(),
          lastPlayedTimeInSeconds: null,
        );
        expect(noTime.hasLastPlayedTime, false);

        final zeroTime = TrickEntity(
          id: 'test',
          name: 'Test',
          imagePath: 'test.png',
          createdAt: DateTime.now(),
          lastPlayedTimeInSeconds: 0,
        );
        expect(zeroTime.hasLastPlayedTime, false);
      });

      test('should format last played time correctly', () {
        final trick120 = trickEntity.copyWith(lastPlayedTimeInSeconds: 120);
        expect(trick120.formattedLastPlayedTime, '02:00');

        final trick75 = trickEntity.copyWith(lastPlayedTimeInSeconds: 75);
        expect(trick75.formattedLastPlayedTime, '01:15');

        final trick5 = trickEntity.copyWith(lastPlayedTimeInSeconds: 5);
        expect(trick5.formattedLastPlayedTime, '00:05');
      });

      test('should return null for no last played time', () {
        final noTime = TrickEntity(
          id: 'test',
          name: 'Test',
          imagePath: 'test.png',
          createdAt: DateTime.now(),
          lastPlayedTimeInSeconds: null,
        );
        expect(noTime.formattedLastPlayedTime, null);

        final zeroTime = TrickEntity(
          id: 'test',
          name: 'Test',
          imagePath: 'test.png',
          createdAt: DateTime.now(),
          lastPlayedTimeInSeconds: 0,
        );
        expect(zeroTime.formattedLastPlayedTime, null);
      });
    });

    group('YouTube URL with last played time', () {
      test('should append time to youtube.com URL', () {
        const youtubeUrl = 'https://youtube.com/watch?v=abc123';
        final trick = trickEntity.copyWith(
          youtubeUrl: youtubeUrl,
          lastPlayedTimeInSeconds: 120,
        );
        expect(
          trick.youtubeUrlWithLastPlayedTime,
          'https://youtube.com/watch?v=abc123&t=120s',
        );
      });

      test('should append time to youtu.be URL', () {
        const shortUrl = 'https://youtu.be/abc123';
        final trick = trickEntity.copyWith(
          youtubeUrl: shortUrl,
          lastPlayedTimeInSeconds: 120,
        );
        expect(
          trick.youtubeUrlWithLastPlayedTime,
          'https://youtu.be/abc123?t=120s',
        );
      });

      test('should return original URL when no last played time', () {
        const youtubeUrl = 'https://youtube.com/watch?v=abc123';
        final trick = TrickEntity(
          id: 'test',
          name: 'Test',
          imagePath: 'test.png',
          createdAt: DateTime.now(),
          youtubeUrl: youtubeUrl,
          lastPlayedTimeInSeconds: null,
        );
        expect(trick.youtubeUrlWithLastPlayedTime, youtubeUrl);
      });
    });

    group('updateLastPlayedTime', () {
      test('should update last played time', () {
        final updated = trickEntity.updateLastPlayedTime(180);

        expect(updated.lastPlayedTimeInSeconds, 180);
        expect(updated.formattedLastPlayedTime, '03:00');
        // Other properties should remain the same
        expect(updated.id, trickEntity.id);
        expect(updated.name, trickEntity.name);
      });
    });

    group('Equality and HashCode', () {
      test('should be equal when all properties are the same', () {
        final other = TrickEntity(
          id: 'trick_1',
          name: 'Sit',
          petId: 'pet_1',
          date: DateTime(2024, 1, 16),
          progress: 50,
          imagePath: 'assets/images/sit.png',
          isCompleted: false,
          isVideo: false,
          difficulty: 'easy',
          duration: '5 minutes',
          youtubeUrl: 'https://youtube.com/watch?v=abc123',
          description: 'Basic sit trick',
          createdAt: testCreatedAt,
        );

        expect(trickEntity == other, true);
        expect(trickEntity.hashCode == other.hashCode, true);
      });

      test('should not be equal when properties differ', () {
        final other = trickEntity.copyWith(name: 'Different Name');

        expect(trickEntity == other, false);
        expect(trickEntity.hashCode == other.hashCode, false);
      });
    });

    group('toString', () {
      test('should return correct string representation', () {
        final stringRepresentation = trickEntity.toString();

        expect(
          stringRepresentation,
          'TrickEntity(id: trick_1, name: Sit, isCompleted: false, progress: 50)',
        );
      });
    });
  });
}

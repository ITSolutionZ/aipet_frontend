import 'package:aipet_frontend/shared/core/services/youtube_api_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late YouTubeApiService youTubeApiService;

  setUp(() {
    youTubeApiService = YouTubeApiService();
  });

  group('YouTubeApiService', () {
    group('searchPetTrainingVideos', () {
      test('should return mock videos when API key is missing', () async {
        // Act
        final result = await youTubeApiService.searchPetTrainingVideos(
          query: '강아지 훈련',
          maxResults: 10,
        );

        // Assert
        expect(result, isA<Result<List<YouTubeVideo>>>());
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, isA<List<YouTubeVideo>>());
        expect(result.dataOrNull!.isNotEmpty, isTrue);

        final videos = result.dataOrNull!;
        expect(videos.length, equals(3)); // Mock data returns 3 videos

        // Check first mock video
        final firstVideo = videos.first;
        expect(firstVideo.id, equals('mock_video_1'));
        expect(firstVideo.title, contains('강아지 기본 훈련'));
        expect(firstVideo.channelTitle, isNotEmpty);
        expect(firstVideo.duration, greaterThan(0));
        expect(firstVideo.viewCount, greaterThan(0));
      });

      test('should handle different query parameters', () async {
        // Act
        final result = await youTubeApiService.searchPetTrainingVideos(
          query: '고양이 놀이',
          maxResults: 5,
          order: 'viewCount',
        );

        // Assert
        expect(result, isA<Result<List<YouTubeVideo>>>());
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull!.isNotEmpty, isTrue);
      });
    });

    group('getPopularPetVideos', () {
      test('should return mock popular videos', () async {
        // Act
        final result = await youTubeApiService.getPopularPetVideos(
          maxResults: 20,
          regionCode: 'JP',
        );

        // Assert
        expect(result, isA<Result<List<YouTubeVideo>>>());
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull!.isNotEmpty, isTrue);

        final videos = result.dataOrNull!;
        expect(videos.length, equals(3)); // Mock data

        // Verify video properties
        for (final video in videos) {
          expect(video.id.isNotEmpty, isTrue);
          expect(video.title.isNotEmpty, isTrue);
          expect(video.channelTitle.isNotEmpty, isTrue);
          expect(video.url.startsWith('https://www.youtube.com/watch?v='), isTrue);
          expect(video.embedUrl.startsWith('https://www.youtube.com/embed/'), isTrue);
        }
      });
    });

    group('getVideoDetails', () {
      test('should return failure when API key is missing', () async {
        // Act
        final result = await youTubeApiService.getVideoDetails('test_video_id');

        // Assert
        expect(result, isA<Result<YouTubeVideo>>());
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, contains('API 키가 설정되지 않았습니다'));
      });
    });

    group('YouTubeVideo model', () {
      test('should format duration correctly', () {
        // Arrange
        final video = YouTubeVideo(
          id: 'test',
          title: 'Test Video',
          description: 'Test Description',
          thumbnailUrl: 'https://test.com/thumb.jpg',
          channelTitle: 'Test Channel',
          publishedAt: DateTime.now(),
          duration: 480, // 8 minutes
          viewCount: 1000,
          likeCount: 50,
          url: 'https://youtube.com/watch?v=test',
          embedUrl: 'https://youtube.com/embed/test',
        );

        // Act & Assert
        expect(video.formattedDuration, equals('8:00'));
      });

      test('should format view count correctly', () {
        // Test thousands
        const videoK = YouTubeVideo(
          id: 'test',
          title: 'Test',
          description: '',
          thumbnailUrl: '',
          channelTitle: '',
          publishedAt: DateTime.now(),
          duration: 0,
          viewCount: 1500,
          likeCount: 0,
          url: '',
          embedUrl: '',
        );
        expect(videoK.formattedViewCount, equals('1.5K'));

        // Test millions
        const videoM = YouTubeVideo(
          id: 'test',
          title: 'Test',
          description: '',
          thumbnailUrl: '',
          channelTitle: '',
          publishedAt: DateTime.now(),
          duration: 0,
          viewCount: 2500000,
          likeCount: 0,
          url: '',
          embedUrl: '',
        );
        expect(videoM.formattedViewCount, equals('2.5M'));

        // Test under 1000
        const videoRegular = YouTubeVideo(
          id: 'test',
          title: 'Test',
          description: '',
          thumbnailUrl: '',
          channelTitle: '',
          publishedAt: DateTime.now(),
          duration: 0,
          viewCount: 999,
          likeCount: 0,
          url: '',
          embedUrl: '',
        );
        expect(videoRegular.formattedViewCount, equals('999'));
      });

      test('should format like count correctly', () {
        final video = YouTubeVideo(
          id: 'test',
          title: 'Test',
          description: '',
          thumbnailUrl: '',
          channelTitle: '',
          publishedAt: DateTime.now(),
          duration: 0,
          viewCount: 0,
          likeCount: 2500,
          url: '',
          embedUrl: '',
        );

        expect(video.formattedLikeCount, equals('2.5K'));
      });

      test('should format time ago correctly', () {
        final now = DateTime.now();
        final threeDaysAgo = now.subtract(const Duration(days: 3));

        final video = YouTubeVideo(
          id: 'test',
          title: 'Test',
          description: '',
          thumbnailUrl: '',
          channelTitle: '',
          publishedAt: threeDaysAgo,
          duration: 0,
          viewCount: 0,
          likeCount: 0,
          url: '',
          embedUrl: '',
        );

        expect(video.timeAgo, equals('3일 전'));
      });
    });

    group('mock data validation', () {
      test('should provide consistent mock video structure', () async {
        // Act
        final result = await youTubeApiService.searchPetTrainingVideos(
          query: '테스트',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        final videos = result.dataOrNull!;

        for (final video in videos) {
          expect(video.id.isNotEmpty, isTrue);
          expect(video.title.isNotEmpty, isTrue);
          expect(video.description.isNotEmpty, isTrue);
          expect(video.thumbnailUrl.startsWith('https://'), isTrue);
          expect(video.channelTitle.isNotEmpty, isTrue);
          expect(video.publishedAt, isA<DateTime>());
          expect(video.duration, greaterThan(0));
          expect(video.viewCount, greaterThan(0));
          expect(video.likeCount, greaterThan(0));
          expect(video.url.startsWith('https://www.youtube.com/watch?v='), isTrue);
          expect(video.embedUrl.startsWith('https://www.youtube.com/embed/'), isTrue);
        }
      });

      test('should include diverse content types in mock data', () async {
        // Act
        final result = await youTubeApiService.searchPetTrainingVideos(query: '테스트');

        // Assert
        expect(result.isSuccess, isTrue);
        final videos = result.dataOrNull!;

        final titles = videos.map((v) => v.title).toList();
        expect(titles.any((title) => title.contains('강아지')), isTrue);
        expect(titles.any((title) => title.contains('고양이')), isTrue);
        expect(titles.any((title) => title.contains('반려동물')), isTrue);
      });
    });
  });
}
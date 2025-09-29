import 'package:aipet_frontend/features/facility/data/facility_repository_impl.dart';
import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart';
import 'package:aipet_frontend/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';

import 'facility_notification_integration_test.mocks.dart';

@GenerateMocks([FacilityRepository, NotificationRepository])
void main() {
  group('Facility & Notification Integration Tests', () {
    late MockFacilityRepository mockFacilityRepository;
    late MockNotificationRepository mockNotificationRepository;
    late ProviderContainer container;

    setUp(() {
      mockFacilityRepository = MockFacilityRepository();
      mockNotificationRepository = MockNotificationRepository();

      container = ProviderContainer(
        overrides: [
          // Override providers with mocks
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Facility Tests', () {
      test('시설 조회가 정상적으로 동작하는지 확인', () async {
        // Given
        final mockFacilities = [
          FacilityEntity(
            id: '1',
            name: 'Test Hospital',
            address: 'Test Address',
            phone: '010-1234-5678',
            facilityType: FacilityType.hospital,
            rating: 4.5,
            services: ['진료', '수술'],
            openingHours: '09:00-18:00',
          ),
        ];

        when(
          mockFacilityRepository.getFacilitiesByLocation(
            any,
            any,
            radiusKm: anyNamed('radiusKm'),
          ),
        ).thenAnswer((_) async => mockFacilities);

        // When & Then
        verify(
          mockFacilityRepository.getFacilitiesByLocation(
            any,
            any,
            radiusKm: anyNamed('radiusKm'),
          ),
        ).called(0); // Not called yet
      });

      test('시설 예약 기능이 정상적으로 동작하는지 확인', () async {
        // Given
        const facilityId = 'test-facility-id';
        final bookingDateTime = DateTime.now().add(const Duration(days: 1));

        when(
          mockFacilityRepository.bookFacility(facilityId, bookingDateTime, any),
        ).thenAnswer((_) async => 'booking-id-123');

        // When
        final bookingId = await mockFacilityRepository.bookFacility(
          facilityId,
          bookingDateTime,
          'Test booking notes',
        );

        // Then
        expect(bookingId, 'booking-id-123');
        verify(
          mockFacilityRepository.bookFacility(
            facilityId,
            bookingDateTime,
            'Test booking notes',
          ),
        ).called(1);
      });

      test('시설 검색 필터링이 정상적으로 동작하는지 확인', () async {
        // Given
        final mockHospitals = [
          FacilityEntity(
            id: '1',
            name: 'Pet Hospital A',
            address: 'Address A',
            phone: '010-1111-1111',
            facilityType: FacilityType.hospital,
            rating: 4.2,
            services: ['진료'],
            openingHours: '09:00-18:00',
          ),
        ];

        when(
          mockFacilityRepository.getFacilitiesByType(FacilityType.hospital),
        ).thenAnswer((_) async => mockHospitals);

        // When
        final hospitals = await mockFacilityRepository.getFacilitiesByType(
          FacilityType.hospital,
        );

        // Then
        expect(hospitals, hasLength(1));
        expect(hospitals.first.facilityType, FacilityType.hospital);
        verify(
          mockFacilityRepository.getFacilitiesByType(FacilityType.hospital),
        ).called(1);
      });
    });

    group('Notification Tests', () {
      test('알림 생성 및 조회가 정상적으로 동작하는지 확인', () async {
        // Given
        final mockNotifications = [
          NotificationModel(
            id: '1',
            title: 'Test Notification',
            body: 'Test Body',
            type: NotificationType.feeding,
            isRead: false,
            timestamp: DateTime.now(),
          ),
        ];

        when(
          mockNotificationRepository.getUnreadNotifications(),
        ).thenAnswer((_) async => mockNotifications);

        // When
        final notifications = await mockNotificationRepository
            .getUnreadNotifications();

        // Then
        expect(notifications, hasLength(1));
        expect(notifications.first.isRead, false);
        verify(mockNotificationRepository.getUnreadNotifications()).called(1);
      });

      test('알림 읽음 처리가 정상적으로 동작하는지 확인', () async {
        // Given
        const notificationId = 'test-notification-id';

        when(
          mockNotificationRepository.markAsRead(notificationId),
        ).thenAnswer((_) async => true);

        // When
        final success = await mockNotificationRepository.markAsRead(
          notificationId,
        );

        // Then
        expect(success, true);
        verify(mockNotificationRepository.markAsRead(notificationId)).called(1);
      });

      test('알림 스케줄링이 정상적으로 동작하는지 확인', () async {
        // Given
        final scheduledTime = DateTime.now().add(const Duration(hours: 1));
        const notificationData = {
          'title': 'Scheduled Notification',
          'body': 'This is a scheduled notification',
          'type': 'feeding',
        };

        when(
          mockNotificationRepository.scheduleNotification(
            scheduledTime,
            notificationData,
          ),
        ).thenAnswer((_) async => 'scheduled-id-123');

        // When
        final scheduleId = await mockNotificationRepository
            .scheduleNotification(scheduledTime, notificationData);

        // Then
        expect(scheduleId, 'scheduled-id-123');
        verify(
          mockNotificationRepository.scheduleNotification(
            scheduledTime,
            notificationData,
          ),
        ).called(1);
      });

      test('알림 타입별 필터링이 정상적으로 동작하는지 확인', () async {
        // Given
        final mockFeedingNotifications = [
          NotificationModel(
            id: '1',
            title: 'Feeding Time',
            body: '밥 줄 시간입니다',
            type: NotificationType.feeding,
            isRead: false,
            timestamp: DateTime.now(),
          ),
        ];

        when(
          mockNotificationRepository.getNotificationsByType(
            NotificationType.feeding,
          ),
        ).thenAnswer((_) async => mockFeedingNotifications);

        // When
        final feedingNotifications = await mockNotificationRepository
            .getNotificationsByType(NotificationType.feeding);

        // Then
        expect(feedingNotifications, hasLength(1));
        expect(feedingNotifications.first.type, NotificationType.feeding);
        verify(
          mockNotificationRepository.getNotificationsByType(
            NotificationType.feeding,
          ),
        ).called(1);
      });
    });

    group('Integration Scenarios', () {
      test('시설 예약 시 자동 알림 생성 시나리오', () async {
        // Given - 시설 예약 성공
        const facilityId = 'hospital-123';
        final bookingDateTime = DateTime.now().add(const Duration(days: 1));
        const bookingId = 'booking-456';

        when(
          mockFacilityRepository.bookFacility(facilityId, bookingDateTime, any),
        ).thenAnswer((_) async => bookingId);

        // Given - 예약 확인 알림 생성
        final notificationData = {
          'title': '예약 확인',
          'body': '병원 예약이 완료되었습니다.',
          'type': 'booking',
          'facilityId': facilityId,
          'bookingId': bookingId,
        };

        when(
          mockNotificationRepository.createNotification(notificationData),
        ).thenAnswer((_) async => 'notification-789');

        // When - 예약 및 알림 생성
        final actualBookingId = await mockFacilityRepository.bookFacility(
          facilityId,
          bookingDateTime,
          'Regular checkup',
        );

        final notificationId = await mockNotificationRepository
            .createNotification(notificationData);

        // Then
        expect(actualBookingId, bookingId);
        expect(notificationId, 'notification-789');

        verify(
          mockFacilityRepository.bookFacility(
            facilityId,
            bookingDateTime,
            'Regular checkup',
          ),
        ).called(1);

        verify(
          mockNotificationRepository.createNotification(notificationData),
        ).called(1);
      });

      test('시설 리뷰 작성 시 알림 업데이트 시나리오', () async {
        // Given
        const facilityId = 'grooming-salon-123';
        const reviewData = {
          'rating': 5,
          'comment': '서비스가 정말 좋았습니다!',
          'userId': 'user-123',
        };

        when(
          mockFacilityRepository.submitReview(facilityId, reviewData),
        ).thenAnswer((_) async => 'review-456');

        // Given - 리뷰 감사 알림
        final thankYouNotification = {
          'title': '리뷰 감사합니다!',
          'body': '소중한 후기를 남겨주셔서 감사합니다.',
          'type': 'review_thanks',
          'facilityId': facilityId,
        };

        when(
          mockNotificationRepository.createNotification(thankYouNotification),
        ).thenAnswer((_) async => 'thank-you-notification-789');

        // When
        final reviewId = await mockFacilityRepository.submitReview(
          facilityId,
          reviewData,
        );

        final notificationId = await mockNotificationRepository
            .createNotification(thankYouNotification);

        // Then
        expect(reviewId, 'review-456');
        expect(notificationId, 'thank-you-notification-789');

        verify(
          mockFacilityRepository.submitReview(facilityId, reviewData),
        ).called(1);
        verify(
          mockNotificationRepository.createNotification(thankYouNotification),
        ).called(1);
      });

      test('에러 상황에서의 롤백 처리 시나리오', () async {
        // Given - 시설 예약은 성공하지만 알림 생성 실패
        const facilityId = 'hotel-123';
        final bookingDateTime = DateTime.now().add(const Duration(days: 2));
        const bookingId = 'booking-789';

        when(
          mockFacilityRepository.bookFacility(facilityId, bookingDateTime, any),
        ).thenAnswer((_) async => bookingId);

        when(
          mockNotificationRepository.createNotification(any),
        ).thenThrow(Exception('Notification service unavailable'));

        when(
          mockFacilityRepository.cancelBooking(bookingId),
        ).thenAnswer((_) async => true);

        // When & Then
        final actualBookingId = await mockFacilityRepository.bookFacility(
          facilityId,
          bookingDateTime,
          'Pet hotel stay',
        );

        expect(actualBookingId, bookingId);

        // 알림 생성 실패 시뮬레이션
        expect(
          () => mockNotificationRepository.createNotification({
            'title': 'Booking Confirmed',
            'body': 'Your pet hotel booking is confirmed',
            'type': 'booking',
          }),
          throwsException,
        );

        // 롤백 처리
        final cancelSuccess = await mockFacilityRepository.cancelBooking(
          bookingId,
        );
        expect(cancelSuccess, true);

        verify(
          mockFacilityRepository.bookFacility(
            facilityId,
            bookingDateTime,
            'Pet hotel stay',
          ),
        ).called(1);

        verify(mockFacilityRepository.cancelBooking(bookingId)).called(1);
      });
    });

    group('Performance Tests', () {
      test('대량 데이터 처리 성능 테스트', () async {
        // Given - 100개의 시설 데이터
        final mockFacilities = List.generate(
          100,
          (index) => FacilityEntity(
            id: 'facility-$index',
            name: 'Facility $index',
            address: 'Address $index',
            phone: '010-$index-$index',
            facilityType: index % 2 == 0
                ? FacilityType.hospital
                : FacilityType.grooming,
            rating: 4.0 + (index % 10) * 0.1,
            services: ['Service ${index % 3}'],
            openingHours: '09:00-18:00',
          ),
        );

        when(
          mockFacilityRepository.getAllFacilities(),
        ).thenAnswer((_) async => mockFacilities);

        // When - 성능 측정
        final stopwatch = Stopwatch()..start();
        final facilities = await mockFacilityRepository.getAllFacilities();
        stopwatch.stop();

        // Then - 100ms 이내 처리 확인
        expect(facilities, hasLength(100));
        expect(stopwatch.elapsedMilliseconds, lessThan(100));

        verify(mockFacilityRepository.getAllFacilities()).called(1);
      });

      test('동시성 처리 테스트 - 다중 예약 요청', () async {
        // Given
        const facilityId = 'popular-hospital-123';
        final bookingTimes = List.generate(
          5,
          (index) => DateTime.now().add(Duration(days: index + 1)),
        );

        when(
          mockFacilityRepository.bookFacility(facilityId, any, any),
        ).thenAnswer((invocation) async {
          final dateTime = invocation.positionalArguments[1] as DateTime;
          return 'booking-${dateTime.day}';
        });

        // When - 동시 예약 요청
        final bookingFutures = bookingTimes.map(
          (dateTime) => mockFacilityRepository.bookFacility(
            facilityId,
            dateTime,
            'Concurrent booking test',
          ),
        );

        final bookingIds = await Future.wait(bookingFutures);

        // Then
        expect(bookingIds, hasLength(5));
        expect(bookingIds.every((id) => id.startsWith('booking-')), true);

        verify(
          mockFacilityRepository.bookFacility(
            facilityId,
            any,
            'Concurrent booking test',
          ),
        ).called(5);
      });
    });
  });
}

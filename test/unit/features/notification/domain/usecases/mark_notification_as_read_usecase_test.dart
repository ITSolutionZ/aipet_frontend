import 'package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart';
import 'package:aipet_frontend/features/notification/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'mark_notification_as_read_usecase_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  late MarkNotificationAsReadUseCase useCase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    useCase = MarkNotificationAsReadUseCase(mockRepository);
  });

  group('MarkNotificationAsReadUseCase', () {
    test(
      'should mark notification as read when repository call is successful',
      () async {
        // Arrange
        const notificationId = 'test-id';
        when(
          mockRepository.markAsRead(notificationId),
        ).thenAnswer((_) async {});

        // Act
        await useCase(notificationId);

        // Assert
        verify(mockRepository.markAsRead(notificationId)).called(1);
      },
    );

    test('should throw exception when repository call fails', () async {
      // Arrange
      const notificationId = 'test-id';
      when(
        mockRepository.markAsRead(notificationId),
      ).thenThrow(Exception('Failed to mark as read'));

      // Act & Assert
      expect(() => useCase(notificationId), throwsA(isA<Exception>()));
      verify(mockRepository.markAsRead(notificationId)).called(1);
    });
  });
}

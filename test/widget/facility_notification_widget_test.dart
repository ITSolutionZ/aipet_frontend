import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

/// 통합 위젯 테스트를 위한 간단한 테스트 위젯들
void main() {
  group('Facility & Notification Widget Tests', () {
    testWidgets('시설 카드 위젯 렌더링 테스트', (WidgetTester tester) async {
      // Given
      const facility = FacilityEntity(
        id: '1',
        name: 'Test Hospital',
        address: 'Test Address',
        phone: '010-1234-5678',
        facilityType: FacilityType.hospital,
        rating: 4.5,
        services: ['진료', '수술'],
        openingHours: '09:00-18:00',
      );

      // When
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: Scaffold(body: FacilityTestCard(facility: facility)),
          ),
        ),
      );

      // Then
      expect(find.text('Test Hospital'), findsOneWidget);
      expect(find.text('Test Address'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('알림 리스트 위젯 렌더링 테스트', (WidgetTester tester) async {
      // Given
      final notifications = [
        NotificationModel(
          id: '1',
          title: 'Test Notification',
          body: 'Test Body',
          type: NotificationType.feeding,
          isRead: false,
          timestamp: DateTime.now(),
        ),
        NotificationModel(
          id: '2',
          title: 'Read Notification',
          body: 'This is read',
          type: NotificationType.health,
          isRead: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

      // When
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NotificationTestList(notifications: notifications),
            ),
          ),
        ),
      );

      // Then
      expect(find.text('Test Notification'), findsOneWidget);
      expect(find.text('Read Notification'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget); // Feeding icon
      expect(
        find.byIcon(Icons.health_and_safety),
        findsOneWidget,
      ); // Health icon
    });

    testWidgets('빈 알림 리스트 상태 테스트', (WidgetTester tester) async {
      // Given
      const notifications = <NotificationModel>[];

      // When
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: Scaffold(
              body: NotificationTestList(notifications: notifications),
            ),
          ),
        ),
      );

      // Then
      expect(find.text('알림이 없습니다'), findsOneWidget);
    });

    testWidgets('시설 필터 위젯 상호작용 테스트', (WidgetTester tester) async {
      // Given
      bool hospitalSelected = false;
      bool groomingSelected = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return FacilityFilterWidget(
                    hospitalSelected: hospitalSelected,
                    groomingSelected: groomingSelected,
                    onHospitalToggle: (value) {
                      setState(() {
                        hospitalSelected = value;
                      });
                    },
                    onGroomingToggle: (value) {
                      setState(() {
                        groomingSelected = value;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      // When - 병원 필터 선택
      await tester.tap(find.text('병원'));
      await tester.pump();

      // Then
      expect(hospitalSelected, true);

      // When - 미용실 필터 선택
      await tester.tap(find.text('미용실'));
      await tester.pump();

      // Then
      expect(groomingSelected, true);
    });

    testWidgets('알림 읽음 처리 위젯 테스트', (WidgetTester tester) async {
      // Given
      bool isRead = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return NotificationItemWidget(
                    notification: NotificationModel(
                      id: '1',
                      title: 'Test Notification',
                      body: 'Test Body',
                      type: NotificationType.feeding,
                      isRead: isRead,
                      timestamp: DateTime.now(),
                    ),
                    onMarkAsRead: () {
                      setState(() {
                        isRead = true;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      // When - 알림 탭하여 읽음 처리
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // Then
      expect(isRead, true);
    });

    testWidgets('로딩 상태 위젯 테스트', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(home: Scaffold(body: LoadingStateWidget())),
        ),
      );

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('로딩중...'), findsOneWidget);
    });

    testWidgets('에러 상태 위젯 테스트', (WidgetTester tester) async {
      // Given
      bool retryPressed = false;

      // When
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ErrorStateWidget(
                message: '데이터 로딩에 실패했습니다',
                onRetry: () {
                  retryPressed = true;
                },
              ),
            ),
          ),
        ),
      );

      // Then
      expect(find.text('데이터 로딩에 실패했습니다'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);

      // When - 다시 시도 버튼 탭
      await tester.tap(find.text('다시 시도'));
      await tester.pump();

      // Then
      expect(retryPressed, true);
    });

    group('접근성 테스트', () {
      testWidgets('시설 카드 접근성 테스트', (WidgetTester tester) async {
        const facility = FacilityEntity(
          id: '1',
          name: 'Test Hospital',
          address: 'Test Address',
          phone: '010-1234-5678',
          facilityType: FacilityType.hospital,
          rating: 4.5,
          services: ['진료', '수술'],
          openingHours: '09:00-18:00',
        );

        await tester.pumpWidget(
          ProviderScope(
            child: const MaterialApp(
              home: Scaffold(body: FacilityTestCard(facility: facility)),
            ),
          ),
        );

        // 접근성 가이드라인 준수 확인
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      });

      testWidgets('알림 리스트 접근성 테스트', (WidgetTester tester) async {
        final notifications = [
          NotificationModel(
            id: '1',
            title: 'Test Notification',
            body: 'Test Body',
            type: NotificationType.feeding,
            isRead: false,
            timestamp: DateTime.now(),
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: NotificationTestList(notifications: notifications),
              ),
            ),
          ),
        );

        // 접근성 가이드라인 준수 확인
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      });
    });
  });
}

/// 테스트용 시설 카드 위젯
class FacilityTestCard extends StatelessWidget {
  final FacilityEntity facility;

  const FacilityTestCard({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(facility.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(facility.address),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                Text(facility.rating.toString()),
              ],
            ),
          ],
        ),
        leading: Icon(
          facility.facilityType == FacilityType.hospital
              ? Icons.local_hospital
              : Icons.content_cut,
        ),
      ),
    );
  }
}

/// 테스트용 알림 리스트 위젯
class NotificationTestList extends StatelessWidget {
  final List<NotificationModel> notifications;

  const NotificationTestList({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(child: Text('알림이 없습니다'));
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          title: Text(notification.title),
          subtitle: Text(notification.body),
          leading: Icon(_getNotificationIcon(notification.type)),
          trailing: notification.isRead
              ? const Icon(Icons.check, color: Colors.green)
              : const Icon(Icons.circle, color: Colors.blue),
        );
      },
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.feeding:
        return Icons.restaurant;
      case NotificationType.health:
        return Icons.health_and_safety;
      case NotificationType.exercise:
        return Icons.directions_run;
      case NotificationType.grooming:
        return Icons.content_cut;
      case NotificationType.vaccination:
        return Icons.vaccines;
      case NotificationType.medication:
        return Icons.medication;
      default:
        return Icons.notifications;
    }
  }
}

/// 테스트용 시설 필터 위젯
class FacilityFilterWidget extends StatelessWidget {
  final bool hospitalSelected;
  final bool groomingSelected;
  final ValueChanged<bool> onHospitalToggle;
  final ValueChanged<bool> onGroomingToggle;

  const FacilityFilterWidget({
    super.key,
    required this.hospitalSelected,
    required this.groomingSelected,
    required this.onHospitalToggle,
    required this.onGroomingToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilterChip(
          label: const Text('병원'),
          selected: hospitalSelected,
          onSelected: onHospitalToggle,
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('미용실'),
          selected: groomingSelected,
          onSelected: onGroomingToggle,
        ),
      ],
    );
  }
}

/// 테스트용 알림 항목 위젯
class NotificationItemWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkAsRead;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(notification.title),
      subtitle: Text(notification.body),
      trailing: notification.isRead
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: notification.isRead ? null : onMarkAsRead,
    );
  }
}

/// 테스트용 로딩 상태 위젯
class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('로딩중...'),
        ],
      ),
    );
  }
}

/// 테스트용 에러 상태 위젯
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

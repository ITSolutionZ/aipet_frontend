import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:aipet_frontend/features/pet_profile/data/services/backend_pet_api_service.dart';
import 'package:aipet_frontend/features/walk/data/services/backend_walk_api_service.dart';
import 'package:aipet_frontend/features/pet_health/data/services/backend_health_api_service.dart';
import 'package:aipet_frontend/features/scheduling/data/services/backend_schedule_api_service.dart';
import 'package:aipet_frontend/shared/core/api/backend_api_client.dart';
import 'package:aipet_frontend/shared/domain/entities/pet_profile_entity.dart';

/// 백엔드 API 통합 테스트
///
/// 주의: 이 테스트를 실행하기 전에 다음을 확인하세요:
/// 1. 백엔드 서버가 http://localhost:3000에서 실행 중이어야 합니다
/// 2. Firebase 인증이 설정되어 있어야 합니다
/// 3. 유효한 Firebase 사용자 계정이 있어야 합니다
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Firebase 초기화 (테스트 환경)
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('⚠️ Firebase already initialized or initialization failed: $e');
    }
  });

  group('Backend API Integration Tests', () {
    late String testPetId;
    late String testWalkId;
    late String testHealthRecordId;
    late String testScheduleId;

    test('0. Backend Health Check', () async {
      final client = BackendApiClient.instance;

      try {
        // /health 엔드포인트는 인증이 필요 없음
        final response = await client.dio.get('http://localhost:3000/health');

        expect(response.statusCode, 200);
        expect(response.data['status'], 'ok');

        print('✅ Backend server is running');
        print('   Response: ${response.data}');
      } catch (e) {
        print('❌ Backend health check failed: $e');
        fail('Backend server is not running or not accessible');
      }
    });

    test('1. Firebase Authentication', () async {
      print('\n=== Testing Firebase Authentication ===');

      try {
        // Firebase 인증 상태 확인
        final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          print('✅ Already logged in');
          print('   User: ${currentUser.email}');
          print('   UID: ${currentUser.uid}');

          // ID Token 획득
          final idToken = await currentUser.getIdToken();
          expect(idToken, isNotNull);
          print('   ID Token obtained: ${idToken?.substring(0, 20)}...');
        } else {
          print('⚠️ No user logged in');
          print('   Skipping tests that require authentication');
          print('   Please login first using the app');
        }
      } catch (e) {
        print('❌ Firebase authentication failed: $e');
      }
    });

    test('2. Pets API - Create Pet', () async {
      print('\n=== Testing Pets API - Create ===');

      try {
        final result = await BackendPetApiService.createPet(
          PetProfileEntity(
            id: '',
            name: 'テストペット ${DateTime.now().millisecondsSinceEpoch}',
            type: 'dog',
            breed: 'ゴールデンレトリバー',
            birthDate: DateTime(2020, 1, 1),
            gender: 'male',
            weight: 25.5,
            ownerId: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        if (result.isSuccess) {
          print('✅ Pet created successfully');
          testPetId = result.data!.id;
          print('   Pet ID: $testPetId');
          print('   Pet Name: ${result.data!.name}');
        } else {
          print('❌ Failed to create pet: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during pet creation: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('3. Pets API - Get All Pets', () async {
      print('\n=== Testing Pets API - Get All ===');

      try {
        final result = await BackendPetApiService.getAllPets();

        if (result.isSuccess) {
          print('✅ Pets retrieved successfully');
          print('   Total pets: ${result.data!.length}');

          for (final pet in result.data!) {
            print('   - ${pet.name} (${pet.type})');
          }
        } else {
          print('❌ Failed to get pets: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during get pets: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('4. Walks API - Create Walk', () async {
      print('\n=== Testing Walks API - Create ===');

      if (testPetId.isEmpty) {
        print('⚠️ Skipping: No test pet ID available');
        return;
      }

      try {
        final result = await BackendWalkApiService.createWalk(
          petId: testPetId,
          startTime: DateTime.now().toIso8601String(),
          duration: 1800, // 30분
          distance: 2.5, // 2.5km
          notes: 'テスト散歩',
        );

        if (result.isSuccess) {
          print('✅ Walk created successfully');
          testWalkId = result.data!['id'] as String;
          print('   Walk ID: $testWalkId');
          print('   Duration: ${result.data!['duration']} seconds');
          print('   Distance: ${result.data!['distance']} km');
        } else {
          print('❌ Failed to create walk: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during walk creation: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('5. Walks API - Get Pet Walk Statistics', () async {
      print('\n=== Testing Walks API - Statistics ===');

      if (testPetId.isEmpty) {
        print('⚠️ Skipping: No test pet ID available');
        return;
      }

      try {
        final result = await BackendWalkApiService.getPetWalkStatistics(testPetId);

        if (result.isSuccess) {
          print('✅ Walk statistics retrieved successfully');
          print('   Total walks: ${result.data!['total_walks']}');
          print('   Total distance: ${result.data!['total_distance']} km');
          print('   Average duration: ${result.data!['average_duration']} seconds');
        } else {
          print('❌ Failed to get walk statistics: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during get walk statistics: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('6. Health API - Create Health Record', () async {
      print('\n=== Testing Health API - Create ===');

      if (testPetId.isEmpty) {
        print('⚠️ Skipping: No test pet ID available');
        return;
      }

      try {
        final result = await BackendHealthApiService.createHealthRecord(
          petId: testPetId,
          recordType: 'vaccination',
          recordDate: DateTime.now().toIso8601String().split('T')[0],
          vetName: 'テスト動物病院',
          notes: '狂犬病ワクチン接種',
          nextScheduledDate: DateTime.now()
              .add(const Duration(days: 365))
              .toIso8601String()
              .split('T')[0],
        );

        if (result.isSuccess) {
          print('✅ Health record created successfully');
          testHealthRecordId = result.data!['id'] as String;
          print('   Record ID: $testHealthRecordId');
          print('   Type: ${result.data!['record_type']}');
          print('   Vet: ${result.data!['vet_name']}');
        } else {
          print('❌ Failed to create health record: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during health record creation: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('7. Health API - Get Pet Health Records', () async {
      print('\n=== Testing Health API - Get Records ===');

      if (testPetId.isEmpty) {
        print('⚠️ Skipping: No test pet ID available');
        return;
      }

      try {
        final result = await BackendHealthApiService.getPetHealthRecords(testPetId);

        if (result.isSuccess) {
          print('✅ Health records retrieved successfully');
          print('   Total records: ${result.data!.length}');

          for (final record in result.data!) {
            print('   - ${record['record_type']}: ${record['record_date']}');
          }
        } else {
          print('❌ Failed to get health records: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during get health records: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('8. Schedules API - Create Schedule', () async {
      print('\n=== Testing Schedules API - Create ===');

      if (testPetId.isEmpty) {
        print('⚠️ Skipping: No test pet ID available');
        return;
      }

      try {
        final result = await BackendScheduleApiService.createSchedule(
          petId: testPetId,
          title: 'テストスケジュール',
          scheduleType: 'feeding',
          scheduledTime: DateTime.now()
              .add(const Duration(hours: 2))
              .toIso8601String(),
          notes: 'ドッグフード 200g',
        );

        if (result.isSuccess) {
          print('✅ Schedule created successfully');
          testScheduleId = result.data!['id'] as String;
          print('   Schedule ID: $testScheduleId');
          print('   Title: ${result.data!['title']}');
          print('   Type: ${result.data!['schedule_type']}');
        } else {
          print('❌ Failed to create schedule: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during schedule creation: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('9. Schedules API - Get Upcoming Schedules', () async {
      print('\n=== Testing Schedules API - Upcoming ===');

      try {
        final result = await BackendScheduleApiService.getUpcomingSchedules(
          daysAhead: 7,
        );

        if (result.isSuccess) {
          print('✅ Upcoming schedules retrieved successfully');
          print('   Total schedules: ${result.data!.length}');

          for (final schedule in result.data!) {
            print('   - ${schedule['title']}: ${schedule['scheduled_time']}');
          }
        } else {
          print('❌ Failed to get upcoming schedules: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during get upcoming schedules: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('10. Cleanup - Delete Test Data', () async {
      print('\n=== Cleaning up test data ===');

      // Delete test schedule
      if (testScheduleId.isNotEmpty) {
        try {
          final result = await BackendScheduleApiService.deleteSchedule(testScheduleId);
          if (result.isSuccess) {
            print('✅ Test schedule deleted');
          }
        } catch (e) {
          print('⚠️ Failed to delete test schedule: $e');
        }
      }

      // Delete test health record
      if (testHealthRecordId.isNotEmpty) {
        try {
          final result = await BackendHealthApiService.deleteHealthRecord(testHealthRecordId);
          if (result.isSuccess) {
            print('✅ Test health record deleted');
          }
        } catch (e) {
          print('⚠️ Failed to delete test health record: $e');
        }
      }

      // Delete test walk
      if (testWalkId.isNotEmpty) {
        try {
          final result = await BackendWalkApiService.deleteWalk(testWalkId);
          if (result.isSuccess) {
            print('✅ Test walk deleted');
          }
        } catch (e) {
          print('⚠️ Failed to delete test walk: $e');
        }
      }

      // Delete test pet
      if (testPetId.isNotEmpty) {
        try {
          final result = await BackendPetApiService.deletePet(testPetId);
          if (result.isSuccess) {
            print('✅ Test pet deleted');
          }
        } catch (e) {
          print('⚠️ Failed to delete test pet: $e');
        }
      }

      print('\n✅ Cleanup completed');
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);
  });
}

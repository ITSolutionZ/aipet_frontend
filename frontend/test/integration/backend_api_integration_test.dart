import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:aipet_frontend/features/pet_profile/data/services/backend_pet_api_service.dart';
import 'package:aipet_frontend/features/walk/data/services/backend_walk_api_service.dart';
import 'package:aipet_frontend/features/pet_health/data/services/backend_health_api_service.dart';
import 'package:aipet_frontend/features/scheduling/data/services/backend_schedule_api_service.dart';
import 'package:aipet_frontend/features/scheduling/domain/entities/schedule_entity.dart';
import 'package:aipet_frontend/features/notification/data/services/backend_notification_api_service.dart';
import 'package:aipet_frontend/features/community/data/services/backend_board_api_service.dart';
import 'package:aipet_frontend/features/pet_health/data/services/backend_daily_health_api_service.dart';
import 'package:aipet_frontend/features/facility/data/services/backend_booking_api_service.dart';
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
    late String testWeightRecordId;
    late String testScheduleId;
    late String testPostId;
    late String testCommentId;
    late String testDailyHealthRecordId;
    late String testBookingId;

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

    test('3.1. Pets API - Update Pet', () async {
      print('\n=== Testing Pets API - Update ===');

      if (testPetId.isEmpty) {
        print('⚠️ Skipping: No test pet ID available');
        return;
      }

      try {
        // Get current pet data first
        final getResult = await BackendPetApiService.getPetById(testPetId);
        if (!getResult.isSuccess || getResult.data == null) {
          print('❌ Failed to get pet for update');
          return;
        }

        final pet = getResult.data!;
        final updatedPet = pet.copyWith(
          weight: 27.0, // 체중 변경: 25.5 -> 27.0
          breed: 'ラブラドールレトリバー', // 품종 변경
        );

        final result = await BackendPetApiService.updatePet(updatedPet);

        if (result.isSuccess) {
          print('✅ Pet updated successfully');
          print('   Updated Weight: ${result.data!.weight}kg');
          print('   Updated Breed: ${result.data!.breed}');
        } else {
          print('❌ Failed to update pet: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during pet update: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('3.2. Pets API - Get Pet by ID', () async {
      print('\n=== Testing Pets API - Get by ID ===');

      if (testPetId.isEmpty) {
        print('⚠️ Skipping: No test pet ID available');
        return;
      }

      try {
        final result = await BackendPetApiService.getPetById(testPetId);

        if (result.isSuccess && result.data != null) {
          print('✅ Pet retrieved successfully');
          print('   Pet ID: ${result.data!.id}');
          print('   Name: ${result.data!.name}');
          print('   Type: ${result.data!.type}');
          print('   Weight: ${result.data!.weight}kg');
          print('   Breed: ${result.data!.breed}');
        } else {
          print('❌ Failed to get pet: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during get pet by ID: $e');
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
          startTime: DateTime.now(),
          durationMinutes: 30, // 30분
          distanceMeters: 2500, // 2.5km = 2500m
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
        final result = await BackendWalkApiService.getWalkStats(petId: testPetId);

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

    test('7.5. Weight History API - Create, Update, Delete', () async {
      print('\n=== Testing Weight History API ===');

      if (testPetId.isEmpty) {
        print('⚠️ Skipping: No test pet ID available');
        return;
      }

      try {
        // Create weight record
        print('\n--- Create Weight Record ---');
        final createResult = await BackendHealthApiService.createWeightRecord(
          petId: testPetId,
          weight: 12.5,
          measuredAt: DateTime.now(),
          notes: 'テスト体重記録',
        );

        if (createResult.isSuccess) {
          print('✅ Weight record created successfully');
          testWeightRecordId = createResult.data!['id'] as String;
          print('   Weight Record ID: $testWeightRecordId');
          print('   Weight: ${createResult.data!['weight']}kg');
        } else {
          print('❌ Failed to create weight record: ${createResult.message}');
          return;
        }

        // Update weight record
        print('\n--- Update Weight Record ---');
        final updateResult = await BackendHealthApiService.updateWeightRecord(
          petId: testPetId,
          weightId: testWeightRecordId,
          weight: 13.0,
          notes: 'テスト体重記録 (更新)',
        );

        if (updateResult.isSuccess) {
          print('✅ Weight record updated successfully');
          print('   Updated Weight: ${updateResult.data!['weight']}kg');
        } else {
          print('❌ Failed to update weight record: ${updateResult.message}');
        }

        // Get weight history
        print('\n--- Get Weight History ---');
        final historyResult = await BackendHealthApiService.getWeightHistory(
          petId: testPetId,
        );

        if (historyResult.isSuccess) {
          print('✅ Weight history retrieved successfully');
          print('   Total records: ${historyResult.data!.length}');
        } else {
          print('❌ Failed to get weight history: ${historyResult.message}');
        }

        // Delete weight record (will be tested in cleanup)
        // We'll keep this for cleanup phase
      } catch (e) {
        print('❌ Exception during weight history test: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('8. Schedules API - Create Schedule', () async {
      print('\n=== Testing Schedules API - Create ===');

      if (testPetId.isEmpty) {
        print('⚠️ Skipping: No test pet ID available');
        return;
      }

      try {
        // ScheduleEntity 생성
        final schedule = ScheduleEntity(
          id: '',
          title: 'テストスケジュール ${DateTime.now().millisecondsSinceEpoch}',
          description: 'ドッグフード 200g',
          startDateTime: DateTime.now().add(const Duration(hours: 2)),
          type: ScheduleType.feeding,
          status: ScheduleStatus.pending,
          priority: SchedulePriority.normal,
          petId: testPetId,
          petName: 'Test Pet',
          hasReminder: true,
          reminderTime: const Duration(minutes: 30),
          isRecurring: false,
          notes: 'Integration test schedule',
          createdAt: DateTime.now(),
        );

        final result = await BackendScheduleApiService.createSchedule(schedule);

        if (result.isSuccess) {
          print('✅ Schedule created successfully');
          testScheduleId = result.data!.id;
          print('   Schedule ID: $testScheduleId');
          print('   Title: ${result.data!.title}');
          print('   Type: ${result.data!.type}');
          print('   Status: ${result.data!.status}');
        } else {
          print('❌ Failed to create schedule: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during schedule creation: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('9. Schedules API - Get All Schedules', () async {
      print('\n=== Testing Schedules API - Get All ===');

      try {
        final result = await BackendScheduleApiService.getSchedules();

        if (result.isSuccess) {
          print('✅ Schedules retrieved successfully');
          print('   Total schedules: ${result.data!.length}');

          for (final schedule in result.data!) {
            print('   - ${schedule.title}: ${schedule.startDateTime}');
            print('     Type: ${schedule.type}, Status: ${schedule.status}');
          }
        } else {
          print('❌ Failed to get schedules: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during get schedules: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('9.1. Schedules API - Get Schedule by ID', () async {
      print('\n=== Testing Schedules API - Get by ID ===');

      if (testScheduleId.isEmpty) {
        print('⚠️ Skipping: No test schedule ID available');
        return;
      }

      try {
        final result = await BackendScheduleApiService.getScheduleById(testScheduleId);

        if (result.isSuccess && result.data != null) {
          print('✅ Schedule retrieved successfully');
          print('   Schedule ID: ${result.data!.id}');
          print('   Title: ${result.data!.title}');
          print('   Type: ${result.data!.type}');
          print('   Status: ${result.data!.status}');
          print('   Start Time: ${result.data!.startDateTime}');
        } else {
          print('❌ Failed to get schedule: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during get schedule by ID: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('9.2. Schedules API - Update Schedule', () async {
      print('\n=== Testing Schedules API - Update ===');

      if (testScheduleId.isEmpty) {
        print('⚠️ Skipping: No test schedule ID available');
        return;
      }

      try {
        // Get current schedule first
        final getResult = await BackendScheduleApiService.getScheduleById(testScheduleId);
        if (!getResult.isSuccess || getResult.data == null) {
          print('❌ Failed to get schedule for update');
          return;
        }

        final schedule = getResult.data!;
        final updatedSchedule = schedule.copyWith(
          title: 'Updated Schedule Title',
          status: ScheduleStatus.confirmed,
          notes: 'Updated notes from integration test',
        );

        final result = await BackendScheduleApiService.updateSchedule(updatedSchedule);

        if (result.isSuccess) {
          print('✅ Schedule updated successfully');
          print('   Updated Title: ${result.data!.title}');
          print('   Updated Status: ${result.data!.status}');
          print('   Updated Notes: ${result.data!.notes}');
        } else {
          print('❌ Failed to update schedule: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during schedule update: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('9.3. Schedules API - Update Schedule Status', () async {
      print('\n=== Testing Schedules API - Update Status ===');

      if (testScheduleId.isEmpty) {
        print('⚠️ Skipping: No test schedule ID available');
        return;
      }

      try {
        final result = await BackendScheduleApiService.updateScheduleStatus(
          testScheduleId,
          ScheduleStatus.completed,
        );

        if (result.isSuccess) {
          print('✅ Schedule status updated successfully');
          print('   New Status: completed');
        } else {
          print('❌ Failed to update schedule status: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during schedule status update: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('9.4. Schedules API - Delete Schedule', () async {
      print('\n=== Testing Schedules API - Delete ===');

      if (testScheduleId.isEmpty) {
        print('⚠️ Skipping: No test schedule ID available');
        return;
      }

      try {
        final result = await BackendScheduleApiService.deleteSchedule(testScheduleId);

        if (result.isSuccess) {
          print('✅ Schedule deleted successfully');
          print('   Deleted Schedule ID: $testScheduleId');
        } else {
          print('❌ Failed to delete schedule: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during schedule deletion: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('9.5. Notification Settings API - Get, Update', () async {
      print('\n=== Testing Notification Settings API ===');

      try {
        // Get notification settings
        print('\n--- Get Notification Settings ---');
        final getResult = await BackendNotificationApiService.getNotificationSettings();

        if (getResult.isSuccess) {
          print('✅ Notification settings retrieved successfully');
          print('   Push Enabled: ${getResult.data!['pushEnabled']}');
          print('   Email Enabled: ${getResult.data!['emailEnabled']}');
          print('   Notification Types: ${getResult.data!['notificationTypes']}');
        } else {
          print('❌ Failed to get notification settings: ${getResult.message}');
        }

        // Update notification settings
        print('\n--- Update Notification Settings ---');
        final updateResult = await BackendNotificationApiService.updateNotificationSettings(
          pushEnabled: false,
          emailEnabled: true,
          notificationTypes: {
            'vaccination': true,
            'feeding': false,
            'walk': true,
            'medical': true,
            'general': false,
          },
        );

        if (updateResult.isSuccess) {
          print('✅ Notification settings updated successfully');
        } else {
          print('❌ Failed to update notification settings: ${updateResult.message}');
        }

        // Verify updated settings
        print('\n--- Verify Updated Settings ---');
        final verifyResult = await BackendNotificationApiService.getNotificationSettings();

        if (verifyResult.isSuccess) {
          print('✅ Updated settings verified');
          print('   Push Enabled: ${verifyResult.data!['pushEnabled']}');
          print('   Email Enabled: ${verifyResult.data!['emailEnabled']}');
        } else {
          print('❌ Failed to verify updated settings: ${verifyResult.message}');
        }
      } catch (e) {
        print('❌ Exception during notification settings test: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('9.6. Notification Stats API - Get Statistics', () async {
      print('\n=== Testing Notification Stats API ===');

      try {
        final result = await BackendNotificationApiService.getNotificationStats();

        if (result.isSuccess) {
          print('✅ Notification statistics retrieved successfully');
          print('   Total Count: ${result.data!['totalCount']}');
          print('   Unread Count: ${result.data!['unreadCount']}');
          print('   Read Count: ${result.data!['readCount']}');
        } else {
          print('❌ Failed to get notification statistics: ${result.message}');
        }
      } catch (e) {
        print('❌ Exception during notification stats test: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('9.7. Board API - Create, Read, Update, Delete Post', () async {
      print('\n=== Testing Board API - Posts ===');

      try {
        // Create post
        print('\n--- Create Post ---');
        final createResult = await BackendBoardApiService.createPost(
          title: 'テスト投稿',
          content: 'これはテスト投稿です。',
          category: 'question',
          tags: ['テスト', 'API'],
        );

        if (createResult.isSuccess) {
          print('✅ Post created successfully');
          testPostId = createResult.data!.id;
          print('   Post ID: $testPostId');
          print('   Title: ${createResult.data!.title}');
        } else {
          print('❌ Failed to create post: ${createResult.message}');
          return;
        }

        // Get post by ID
        print('\n--- Get Post by ID ---');
        final getResult = await BackendBoardApiService.getPostById(testPostId);

        if (getResult.isSuccess) {
          print('✅ Post retrieved successfully');
          print('   Title: ${getResult.data!.title}');
          print('   View Count: ${getResult.data!.viewCount}');
        } else {
          print('❌ Failed to get post: ${getResult.message}');
        }

        // Update post
        print('\n--- Update Post ---');
        final updateResult = await BackendBoardApiService.updatePost(
          postId: testPostId,
          title: 'テスト投稿 (更新)',
          content: 'これはテスト投稿です (更新)',
          category: 'tip',
          tags: ['テスト', 'API', '更新'],
        );

        if (updateResult.isSuccess) {
          print('✅ Post updated successfully');
          print('   Updated Title: ${updateResult.data!.title}');
        } else {
          print('❌ Failed to update post: ${updateResult.message}');
        }

        // Get posts list
        print('\n--- Get Posts List ---');
        final listResult = await BackendBoardApiService.getPosts(
          category: 'all',
          page: 1,
          limit: 10,
        );

        if (listResult.isSuccess) {
          print('✅ Posts list retrieved successfully');
          print('   Total posts: ${listResult.data!.length}');
        } else {
          print('❌ Failed to get posts list: ${listResult.message}');
        }
      } catch (e) {
        print('❌ Exception during board API test: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('9.8. Board API - Comments and Likes', () async {
      print('\n=== Testing Board API - Comments and Likes ===');

      if (testPostId.isEmpty) {
        print('⚠️ Skipping: No test post ID available');
        return;
      }

      try {
        // Create comment
        print('\n--- Create Comment ---');
        final commentResult = await BackendBoardApiService.createComment(
          postId: testPostId,
          content: 'これはテストコメントです。',
        );

        if (commentResult.isSuccess) {
          print('✅ Comment created successfully');
          testCommentId = commentResult.data!['id']?.toString() ?? '';
          print('   Comment ID: $testCommentId');
        } else {
          print('❌ Failed to create comment: ${commentResult.message}');
        }

        // Get comments
        print('\n--- Get Comments ---');
        final getCommentsResult = await BackendBoardApiService.getComments(testPostId);

        if (getCommentsResult.isSuccess) {
          print('✅ Comments retrieved successfully');
          print('   Total comments: ${getCommentsResult.data!.length}');
        } else {
          print('❌ Failed to get comments: ${getCommentsResult.message}');
        }

        // Toggle like (add)
        print('\n--- Toggle Like (Add) ---');
        final likeResult = await BackendBoardApiService.toggleLike(testPostId);

        if (likeResult.isSuccess) {
          print('✅ Like toggled successfully');
          print('   Liked: ${likeResult.data!['liked']}');
          print('   Like Count: ${likeResult.data!['likeCount']}');
        } else {
          print('❌ Failed to toggle like: ${likeResult.message}');
        }

        // Check like status
        print('\n--- Check Like Status ---');
        final statusResult = await BackendBoardApiService.checkLikeStatus(testPostId);

        if (statusResult.isSuccess) {
          print('✅ Like status checked successfully');
          print('   Is Liked: ${statusResult.data}');
        } else {
          print('❌ Failed to check like status: ${statusResult.message}');
        }

        // Toggle like (remove)
        print('\n--- Toggle Like (Remove) ---');
        final unlikeResult = await BackendBoardApiService.toggleLike(testPostId);

        if (unlikeResult.isSuccess) {
          print('✅ Like toggled successfully');
          print('   Liked: ${unlikeResult.data!['liked']}');
        } else {
          print('❌ Failed to toggle like: ${unlikeResult.message}');
        }
      } catch (e) {
        print('❌ Exception during board API test: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('9.9. Daily Health API - Create, Read, Update, Delete', () async {
      print('\n=== Testing Daily Health API ===');

      if (testPetId.isEmpty) {
        print('⚠️ Skipping: No test pet ID available');
        return;
      }

      try {
        // Create daily health record
        print('\n--- Create Daily Health Record ---');
        final today = DateTime.now().toIso8601String().split('T')[0];
        final createResult = await BackendDailyHealthApiService.createDailyHealthRecord(
          petId: int.parse(testPetId),
          recordDate: today,
          mealCount: 2,
          poopCount: 1,
          exerciseDuration: 30,
          sleepDuration: 480,
          mood: 'good',
          condition: 'excellent',
          symptoms: [],
          notes: 'テスト記録',
        );

        if (createResult.isSuccess) {
          print('✅ Daily health record created successfully');
          testDailyHealthRecordId = createResult.data!['id']?.toString() ?? '';
          print('   Record ID: $testDailyHealthRecordId');
          print('   Date: ${createResult.data!['record_date']}');
        } else {
          print('❌ Failed to create daily health record: ${createResult.message}');
          return;
        }

        // Get record by ID
        print('\n--- Get Daily Health Record by ID ---');
        final getResult = await BackendDailyHealthApiService.getDailyHealthRecordById(
          testDailyHealthRecordId,
        );

        if (getResult.isSuccess) {
          print('✅ Daily health record retrieved successfully');
          print('   Meal Count: ${getResult.data!['meal_count']}');
          print('   Poop Count: ${getResult.data!['poop_count']}');
        } else {
          print('❌ Failed to get daily health record: ${getResult.message}');
        }

        // Get record by date
        print('\n--- Get Daily Health Record by Date ---');
        final getByDateResult = await BackendDailyHealthApiService.getDailyHealthRecordByDate(
          petId: int.parse(testPetId),
          recordDate: today,
        );

        if (getByDateResult.isSuccess) {
          print('✅ Daily health record by date retrieved successfully');
          print('   Mood: ${getByDateResult.data!['mood']}');
          print('   Condition: ${getByDateResult.data!['condition']}');
        } else {
          print('❌ Failed to get daily health record by date: ${getByDateResult.message}');
        }

        // Update record
        print('\n--- Update Daily Health Record ---');
        final updateResult = await BackendDailyHealthApiService.updateDailyHealthRecord(
          recordId: testDailyHealthRecordId,
          mealCount: 3,
          poopCount: 2,
          mood: 'normal',
          notes: 'テスト記録 (更新)',
        );

        if (updateResult.isSuccess) {
          print('✅ Daily health record updated successfully');
          print('   Updated Meal Count: ${updateResult.data!['meal_count']}');
        } else {
          print('❌ Failed to update daily health record: ${updateResult.message}');
        }

        // Get records list
        print('\n--- Get Daily Health Records List ---');
        final listResult = await BackendDailyHealthApiService.getDailyHealthRecords(
          petId: int.parse(testPetId),
          limit: 10,
        );

        if (listResult.isSuccess) {
          print('✅ Daily health records list retrieved successfully');
          print('   Total records: ${listResult.data!.length}');
        } else {
          print('❌ Failed to get daily health records list: ${listResult.message}');
        }

        // Get stats
        print('\n--- Get Daily Health Stats ---');
        final statsResult = await BackendDailyHealthApiService.getDailyHealthStats(
          petId: int.parse(testPetId),
        );

        if (statsResult.isSuccess) {
          print('✅ Daily health stats retrieved successfully');
          final summary = statsResult.data!['summary'];
          print('   Total Records: ${summary['total_records']}');
          print('   Avg Meals: ${summary['avg_meals']}');
          print('   Avg Poops: ${summary['avg_poops']}');
        } else {
          print('❌ Failed to get daily health stats: ${statsResult.message}');
        }
      } catch (e) {
        print('❌ Exception during daily health API test: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('9.10. Booking API - Create, Read, Update, Cancel', () async {
      print('\n=== Testing Booking API ===');

      if (testPetId.isEmpty) {
        print('⚠️ Skipping: No test pet ID available');
        return;
      }

      try {
        // Create booking
        print('\n--- Create Booking ---');
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final bookingDate = tomorrow.toIso8601String().split('T')[0];
        final createResult = await BackendBookingApiService.createBooking(
          petId: int.parse(testPetId),
          facilityName: 'テスト動物病院',
          facilityType: 'hospital',
          bookingDate: bookingDate,
          bookingTime: '14:00',
          facilityAddress: '東京都渋谷区テスト1-2-3',
          facilityPhone: '03-1234-5678',
          serviceType: '健康診断',
          notes: 'テスト予約',
        );

        if (createResult.isSuccess) {
          print('✅ Booking created successfully');
          testBookingId = createResult.data!['id']?.toString() ?? '';
          print('   Booking ID: $testBookingId');
          print('   Date: ${createResult.data!['booking_date']}');
          print('   Time: ${createResult.data!['booking_time']}');
        } else {
          print('❌ Failed to create booking: ${createResult.message}');
          return;
        }

        // Get booking by ID
        print('\n--- Get Booking by ID ---');
        final getResult = await BackendBookingApiService.getBookingById(testBookingId);

        if (getResult.isSuccess) {
          print('✅ Booking retrieved successfully');
          print('   Facility: ${getResult.data!['facility_name']}');
          print('   Status: ${getResult.data!['status']}');
        } else {
          print('❌ Failed to get booking: ${getResult.message}');
        }

        // Update booking
        print('\n--- Update Booking ---');
        final updateResult = await BackendBookingApiService.updateBooking(
          bookingId: testBookingId,
          bookingTime: '15:00',
          notes: 'テスト予約 (更新)',
        );

        if (updateResult.isSuccess) {
          print('✅ Booking updated successfully');
          print('   Updated Time: ${updateResult.data!['booking_time']}');
        } else {
          print('❌ Failed to update booking: ${updateResult.message}');
        }

        // Get upcoming bookings
        print('\n--- Get Upcoming Bookings ---');
        final upcomingResult = await BackendBookingApiService.getUpcomingBookings(
          limit: 10,
        );

        if (upcomingResult.isSuccess) {
          print('✅ Upcoming bookings retrieved successfully');
          print('   Total upcoming bookings: ${upcomingResult.data!.length}');
        } else {
          print('❌ Failed to get upcoming bookings: ${upcomingResult.message}');
        }

        // Get bookings list
        print('\n--- Get Bookings List ---');
        final listResult = await BackendBookingApiService.getBookings(
          petId: int.parse(testPetId),
          limit: 50,
        );

        if (listResult.isSuccess) {
          print('✅ Bookings list retrieved successfully');
          print('   Total bookings: ${listResult.data!.length}');
        } else {
          print('❌ Failed to get bookings list: ${listResult.message}');
        }

        // Update booking status
        print('\n--- Update Booking Status ---');
        final statusResult = await BackendBookingApiService.updateBookingStatus(
          bookingId: testBookingId,
          status: 'confirmed',
        );

        if (statusResult.isSuccess) {
          print('✅ Booking status updated successfully');
          print('   New Status: ${statusResult.data!['status']}');
        } else {
          print('❌ Failed to update booking status: ${statusResult.message}');
        }

        // Cancel booking (will be tested in cleanup)
        // We'll keep this for cleanup phase
      } catch (e) {
        print('❌ Exception during booking API test: $e');
      }
    }, skip: firebase_auth.FirebaseAuth.instance.currentUser == null);

    test('10. Cleanup - Delete Test Data', () async {
      print('\n=== Cleaning up test data ===');

      // Cancel test booking
      if (testBookingId.isNotEmpty) {
        try {
          final result = await BackendBookingApiService.cancelBooking(testBookingId);
          if (result.isSuccess) {
            print('✅ Test booking cancelled');
          }
        } catch (e) {
          print('⚠️ Failed to cancel test booking: $e');
        }
      }

      // Delete test daily health record
      if (testDailyHealthRecordId.isNotEmpty) {
        try {
          final result = await BackendDailyHealthApiService.deleteDailyHealthRecord(
            testDailyHealthRecordId,
          );
          if (result.isSuccess) {
            print('✅ Test daily health record deleted');
          }
        } catch (e) {
          print('⚠️ Failed to delete test daily health record: $e');
        }
      }

      // Delete test comment (if needed separately - but CASCADE handles it)
      if (testCommentId.isNotEmpty) {
        try {
          final result = await BackendBoardApiService.deleteComment(
            postId: testPostId,
            commentId: testCommentId,
          );
          if (result.isSuccess) {
            print('✅ Test comment deleted');
          }
        } catch (e) {
          print('⚠️ Failed to delete test comment: $e');
        }
      }

      // Delete test post (this will CASCADE delete comments and likes)
      if (testPostId.isNotEmpty) {
        try {
          final result = await BackendBoardApiService.deletePost(testPostId);
          if (result.isSuccess) {
            print('✅ Test post deleted');
          }
        } catch (e) {
          print('⚠️ Failed to delete test post: $e');
        }
      }

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

      // Delete test weight record
      if (testWeightRecordId.isNotEmpty) {
        try {
          final result = await BackendHealthApiService.deleteWeightRecord(
            petId: testPetId,
            weightId: testWeightRecordId,
          );
          if (result.isSuccess) {
            print('✅ Test weight record deleted');
          }
        } catch (e) {
          print('⚠️ Failed to delete test weight record: $e');
        }
      }

      // Delete test walk
      if (testWalkId.isNotEmpty) {
        try {
          final result = await BackendWalkApiService.deleteWalk(
            petId: testPetId,
            walkId: testWalkId,
          );
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

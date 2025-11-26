import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/result.dart';
import 'firebase_token_service.dart';
import 'logger_service.dart';

/// Firestore를 사용한 사용자 설정 관리 서비스
class FirestoreSettingsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 사용자 설정 가져오기
  static Future<Result<Map<String, dynamic>>> getUserSettings() async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 사용자 설정 조회 - User: $userId');

      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .get();

      if (!docSnapshot.exists) {
        LoggerService.debug('⚠️ [Firestore] 설정 없음, 기본값 반환');
        return Result.success('기본 설정', {});
      }

      final settings = docSnapshot.data()!;

      LoggerService.debug('✅ [Firestore] 사용자 설정 조회 성공');
      return Result.success('설정을 불러왔습니다', settings);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 사용자 설정 조회 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('설정을 불러오는데 실패했습니다: $e');
    }
  }

  /// 사용자 설정 업데이트
  static Future<Result<void>> updateUserSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 사용자 설정 업데이트 - User: $userId');

      final settingsData = {
        ...settings,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .set(settingsData, SetOptions(merge: true));

      LoggerService.debug('✅ [Firestore] 사용자 설정 업데이트 성공');
      return Result.success('設定が更新されました', null);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 사용자 설정 업데이트 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('설정 업데이트에 실패했습니다: $e');
    }
  }

  /// 알림 설정 가져오기
  static Future<Result<Map<String, dynamic>>> getNotificationSettings() async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 알림 설정 조회 - User: $userId');

      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .get();

      if (!docSnapshot.exists) {
        LoggerService.debug('⚠️ [Firestore] 알림 설정 없음, 기본값 반환');
        return Result.success('기본 알림 설정', {
          'enabled': true,
          'walkReminder': true,
          'feedingReminder': true,
          'healthReminder': true,
        });
      }

      final settings = docSnapshot.data()!;

      LoggerService.debug('✅ [Firestore] 알림 설정 조회 성공');
      return Result.success('알림 설정을 불러왔습니다', settings);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 알림 설정 조회 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('알림 설정을 불러오는데 실패했습니다: $e');
    }
  }

  /// 알림 설정 업데이트
  static Future<Result<void>> updateNotificationSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 알림 설정 업데이트 - User: $userId');

      final settingsData = {
        ...settings,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set(settingsData, SetOptions(merge: true));

      LoggerService.debug('✅ [Firestore] 알림 설정 업데이트 성공');
      return Result.success('通知設定が更新されました', null);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 알림 설정 업데이트 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('알림 설정 업데이트에 실패했습니다: $e');
    }
  }

  /// 사용자 프로필 정보 가져오기
  static Future<Result<Map<String, dynamic>>> getUserProfile() async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 사용자 프로필 조회 - User: $userId');

      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        LoggerService.debug('⚠️ [Firestore] 사용자 프로필 없음');
        return Result.failure('ユーザープロフィールが見つかりません');
      }

      final profile = docSnapshot.data()!;

      LoggerService.debug('✅ [Firestore] 사용자 프로필 조회 성공');
      return Result.success('프로필을 불러왔습니다', profile);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 사용자 프로필 조회 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('프로필을 불러오는데 실패했습니다: $e');
    }
  }

  /// 사용자 프로필 정보 업데이트
  static Future<Result<void>> updateUserProfile(
    Map<String, dynamic> profile,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 사용자 프로필 업데이트 - User: $userId');

      final profileData = {
        ...profile,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .set(profileData, SetOptions(merge: true));

      LoggerService.debug('✅ [Firestore] 사용자 프로필 업데이트 성공');
      return Result.success('プロフィールが更新されました', null);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 사용자 프로필 업데이트 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('프로필 업데이트에 실패했습니다: $e');
    }
  }

  /// 특정 설정 값 가져오기
  static Future<Result<dynamic>> getSettingValue(String key) async {
    try {
      final settingsResult = await getUserSettings();
      if (!settingsResult.isSuccess) {
        return settingsResult;
      }

      final settings = settingsResult.dataOrNull ?? {};
      final value = settings[key];

      LoggerService.debug('✅ [Firestore] 설정 값 조회 성공 - Key: $key');
      return Result.success('설정 값을 불러왔습니다', value);
    } catch (e) {
      LoggerService.debug('❌ [Firestore] 설정 값 조회 실패: $e');
      return Result.failure('설정 값을 불러오는데 실패했습니다: $e');
    }
  }

  /// 특정 설정 값 업데이트
  static Future<Result<void>> updateSettingValue(
    String key,
    dynamic value,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 설정 값 업데이트 - Key: $key');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .set({
        key: value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      LoggerService.debug('✅ [Firestore] 설정 값 업데이트 성공');
      return Result.success('設定が更新されました', null);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 설정 값 업데이트 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('설정 업데이트에 실패했습니다: $e');
    }
  }
}

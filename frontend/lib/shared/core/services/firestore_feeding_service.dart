import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/result.dart';
import 'firebase_token_service.dart';
import 'logger_service.dart';

/// Firestore를 사용한 급식 관리 서비스
class FirestoreFeedingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 펫의 모든 급식 기록 가져오기
  static Future<Result<List<Map<String, dynamic>>>> getFeedingRecords(
    String petId,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 급식 기록 조회 - Pet: $petId');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .collection('feedings')
          .orderBy('timestamp', descending: true)
          .get();

      final records = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      LoggerService.debug('✅ [Firestore] 급식 기록 조회 성공: ${records.length}개');
      return Result.success('급식 기록을 불러왔습니다', records);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 급식 기록 조회 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('급식 기록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 급식 기록 추가
  static Future<Result<Map<String, dynamic>>> addFeedingRecord(
    String petId,
    Map<String, dynamic> record,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 급식 기록 추가 - Pet: $petId');

      final recordData = {
        ...record,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .collection('feedings')
          .add(recordData);

      final createdRecord = {
        'id': docRef.id,
        ...record,
      };

      LoggerService.debug('✅ [Firestore] 급식 기록 추가 성공 - ID: ${docRef.id}');
      return Result.success('급식 기록이 저장되었습니다', createdRecord);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 급식 기록 추가 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('급식 기록 저장에 실패했습니다: $e');
    }
  }

  /// 급식 스케줄 가져오기
  static Future<Result<Map<String, dynamic>>> getFeedingSchedule(
    String petId,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 급식 스케줄 조회 - Pet: $petId');

      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .collection('settings')
          .doc('feeding_schedule')
          .get();

      if (!docSnapshot.exists) {
        LoggerService.debug('⚠️ [Firestore] 급식 스케줄 없음, 기본값 반환');
        return Result.success('기본 급식 스케줄', {});
      }

      final schedule = docSnapshot.data()!;

      LoggerService.debug('✅ [Firestore] 급식 스케줄 조회 성공');
      return Result.success('급식 스케줄을 불러왔습니다', schedule);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 급식 스케줄 조회 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('급식 스케줄을 불러오는데 실패했습니다: $e');
    }
  }

  /// 급식 스케줄 업데이트
  static Future<Result<void>> updateFeedingSchedule(
    String petId,
    Map<String, dynamic> schedule,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 급식 스케줄 업데이트 - Pet: $petId');

      final scheduleData = {
        ...schedule,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .collection('settings')
          .doc('feeding_schedule')
          .set(scheduleData, SetOptions(merge: true));

      LoggerService.debug('✅ [Firestore] 급식 스케줄 업데이트 성공');
      return Result.success('급식 스케줄이 업데이트되었습니다', null);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 급식 스케줄 업데이트 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('급식 스케줄 업데이트에 실패했습니다: $e');
    }
  }

  /// 날짜별 급식 기록 조회
  static Future<Result<List<Map<String, dynamic>>>> getFeedingRecordsByDate(
    String petId,
    DateTime date,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 날짜별 급식 기록 조회');
      LoggerService.debug('   Pet: $petId, Date: $date');

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .collection('feedings')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .orderBy('timestamp', descending: true)
          .get();

      final records = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      LoggerService.debug('✅ [Firestore] 날짜별 급식 기록 조회 성공: ${records.length}개');
      return Result.success('급식 기록을 불러왔습니다', records);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 날짜별 급식 기록 조회 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('급식 기록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 급식 기록 삭제
  static Future<Result<void>> deleteFeedingRecord(
    String petId,
    String recordId,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 급식 기록 삭제');
      LoggerService.debug('   Pet: $petId, Record: $recordId');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .collection('feedings')
          .doc(recordId)
          .delete();

      LoggerService.debug('✅ [Firestore] 급식 기록 삭제 성공');
      return Result.success('급식 기록이 삭제되었습니다', null);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 급식 기록 삭제 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('급식 기록 삭제에 실패했습니다: $e');
    }
  }
}

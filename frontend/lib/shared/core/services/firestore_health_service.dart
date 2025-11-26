import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/daily/domain/entities/daily_health_record.dart';
import '../domain/result.dart';
import 'firebase_token_service.dart';
import 'logger_service.dart';

/// Firestore를 사용한 건강 기록 관리 서비스
class FirestoreHealthService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 펫의 모든 건강 기록 가져오기
  static Future<Result<List<DailyHealthRecord>>> getHealthRecords(
    String petId,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 건강 기록 조회 - Pet: $petId');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .collection('health')
          .orderBy('date', descending: true)
          .get();

      final records = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return DailyHealthRecord.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();

      LoggerService.debug('✅ [Firestore] 건강 기록 조회 성공: ${records.length}개');
      return Result.success('건강 기록을 불러왔습니다', records);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 건강 기록 조회 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('건강 기록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 특정 건강 기록 가져오기
  static Future<Result<DailyHealthRecord?>> getHealthRecordById(
    String petId,
    String recordId,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 건강 기록 상세 조회');
      LoggerService.debug('   Pet: $petId, Record: $recordId');

      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .collection('health')
          .doc(recordId)
          .get();

      if (!docSnapshot.exists) {
        LoggerService.debug('⚠️ [Firestore] 건강 기록을 찾을 수 없음');
        return Result.success('건강 기록을 찾을 수 없습니다', null);
      }

      final record = DailyHealthRecord.fromJson({
        'id': docSnapshot.id,
        ...docSnapshot.data()!,
      });

      LoggerService.debug('✅ [Firestore] 건강 기록 상세 조회 성공');
      return Result.success('건강 기록을 불러왔습니다', record);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 건강 기록 상세 조회 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('건강 기록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 건강 기록 생성
  static Future<Result<DailyHealthRecord>> createHealthRecord(
    DailyHealthRecord record,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 건강 기록 생성');
      LoggerService.debug('   Pet: ${record.petId}');

      final recordData = record.toJson();
      recordData.remove('id');
      recordData['createdAt'] = FieldValue.serverTimestamp();
      recordData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(record.petId)
          .collection('health')
          .add(recordData);

      final createdRecord = record.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      LoggerService.debug('✅ [Firestore] 건강 기록 생성 성공 - ID: ${docRef.id}');
      return Result.success('건강 기록이 저장되었습니다', createdRecord);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 건강 기록 생성 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('건강 기록 저장에 실패했습니다: $e');
    }
  }

  /// 건강 기록 업데이트
  static Future<Result<DailyHealthRecord>> updateHealthRecord(
    DailyHealthRecord record,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 건강 기록 업데이트 - ID: ${record.id}');

      final recordData = record.toJson();
      recordData.remove('id');
      recordData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(record.petId)
          .collection('health')
          .doc(record.id)
          .update(recordData);

      final updatedRecord = record.copyWith(updatedAt: DateTime.now());

      LoggerService.debug('✅ [Firestore] 건강 기록 업데이트 성공');
      return Result.success('건강 기록이 업데이트되었습니다', updatedRecord);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 건강 기록 업데이트 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('건강 기록 업데이트에 실패했습니다: $e');
    }
  }

  /// 건강 기록 삭제
  static Future<Result<void>> deleteHealthRecord(
    String petId,
    String recordId,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 건강 기록 삭제');
      LoggerService.debug('   Pet: $petId, Record: $recordId');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .collection('health')
          .doc(recordId)
          .delete();

      LoggerService.debug('✅ [Firestore] 건강 기록 삭제 성공');
      return Result.success('건강 기록이 삭제되었습니다', null);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 건강 기록 삭제 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('건강 기록 삭제에 실패했습니다: $e');
    }
  }

  /// 날짜 범위로 건강 기록 조회
  static Future<Result<List<DailyHealthRecord>>> getHealthRecordsByDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 날짜별 건강 기록 조회');
      LoggerService.debug('   Pet: $petId');
      LoggerService.debug('   범위: $startDate ~ $endDate');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .collection('health')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date', descending: true)
          .get();

      final records = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return DailyHealthRecord.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();

      LoggerService.debug('✅ [Firestore] 날짜별 건강 기록 조회 성공: ${records.length}개');
      return Result.success('건강 기록을 불러왔습니다', records);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 날짜별 건강 기록 조회 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('건강 기록을 불러오는데 실패했습니다: $e');
    }
  }
}

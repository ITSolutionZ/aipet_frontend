import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/walk/domain/entities/walk_record_entity.dart';
import '../domain/result.dart';
import 'firebase_token_service.dart';
import 'logger_service.dart';

/// Firestore를 사용한 산책 기록 관리 서비스
class FirestoreWalkService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 사용자의 모든 산책 기록 가져오기
  static Future<Result<List<WalkRecordEntity>>> getAllWalkRecords() async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 산책 기록 조회 시작 - User: $userId');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('walks')
          .orderBy('startTime', descending: true)
          .get();

      final walks = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return WalkRecordEntity.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();

      LoggerService.debug('✅ [Firestore] 산책 기록 조회 성공: ${walks.length}개');
      return Result.success('산책 기록을 불러왔습니다', walks);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 산책 기록 조회 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('산책 기록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 특정 펫의 산책 기록 가져오기
  static Future<Result<List<WalkRecordEntity>>> getWalkRecordsByPetId(
    String petId,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 펫별 산책 기록 조회 - Pet: $petId');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('walks')
          .where('petId', isEqualTo: petId)
          .orderBy('startTime', descending: true)
          .get();

      final walks = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return WalkRecordEntity.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();

      LoggerService.debug('✅ [Firestore] 펫별 산책 기록 조회 성공: ${walks.length}개');
      return Result.success('산책 기록을 불러왔습니다', walks);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 펫별 산책 기록 조회 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('산책 기록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 특정 산책 기록 가져오기
  static Future<Result<WalkRecordEntity?>> getWalkRecordById(String id) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 산책 기록 상세 조회 - ID: $id');

      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('walks')
          .doc(id)
          .get();

      if (!docSnapshot.exists) {
        LoggerService.debug('⚠️ [Firestore] 산책 기록을 찾을 수 없음');
        return Result.success('산책 기록을 찾을 수 없습니다', null);
      }

      final walk = WalkRecordEntity.fromJson({
        'id': docSnapshot.id,
        ...docSnapshot.data()!,
      });

      LoggerService.debug('✅ [Firestore] 산책 기록 상세 조회 성공');
      return Result.success('산책 기록을 불러왔습니다', walk);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 산책 기록 상세 조회 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('산책 기록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 새 산책 기록 생성
  static Future<Result<WalkRecordEntity>> createWalkRecord(
    WalkRecordEntity walk,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 산책 기록 생성 시작');
      LoggerService.debug('   Pet: ${walk.petName}');
      LoggerService.debug('   Distance: ${walk.distance}m');

      final walkData = walk.toJson();
      walkData.remove('id'); // Firestore가 ID를 생성

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('walks')
          .add(walkData);

      final createdWalk = walk.copyWith(id: docRef.id);

      LoggerService.debug('✅ [Firestore] 산책 기록 생성 성공 - ID: ${docRef.id}');
      return Result.success('산책 기록이 저장되었습니다', createdWalk);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 산책 기록 생성 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('산책 기록 저장에 실패했습니다: $e');
    }
  }

  /// 산책 기록 업데이트
  static Future<Result<WalkRecordEntity>> updateWalkRecord(
    WalkRecordEntity walk,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 산책 기록 업데이트 - ID: ${walk.id}');

      final walkData = walk.toJson();
      walkData.remove('id');
      walkData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('walks')
          .doc(walk.id)
          .update(walkData);

      LoggerService.debug('✅ [Firestore] 산책 기록 업데이트 성공');
      return Result.success('산책 기록이 업데이트되었습니다', walk);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 산책 기록 업데이트 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('산책 기록 업데이트에 실패했습니다: $e');
    }
  }

  /// 산책 기록 삭제
  static Future<Result<void>> deleteWalkRecord(String id) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 산책 기록 삭제 - ID: $id');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('walks')
          .doc(id)
          .delete();

      LoggerService.debug('✅ [Firestore] 산책 기록 삭제 성공');
      return Result.success('산책 기록이 삭제되었습니다', null);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 산책 기록 삭제 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('산책 기록 삭제에 실패했습니다: $e');
    }
  }

  /// 날짜 범위로 산책 기록 조회
  static Future<Result<List<WalkRecordEntity>>> getWalkRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return Result.failure('ログインが必要です');
      }

      LoggerService.debug('📡 [Firestore] 날짜별 산책 기록 조회');
      LoggerService.debug('   범위: $startDate ~ $endDate');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('walks')
          .where('startTime', isGreaterThanOrEqualTo: startDate)
          .where('startTime', isLessThanOrEqualTo: endDate)
          .orderBy('startTime', descending: true)
          .get();

      final walks = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return WalkRecordEntity.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();

      LoggerService.debug('✅ [Firestore] 날짜별 산책 기록 조회 성공: ${walks.length}개');
      return Result.success('산책 기록을 불러왔습니다', walks);
    } catch (e, stackTrace) {
      LoggerService.debug('❌ [Firestore] 날짜별 산책 기록 조회 실패: $e');
      LoggerService.debug('   StackTrace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      return Result.failure('산책 기록을 불러오는데 실패했습니다: $e');
    }
  }
}

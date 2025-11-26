import 'package:aipet_frontend/features/pet_profile/data/services/pet_local_storage_service.dart';
import 'package:aipet_frontend/shared/core/services/firestore_pet_service.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';

import '../domain/result.dart';
import 'firebase_token_service.dart';

/// 로컬 데이터를 Firebase Firestore로 마이그레이션하는 서비스
///
/// SQLite에 저장된 펫 데이터를 Firestore로 이전합니다.
class DataMigrationService {
  /// 로컬 펫 데이터를 Firestore로 마이그레이션
  ///
  /// Returns: 마이그레이션 결과 (성공 개수, 실패 개수)
  static Future<Result<Map<String, int>>> migratePetsToFirestore() async {
    try {
      print('🔄 [Migration] ローカルデータのマイグレーション開始');
      LoggerService.debug('🔄 [Migration] 로컬 데이터 마이그레이션 시작');

      // 1. 로그인 상태 확인
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        print('⚠️ [Migration] ログインが必要です');
        LoggerService.debug('⚠️ [Migration] 로그인이 필요합니다');
        return Result.failure('ログインが必要です');
      }

      print('✅ [Migration] ユーザー認証完了: $userId');
      LoggerService.debug('✅ [Migration] 사용자 인증 완료: $userId');

      // 2. 로컬 펫 데이터 가져오기
      final localPets = await PetLocalStorageService.getPets();

      if (localPets.isEmpty) {
        print('📭 [Migration] マイグレーションするデータがありません');
        LoggerService.debug('📭 [Migration] 마이그레이션할 데이터 없음');
        return Result.success('マイグレーションするデータがありません', {'success': 0, 'fail': 0});
      }

      print('📦 [Migration] ${localPets.length}匹のペットをマイグレーション中...');
      LoggerService.debug('📦 [Migration] ${localPets.length}개의 펫 마이그레이션 중...');

      // 3. 각 펫을 Firestore로 업로드
      int successCount = 0;
      int failCount = 0;

      for (final localPet in localPets) {
        try {
          print('   → ${localPet.name} (${localPet.type}) アップロード中...');
          LoggerService.debug(
            '   → ${localPet.name} (${localPet.type}) 업로드 중...',
          );

          // Firestore에 펫 생성
          final result = await FirestorePetService.createPet(localPet);

          if (result.isSuccess) {
            successCount++;
            print('   ✅ ${localPet.name} アップロード成功');
            LoggerService.debug('   ✅ ${localPet.name} 업로드 성공');
          } else {
            failCount++;
            print('   ❌ ${localPet.name} アップロード失敗: ${result.error}');
            LoggerService.debug(
              '   ❌ ${localPet.name} 업로드 실패: ${result.error}',
            );
          }
        } catch (e) {
          failCount++;
          print('   ❌ ${localPet.name} アップロード失敗: $e');
          LoggerService.debug('   ❌ ${localPet.name} 업로드 실패: $e');
        }
      }

      print('🎉 [Migration] マイグレーション完了: 成功 $successCount匹, 失敗 $failCount匹');
      LoggerService.debug(
        '🎉 [Migration] 마이그레이션 완료: 성공 $successCount개, 실패 $failCount개',
      );

      // 4. 성공한 경우 로컬 데이터 삭제 (선택사항)
      if (successCount > 0 && failCount == 0) {
        print('🧹 [Migration] ローカルデータのクリーンアップをスキップ (安全のため)');
        LoggerService.debug('🧹 [Migration] 로컬 데이터 정리 스킵 (안전을 위해)');
        // await _clearLocalPets();
        // print('🧹 [Migration] ローカルデータのクリーンアップ完了');
      } else if (failCount > 0) {
        print('⚠️ [Migration] 失敗があったため、ローカルデータは保持します');
        LoggerService.debug('⚠️ [Migration] 실패가 있어서 로컬 데이터 유지');
      }

      return Result.success('$successCount匹のペットをFirebaseに同期しました', {
        'success': successCount,
        'fail': failCount,
      });
    } catch (e, stackTrace) {
      print('❌ [Migration] エラー: $e');
      LoggerService.debug('❌ [Migration] 에러: $e');
      LoggerService.debug(
        '   StackTrace: ${stackTrace.toString().split('\n').take(5).join('\n')}',
      );
      return Result.failure('マイグレーションに失敗しました: $e');
    }
  }

  /// 로컬 펫 데이터 삭제 (마이그레이션 성공 후)
  static Future<void> _clearLocalPets() async {
    try {
      final localPets = await PetLocalStorageService.getPets();
      for (final pet in localPets) {
        await PetLocalStorageService.deletePet(pet.id);
      }
      LoggerService.debug('✅ 로컬 펫 데이터 정리 완료');
    } catch (e) {
      LoggerService.debug('⚠️ 로컬 데이터 정리 실패: $e');
    }
  }

  /// 마이그레이션 필요 여부 확인
  ///
  /// 로컬에 펫 데이터가 있고, Firestore에는 없으면 마이그레이션 필요
  static Future<bool> needsMigration() async {
    try {
      // 1. 로그인 확인
      final userId = FirebaseTokenService.getCurrentUserId();
      if (userId == null) {
        return false;
      }

      // 2. 로컬 펫 데이터 확인
      final localPets = await PetLocalStorageService.getPets();
      if (localPets.isEmpty) {
        return false;
      }

      // 3. Firestore 펫 데이터 확인
      final firestoreResult = await FirestorePetService.getAllPets();
      final firestorePets = firestoreResult.dataOrNull ?? [];

      // 로컬에는 있지만 Firestore에는 없으면 마이그레이션 필요
      final needsMigration = localPets.isNotEmpty && firestorePets.isEmpty;

      if (needsMigration) {
        print('📊 [Migration] マイグレーションが必要です');
        print('   ローカル: ${localPets.length}匹');
        print('   Firestore: ${firestorePets.length}匹');
        LoggerService.debug('📊 [Migration] 마이그레이션 필요');
        LoggerService.debug('   로컬: ${localPets.length}개');
        LoggerService.debug('   Firestore: ${firestorePets.length}개');
      }

      return needsMigration;
    } catch (e) {
      LoggerService.debug('⚠️ [Migration] 마이그레이션 필요 여부 확인 실패: $e');
      return false;
    }
  }
}

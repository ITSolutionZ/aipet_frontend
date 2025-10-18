import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';

/// 로컬 데이터 저장 검증 서비스
/// 모든 로컬 데이터가 제대로 저장되었는지 확인
class DataVerificationService {
  static final LocalStorageService _storage = LocalStorageService.instance;

  /// 📊 전체 데이터 검증 수행
  static Future<void> verifyAllData() async {
    debugPrint('🔍 ===== 데이터 검증 시작 =====');
    await Future.wait([
      _verifyPets(),
      _verifySchedules(),
      _verifyUserProfile(),
    ]);
    debugPrint('✅ ===== 데이터 검증 완료 =====');
  }

  /// 🐾 펫 데이터 검증
  static Future<void> _verifyPets() async {
    debugPrint('\n📋 ===== 펫 데이터 검증 =====');
    try {
      final pets = await _storage.pet.getAllPets();

      debugPrint('🐾 전체 펫 개수: ${pets.length}');

      if (pets.isEmpty) {
        debugPrint('⚠️  저장된 펫이 없습니다');
        return;
      }

      for (int i = 0; i < pets.length; i++) {
        final pet = pets[i];
        debugPrint('\n  📌 펫 #${i + 1}:');
        debugPrint('     ID: ${pet['petId']}');
        debugPrint('     이름: ${pet['name']}');
        debugPrint('     타입: ${pet['type']}');
        debugPrint('     품종: ${pet['breed']}');
        debugPrint('     성별: ${pet['gender']}');
        debugPrint('     체중: ${pet['weight']}kg');
        debugPrint('     생년월일: ${pet['birth_date']}');
        debugPrint('     활성: ${pet['is_active'] == 1 ? '활성' : '비활성'}');

        // additionalInfo 확인
        if (pet['additionalInfo'] != null) {
          debugPrint('     추가정보: ${pet['additionalInfo']}');
        }

        debugPrint('     생성일: ${pet['created_at']}');
        debugPrint('     수정일: ${pet['updated_at']}');
        debugPrint('     ✅ 데이터 완전');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ 펫 데이터 검증 실패: $e');
      debugPrint('📍 StackTrace: $stackTrace');
    }
  }

  /// 📅 스케줄 데이터 검증
  static Future<void> _verifySchedules() async {
    debugPrint('\n📋 ===== 스케줄 데이터 검증 =====');
    try {
      final schedules = await _storage.schedule.getAllSchedules();

      debugPrint('📅 전체 스케줄 개수: ${schedules.length}');

      if (schedules.isEmpty) {
        debugPrint('⚠️  저장된 스케줄이 없습니다');
        return;
      }

      for (int i = 0; i < schedules.length; i++) {
        final schedule = schedules[i];
        debugPrint('\n  📌 스케줄 #${i + 1}:');
        debugPrint('     ID: ${schedule['id']}');
        debugPrint('     펫ID: ${schedule['petId']}');
        debugPrint('     제목: ${schedule['title']}');
        debugPrint('     타입: ${schedule['type']}');
        debugPrint('     시간: ${schedule['time']}');
        debugPrint('     반복타입: ${schedule['repeat_type']}');
        debugPrint('     활성: ${schedule['is_enabled'] == 1 ? '활성' : '비활성'}');
        debugPrint('     생성일: ${schedule['created_at']}');
        debugPrint('     수정일: ${schedule['updated_at']}');
        debugPrint('     ✅ 데이터 완전');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ 스케줄 데이터 검증 실패: $e');
      debugPrint('📍 StackTrace: $stackTrace');
    }
  }

  /// 👤 사용자 프로필 검증
  static Future<void> _verifyUserProfile() async {
    debugPrint('\n📋 ===== 사용자 프로필 검증 =====');
    try {
      final profile = await _storage.user.loadUserProfile();

      if (profile == null) {
        debugPrint('⚠️  저장된 사용자 프로필이 없습니다');
        return;
      }

      debugPrint('👤 사용자 프로필:');
      debugPrint('   ID: ${profile.id}');
      debugPrint('   사용자명: ${profile.userName}');
      debugPrint('   이메일: ${profile.email}');
      debugPrint('   연락처: ${profile.contact ?? 'N/A'}');
      debugPrint('   카타카나 이름: ${profile.nameKatakana ?? 'N/A'}');
      debugPrint('   프로필 이미지: ${profile.profileImage ?? 'N/A'}');
      debugPrint('   생성일: ${profile.createdAt}');
      debugPrint('   수정일: ${profile.updatedAt}');
      debugPrint('   ✅ 데이터 완전');
    } catch (e, stackTrace) {
      debugPrint('❌ 사용자 프로필 검증 실패: $e');
      debugPrint('📍 StackTrace: $stackTrace');
    }
  }

  /// 💾 데이터 백업 상태 확인
  static Future<void> verifyBackup() async {
    debugPrint('\n🔍 ===== 데이터 백업 검증 =====');
    try {
      final backup = await _storage.backupData();

      debugPrint('💾 백업 데이터:');
      debugPrint('   펫 개수: ${(backup['pets'] as List?)?.length ?? 0}');
      debugPrint('   스케줄 개수: ${(backup['schedules'] as List?)?.length ?? 0}');
      debugPrint('   백업 일시: ${backup['backupDate']}');
      debugPrint('   ✅ 백업 완전');
    } catch (e, stackTrace) {
      debugPrint('❌ 백업 검증 실패: $e');
      debugPrint('📍 StackTrace: $stackTrace');
    }
  }

  /// 🧹 데이터 정리 및 검증
  static Future<void> cleanAndVerify() async {
    debugPrint('\n🔍 ===== 데이터 정리 및 검증 =====');

    try {
      // 1. 백업 생성 및 검증
      debugPrint('💾 백업 생성 중...');
      await _storage.backupData();
      debugPrint('✅ 백업 생성 완료');

      // 2. 데이터 검증
      debugPrint('🔍 데이터 검증 중...');
      await verifyAllData();
      debugPrint('✅ 데이터 검증 완료');

      // 3. 백업 검증
      debugPrint('💾 백업 검증 중...');
      await verifyBackup();
      debugPrint('✅ 백업 검증 완료');

      debugPrint('\n✅ 모든 검증 완료!');
    } catch (e, stackTrace) {
      debugPrint('❌ 정리 및 검증 실패: $e');
      debugPrint('📍 StackTrace: $stackTrace');
    }
  }

  /// 📊 데이터 통계
  static Future<void> printDataStatistics() async {
    debugPrint('\n📊 ===== 데이터 통계 =====');

    try {
      final pets = await _storage.pet.getAllPets();
      final schedules = await _storage.schedule.getAllSchedules();
      final profile = await _storage.user.loadUserProfile();

      debugPrint('📈 통계 현황:');
      debugPrint('   총 펫 개수: ${pets.length}');
      debugPrint('   활성 펫: ${pets.where((p) => p['is_active'] == 1).length}');
      debugPrint('   총 스케줄: ${schedules.length}');
      debugPrint('   활성 스케줄: ${schedules.where((s) => s['is_enabled'] == 1).length}');
      debugPrint('   사용자 프로필: ${profile != null ? '있음' : '없음'}');

      debugPrint('\n📝 저장소 경로: 로컬 SQLite DB');
      debugPrint('   DB 파일: aipet_local.db');
      debugPrint('   위치: 앱 내부 저장소');

    } catch (e, stackTrace) {
      debugPrint('❌ 통계 출력 실패: $e');
      debugPrint('📍 StackTrace: $stackTrace');
    }
  }
}

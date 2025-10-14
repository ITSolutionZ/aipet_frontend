import 'package:aipet_frontend/shared/services/local_data_manager.dart';
import 'package:flutter/foundation.dart';

import 'pet_registration_form_data.dart';

/// 펫 등록 폼 로컬 저장소 서비스
///
/// 펫 등록 폼 데이터를 로컬 저장소에 저장/로드/삭제하는 책임을 가진 클래스
class PetRegistrationStorageService {
  final LocalDataManager _localDataManager;

  PetRegistrationStorageService([LocalDataManager? localDataManager])
    : _localDataManager = localDataManager ?? LocalDataManager.instance;

  /// 폼 데이터를 로컬 저장소에 저장
  Future<void> saveFormData(PetRegistrationFormData formData) async {
    try {
      debugPrint('💾 Starting to save form data to local storage');
      if (!_localDataManager.isInitialized) {
        debugPrint('💾 Initializing LocalDataManager');
        await _localDataManager.initialize();
      }
      final jsonData = formData.toJson();
      debugPrint('💾 Form data to save: ${jsonData.toString()}');
      await _localDataManager.savePetRegistrationFormData(jsonData);
      debugPrint('💾 Form data saved successfully');
    } catch (e) {
      debugPrint('❌ 펫 등록 폼 데이터 저장 실패: $e');
    }
  }

  /// 로컬 저장소에서 폼 데이터 로드
  Future<PetRegistrationFormData?> loadFormData() async {
    try {
      debugPrint('📥 Starting to load saved form data');
      if (!_localDataManager.isInitialized) {
        debugPrint('📥 Initializing LocalDataManager for loading');
        await _localDataManager.initialize();
      }
      final savedData = await _localDataManager.loadPetRegistrationFormData();
      if (savedData != null) {
        debugPrint('📥 Found saved data: ${savedData.toString()}');
        return PetRegistrationFormData.fromJson(savedData);
      } else {
        debugPrint('📥 No saved data found');
        return null;
      }
    } catch (e) {
      debugPrint('❌ 펫 등록 폼 데이터 로드 실패: $e');
      return null;
    }
  }

  /// 로컬 저장소에서 폼 데이터 삭제
  Future<void> clearFormData() async {
    try {
      if (!_localDataManager.isInitialized) {
        await _localDataManager.initialize();
      }
      await _localDataManager.clearPetRegistrationFormData();
      debugPrint('🗑️ Form data cleared successfully');
    } catch (e) {
      debugPrint('❌ 펫 등록 폼 데이터 삭제 실패: $e');
    }
  }
}

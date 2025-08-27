import 'package:shared_preferences/shared_preferences.dart';

import 'encryption_service.dart';

/// 보안 저장소 서비스
///
/// SharedPreferences를 암호화하여 민감한 데이터를 안전하게 저장합니다.
class SecureStorageService {
  static SharedPreferences? _prefs;

  /// SharedPreferences 인스턴스를 초기화합니다.
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 암호화된 문자열을 저장합니다.
  ///
  /// [key] 저장할 키
  /// [value] 저장할 값
  ///
  /// Returns 저장 성공 여부
  static Future<bool> setString(String key, String value) async {
    await initialize();
    if (_prefs == null) return false;

    return EncryptionService.encryptAndSave(key, value, _prefs!);
  }

  /// 암호화된 문자열을 불러옵니다.
  ///
  /// [key] 불러올 키
  ///
  /// Returns 불러온 값 또는 null
  static Future<String?> getString(String key) async {
    await initialize();
    if (_prefs == null) return null;

    return EncryptionService.decryptAndLoad(key, _prefs!);
  }

  /// 암호화된 데이터를 삭제합니다.
  ///
  /// [key] 삭제할 키
  ///
  /// Returns 삭제 성공 여부
  static Future<bool> remove(String key) async {
    await initialize();
    if (_prefs == null) return false;

    return EncryptionService.deleteEncryptedData(key, _prefs!);
  }

  /// 모든 암호화된 데이터를 삭제합니다.
  ///
  /// Returns 삭제 성공 여부
  static Future<bool> clear() async {
    await initialize();
    if (_prefs == null) return false;

    return EncryptionService.clearAllEncryptedData(_prefs!);
  }

  /// 키가 존재하는지 확인합니다.
  ///
  /// [key] 확인할 키
  ///
  /// Returns 존재 여부
  static Future<bool> containsKey(String key) async {
    await initialize();
    if (_prefs == null) return false;

    return EncryptionService.isEncrypted(key, _prefs!);
  }

  /// 모든 키를 가져옵니다.
  ///
  /// Returns 모든 키 목록
  static Future<Set<String>> getKeys() async {
    await initialize();
    if (_prefs == null) return <String>{};

    final allKeys = _prefs!.getKeys();
    final encryptedKeys = allKeys.where(
      (key) =>
          key.startsWith('encryption_key_') &&
          !key.endsWith('_key') &&
          !key.endsWith('_iv'),
    );

    return encryptedKeys
        .map((key) => key.replaceFirst('encryption_key_', ''))
        .toSet();
  }

  /// 암호화되지 않은 일반 데이터 저장 (민감하지 않은 데이터용)
  ///
  /// [key] 저장할 키
  /// [value] 저장할 값
  ///
  /// Returns 저장 성공 여부
  static Future<bool> setStringUnencrypted(String key, String value) async {
    await initialize();
    if (_prefs == null) return false;

    return _prefs!.setString(key, value);
  }

  /// 암호화되지 않은 일반 데이터 불러오기 (민감하지 않은 데이터용)
  ///
  /// [key] 불러올 키
  ///
  /// Returns 불러온 값 또는 null
  static Future<String?> getStringUnencrypted(String key) async {
    await initialize();
    if (_prefs == null) return null;

    return _prefs!.getString(key);
  }

  /// 암호화되지 않은 일반 데이터 삭제 (민감하지 않은 데이터용)
  ///
  /// [key] 삭제할 키
  ///
  /// Returns 삭제 성공 여부
  static Future<bool> removeUnencrypted(String key) async {
    await initialize();
    if (_prefs == null) return false;

    return _prefs!.remove(key);
  }

  /// Boolean 값 저장 (암호화되지 않음)
  ///
  /// [key] 저장할 키
  /// [value] 저장할 값
  ///
  /// Returns 저장 성공 여부
  static Future<bool> setBool(String key, bool value) async {
    await initialize();
    if (_prefs == null) return false;

    return _prefs!.setBool(key, value);
  }

  /// Boolean 값 불러오기 (암호화되지 않음)
  ///
  /// [key] 불러올 키
  ///
  /// Returns 불러온 값 또는 null
  static Future<bool?> getBool(String key) async {
    await initialize();
    if (_prefs == null) return null;

    return _prefs!.getBool(key);
  }

  /// Integer 값 저장 (암호화되지 않음)
  ///
  /// [key] 저장할 키
  /// [value] 저장할 값
  ///
  /// Returns 저장 성공 여부
  static Future<bool> setInt(String key, int value) async {
    await initialize();
    if (_prefs == null) return false;

    return _prefs!.setInt(key, value);
  }

  /// Integer 값 불러오기 (암호화되지 않음)
  ///
  /// [key] 불러올 키
  ///
  /// Returns 불러온 값 또는 null
  static Future<int?> getInt(String key) async {
    await initialize();
    if (_prefs == null) return null;

    return _prefs!.getInt(key);
  }

  /// Double 값 저장 (암호화되지 않음)
  ///
  /// [key] 저장할 키
  /// [value] 저장할 값
  ///
  /// Returns 저장 성공 여부
  static Future<bool> setDouble(String key, double value) async {
    await initialize();
    if (_prefs == null) return false;

    return _prefs!.setDouble(key, value);
  }

  /// Double 값 불러오기 (암호화되지 않음)
  ///
  /// [key] 불러올 키
  ///
  /// Returns 불러온 값 또는 null
  static Future<double?> getDouble(String key) async {
    await initialize();
    if (_prefs == null) return null;

    return _prefs!.getDouble(key);
  }

  /// String 리스트 저장 (암호화되지 않음)
  ///
  /// [key] 저장할 키
  /// [value] 저장할 값
  ///
  /// Returns 저장 성공 여부
  static Future<bool> setStringList(String key, List<String> value) async {
    await initialize();
    if (_prefs == null) return false;

    return _prefs!.setStringList(key, value);
  }

  /// String 리스트 불러오기 (암호화되지 않음)
  ///
  /// [key] 불러올 키
  ///
  /// Returns 불러온 값 또는 null
  static Future<List<String>?> getStringList(String key) async {
    await initialize();
    if (_prefs == null) return null;

    return _prefs!.getStringList(key);
  }
}

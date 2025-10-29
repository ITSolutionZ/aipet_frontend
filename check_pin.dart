import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();
  
  // PIN 확인
  final savedPin = prefs.getString('user_pin');
  final pinEnabled = prefs.getBool('pin_enabled');
  
  print('======================================');
  print('🔐 현재 저장된 PIN 번호: $savedPin');
  print('🔐 PIN 활성화 상태: $pinEnabled');
  print('======================================');
  
  // 모든 키 확인
  final allKeys = prefs.getKeys();
  print('\n📋 저장된 모든 키:');
  for (var key in allKeys) {
    if (key.contains('pin') || key.contains('biometric')) {
      print('  - $key: ${prefs.get(key)}');
    }
  }
}

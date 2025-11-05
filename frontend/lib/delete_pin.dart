import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  
  // 삭제 전 확인
  final savedPin = prefs.getString('user_pin');
  print('======================================');
  print('🔐 삭제 전 PIN: $savedPin');
  
  // PIN 관련 데이터 삭제
  await prefs.remove('user_pin');
  await prefs.remove('pin_enabled');
  
  // 삭제 후 확인
  final afterPin = prefs.getString('user_pin');
  final afterEnabled = prefs.getBool('pin_enabled');
  
  print('✅ PIN 삭제 완료!');
  print('🔐 삭제 후 PIN: $afterPin');
  print('🔐 삭제 후 활성화 상태: $afterEnabled');
  print('======================================');
}

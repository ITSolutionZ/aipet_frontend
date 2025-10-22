import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// 데이터베이스의 모든 펫과 유저 데이터 삭제 스크립트
Future<void> main() async {
  try {
    debugPrint('🗄️ 데이터베이스 삭제 시작...');

    // 데이터베이스 경로
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'aipet_local.db');

    debugPrint('📁 데이터베이스 경로: $path');

    // 데이터베이스 열기
    final database = await openDatabase(path);

    // 모든 테이블의 데이터 삭제
    debugPrint('🧹 pets 테이블 삭제 중...');
    await database.delete('pets');

    debugPrint('🧹 user_profiles 테이블 삭제 중...');
    await database.delete('user_profiles');

    debugPrint('🧹 walk_records 테이블 삭제 중...');
    await database.delete('walk_records');

    debugPrint('🧹 health_records 테이블 삭제 중...');
    await database.delete('health_records');

    debugPrint('🧹 schedules 테이블 삭제 중...');
    await database.delete('schedules');

    debugPrint('🧹 activities 테이블 삭제 중...');
    await database.delete('activities');

    debugPrint('🧹 pet_user_relations 테이블 삭제 중...');
    await database.delete('pet_user_relations');

    debugPrint('🧹 ai_categories 테이블 삭제 중...');
    await database.delete('ai_categories');

    debugPrint('🧹 ai_keywords 테이블 삭제 중...');
    await database.delete('ai_keywords');

    // 데이터베이스 닫기
    await database.close();

    debugPrint('✅ 모든 데이터 삭제 완료!');
    debugPrint('');
    debugPrint('삭제된 테이블:');
    debugPrint('  - pets');
    debugPrint('  - user_profiles');
    debugPrint('  - walk_records');
    debugPrint('  - health_records');
    debugPrint('  - schedules');
    debugPrint('  - activities');
    debugPrint('  - pet_user_relations');
    debugPrint('  - ai_categories');
    debugPrint('  - ai_keywords');
  } catch (e) {
    debugPrint('❌ 에러 발생: $e');
  }
}

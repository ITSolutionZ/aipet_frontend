import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// 데이터베이스의 모든 펫과 유저 데이터 삭제 스크립트
Future<void> main() async {
  try {
    print('🗄️ 데이터베이스 삭제 시작...');

    // 데이터베이스 경로
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'aipet_local.db');

    print('📁 데이터베이스 경로: $path');

    // 데이터베이스 열기
    final database = await openDatabase(path);

    // 모든 테이블의 데이터 삭제
    print('🧹 pets 테이블 삭제 중...');
    await database.delete('pets');

    print('🧹 user_profiles 테이블 삭제 중...');
    await database.delete('user_profiles');

    print('🧹 walk_records 테이블 삭제 중...');
    await database.delete('walk_records');

    print('🧹 health_records 테이블 삭제 중...');
    await database.delete('health_records');

    print('🧹 schedules 테이블 삭제 중...');
    await database.delete('schedules');

    print('🧹 activities 테이블 삭제 중...');
    await database.delete('activities');

    print('🧹 pet_user_relations 테이블 삭제 중...');
    await database.delete('pet_user_relations');

    print('🧹 ai_categories 테이블 삭제 중...');
    await database.delete('ai_categories');

    print('🧹 ai_keywords 테이블 삭제 중...');
    await database.delete('ai_keywords');

    // 데이터베이스 닫기
    await database.close();

    print('✅ 모든 데이터 삭제 완료!');
    print('');
    print('삭제된 테이블:');
    print('  - pets');
    print('  - user_profiles');
    print('  - walk_records');
    print('  - health_records');
    print('  - schedules');
    print('  - activities');
    print('  - pet_user_relations');
    print('  - ai_categories');
    print('  - ai_keywords');
  } catch (e) {
    print('❌ 에러 발생: $e');
  }
}

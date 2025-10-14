import 'dart:convert';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// 로컬 데이터베이스 서비스
/// SQLite와 SharedPreferences를 활용한 로컬 데이터 저장소
class LocalDatabaseService {
  static LocalDatabaseService? _instance;
  static Database? _database;

  LocalDatabaseService._();

  static LocalDatabaseService get instance {
    _instance ??= LocalDatabaseService._();
    return _instance!;
  }

  /// SQLite 데이터베이스 초기화
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'aipet_local.db');

    return openDatabase(
      path,
      version: 3, // 버전을 더 높게 올려서 테이블 재생성 강제
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 데이터베이스 테이블 생성
  Future<void> _onCreate(Database db, int version) async {
    // 펫 정보 테이블
    await db.execute('''
      CREATE TABLE pets(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        breed TEXT,
        age INTEGER,
        weight REAL,
        gender TEXT,
        birth_date TEXT,
        profile_image TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        data TEXT
      )
    ''');

    // 급식 기록 테이블
    await db.execute('''
      CREATE TABLE feeding_records(
        id TEXT PRIMARY KEY,
        pet_id TEXT NOT NULL,
        amount REAL NOT NULL,
        food_type TEXT,
        feeding_time TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');

    // 산책 기록 테이블
    await db.execute('''
      CREATE TABLE walk_records(
        id TEXT PRIMARY KEY,
        pet_id TEXT NOT NULL,
        duration INTEGER NOT NULL,
        distance REAL,
        route TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');

    // 건강 기록 테이블
    await db.execute('''
      CREATE TABLE health_records(
        id TEXT PRIMARY KEY,
        pet_id TEXT NOT NULL,
        record_type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        vet_name TEXT,
        hospital_name TEXT,
        attachments TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');

    // 스케줄 테이블
    await db.execute('''
      CREATE TABLE schedules(
        id TEXT PRIMARY KEY,
        pet_id TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        time TEXT NOT NULL,
        repeat_type TEXT,
        is_enabled INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');

    // 활동 기록 테이블
    await db.execute('''
      CREATE TABLE activities(
        id TEXT PRIMARY KEY,
        pet_id TEXT NOT NULL,
        activity_type TEXT NOT NULL,
        name TEXT NOT NULL,
        progress INTEGER DEFAULT 0,
        is_completed INTEGER DEFAULT 0,
        metadata TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');

    // AI 채팅 기록 테이블
    await db.execute('''
      CREATE TABLE ai_chats(
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        message TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        metadata TEXT
      )
    ''');

    // 시설 즐겨찾기 테이블
    await db.execute('''
      CREATE TABLE facility_favorites(
        id TEXT PRIMARY KEY,
        facility_id TEXT NOT NULL,
        facility_name TEXT NOT NULL,
        facility_type TEXT NOT NULL,
        address TEXT,
        phone TEXT,
        latitude REAL,
        longitude REAL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 사용자 프로필 테이블
    await db.execute('''
      CREATE TABLE user_profiles(
        id TEXT PRIMARY KEY,
        user_name TEXT NOT NULL,
        email TEXT NOT NULL,
        name_katakana TEXT,
        contact TEXT,
        profile_image TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  /// 데이터베이스 업그레이드
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 향후 버전 업그레이드 시 사용
  }

  /// SharedPreferences 인스턴스 가져오기
  Future<SharedPreferences> get prefs async {
    return SharedPreferences.getInstance();
  }

  /// JSON 데이터를 SharedPreferences에 저장
  Future<bool> saveJsonToPrefs(String key, Map<String, dynamic> data) async {
    final pref = await prefs;
    return pref.setString(key, jsonEncode(data));
  }

  /// SharedPreferences에서 JSON 데이터 로드
  Future<Map<String, dynamic>?> loadJsonFromPrefs(String key) async {
    final pref = await prefs;
    final jsonString = pref.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /// 리스트 데이터를 SharedPreferences에 저장
  Future<bool> saveListToPrefs(
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    final pref = await prefs;
    return pref.setString(key, jsonEncode(data));
  }

  /// SharedPreferences에서 리스트 데이터 로드
  Future<List<Map<String, dynamic>>?> loadListFromPrefs(String key) async {
    final pref = await prefs;
    final jsonString = pref.getString(key);
    if (jsonString != null) {
      final list = jsonDecode(jsonString) as List;
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return null;
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  /// 데이터베이스 삭제 (테스트용)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'aipet_local.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}

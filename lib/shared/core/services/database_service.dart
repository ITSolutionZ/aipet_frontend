import 'dart:convert';

import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite 데이터베이스 서비스
class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'aipet.db';
  static const int _databaseVersion = 1;

  /// 싱글톤 인스턴스
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// 데이터베이스 인스턴스 가져오기
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 데이터베이스 초기화
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// 데이터베이스 테이블 생성
  Future<void> _createDatabase(Database db, int version) async {
    // Pet Profile 테이블
    await db.execute('''
      CREATE TABLE pet_profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        breed TEXT,
        birth_date TEXT NOT NULL,
        gender TEXT NOT NULL,
        weight REAL NOT NULL,
        image_path TEXT,
        owner_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        additional_info TEXT
      )
    ''');

    // Temporary Pet Data 테이블
    await db.execute('''
      CREATE TABLE temporary_pet_data (
        id TEXT PRIMARY KEY,
        step TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 인덱스 생성
    await db.execute('CREATE INDEX idx_pet_owner_id ON pet_profiles(owner_id)');
    await db.execute('CREATE INDEX idx_pet_type ON pet_profiles(type)');
  }

  /// 데이터베이스 업그레이드
  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // 향후 스키마 변경 시 여기에 마이그레이션 로직 추가
  }

  /// Pet Profile 저장
  Future<Result<void>> savePetProfile(PetProfileEntity pet) async {
    try {
      final db = await database;

      final petMap = {
        'id': pet.id,
        'name': pet.name,
        'type': pet.type,
        'breed': pet.breed,
        'birth_date': pet.birthDate.toIso8601String(),
        'gender': pet.gender,
        'weight': pet.weight,
        'image_path': pet.imagePath,
        'owner_id': pet.ownerId,
        'created_at': pet.createdAt.toIso8601String(),
        'updated_at': pet.updatedAt.toIso8601String(),
        'additional_info': jsonEncode(pet.additionalInfo),
      };

      await db.insert(
        'pet_profiles',
        petMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success('펫 프로필이 성공적으로 저장되었습니다', null);
    } catch (e) {
      return Result.failure('펫 프로필 저장에 실패했습니다: ${e.toString()}');
    }
  }

  /// Pet Profile 조회 (ID로)
  Future<Result<PetProfileEntity?>> getPetProfileById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pet_profiles',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return Result.success('펫을 찾을 수 없습니다', null);
      }

      final pet = _mapToPetProfile(maps.first);
      return Result.success('펫 프로필을 성공적으로 조회했습니다', pet);
    } catch (e) {
      return Result.failure('펫 프로필 조회에 실패했습니다: ${e.toString()}');
    }
  }

  /// 모든 Pet Profile 조회
  Future<Result<List<PetProfileEntity>>> getAllPetProfiles() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pet_profiles',
        orderBy: 'created_at DESC',
      );

      final pets = maps.map(_mapToPetProfile).toList();
      return Result.success('펫 목록을 성공적으로 조회했습니다', pets);
    } catch (e) {
      return Result.failure('펫 목록 조회에 실패했습니다: ${e.toString()}');
    }
  }

  /// Owner ID로 Pet Profile 조회
  Future<Result<List<PetProfileEntity>>> getPetProfilesByOwnerId(
    String ownerId,
  ) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pet_profiles',
        where: 'owner_id = ?',
        whereArgs: [ownerId],
        orderBy: 'created_at DESC',
      );

      final pets = maps.map(_mapToPetProfile).toList();
      return Result.success('사용자의 펫 목록을 성공적으로 조회했습니다', pets);
    } catch (e) {
      return Result.failure('사용자 펫 목록 조회에 실패했습니다: ${e.toString()}');
    }
  }

  /// Pet Profile 업데이트
  Future<Result<void>> updatePetProfile(PetProfileEntity pet) async {
    try {
      final db = await database;

      final petMap = {
        'name': pet.name,
        'type': pet.type,
        'breed': pet.breed,
        'birth_date': pet.birthDate.toIso8601String(),
        'gender': pet.gender,
        'weight': pet.weight,
        'image_path': pet.imagePath,
        'owner_id': pet.ownerId,
        'updated_at': DateTime.now().toIso8601String(),
        'additional_info': jsonEncode(pet.additionalInfo),
      };

      final rowsAffected = await db.update(
        'pet_profiles',
        petMap,
        where: 'id = ?',
        whereArgs: [pet.id],
      );

      if (rowsAffected == 0) {
        return Result.failure('업데이트할 펫을 찾을 수 없습니다');
      }

      return Result.success('펫 프로필이 성공적으로 업데이트되었습니다', null);
    } catch (e) {
      return Result.failure('펫 프로필 업데이트에 실패했습니다: ${e.toString()}');
    }
  }

  /// Pet Profile 삭제
  Future<Result<void>> deletePetProfile(String id) async {
    try {
      final db = await database;

      final rowsAffected = await db.delete(
        'pet_profiles',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        return Result.failure('삭제할 펫을 찾을 수 없습니다');
      }

      return Result.success('펫 프로필이 성공적으로 삭제되었습니다', null);
    } catch (e) {
      return Result.failure('펫 프로필 삭제에 실패했습니다: ${e.toString()}');
    }
  }

  /// Temporary Pet Data 저장
  Future<Result<void>> saveTemporaryPetData(
    String step,
    Map<String, dynamic> data,
  ) async {
    try {
      final db = await database;

      final tempDataMap = {
        'id': 'temp_$step',
        'step': step,
        'data': jsonEncode(data),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await db.insert(
        'temporary_pet_data',
        tempDataMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success('임시 데이터가 성공적으로 저장되었습니다', null);
    } catch (e) {
      return Result.failure('임시 데이터 저장에 실패했습니다: ${e.toString()}');
    }
  }

  /// Temporary Pet Data 조회
  Future<Result<Map<String, dynamic>?>> getTemporaryPetData(String step) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'temporary_pet_data',
        where: 'step = ?',
        whereArgs: [step],
      );

      if (maps.isEmpty) {
        return Result.success('임시 데이터를 찾을 수 없습니다', null);
      }

      final data =
          jsonDecode(maps.first['data'] as String) as Map<String, dynamic>;
      return Result.success('임시 데이터를 성공적으로 조회했습니다', data);
    } catch (e) {
      return Result.failure('임시 데이터 조회에 실패했습니다: ${e.toString()}');
    }
  }

  /// 모든 Temporary Pet Data 삭제
  Future<Result<void>> clearTemporaryPetData() async {
    try {
      final db = await database;
      await db.delete('temporary_pet_data');
      return Result.success('모든 임시 데이터가 삭제되었습니다', null);
    } catch (e) {
      return Result.failure('임시 데이터 삭제에 실패했습니다: ${e.toString()}');
    }
  }

  /// Map을 PetProfileEntity로 변환
  PetProfileEntity _mapToPetProfile(Map<String, dynamic> map) {
    return PetProfileEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      breed: map['breed'] as String?,
      birthDate: DateTime.parse(map['birth_date'] as String),
      gender: map['gender'] as String,
      weight: (map['weight'] as num).toDouble(),
      imagePath: map['image_path'] as String?,
      ownerId: map['owner_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      additionalInfo: map['additional_info'] != null
          ? jsonDecode(map['additional_info'] as String) as Map<String, dynamic>
          : {},
    );
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

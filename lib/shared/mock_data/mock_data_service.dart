import 'package:flutter/material.dart';

import '../../features/ai/domain/entities/ai_message_entity.dart';
import '../../features/facility/domain/facility.dart';
import '../../features/home/domain/entities/home_dashboard_entity.dart';
import '../../features/notification/domain/entities/notification_model.dart';
import '../../features/pet_activities/domain/entities/trick_entity.dart';
import '../../features/pet_activities/domain/entities/video_bookmark_entity.dart';
import '../../features/pet_activities/domain/entities/video_progress_entity.dart';
import '../../features/pet_feeding/data/data.dart';
import '../../features/pet_feeding/domain/entities/feeding_record_entity.dart';
import '../../features/pet_health/domain/entities/vaccine_record_entity.dart';
import '../../features/pet_health/domain/entities/weight_record_entity.dart';
import '../../features/pet_registor/domain/entities/pet_profile_entity.dart';
import '../../features/walk/domain/entities/walk_record_entity.dart';

/// モックデータサービス
///
/// アプリ全体で使用されるモックデータを一元管理します。
/// 実際のAPI連携時にはこのファイルを削除または無効化してください。
abstract class MockDataService {
  /// モックデータ使用フラグ
  /// falseに設定すると実際のAPI呼び出しに切り替わります。
  static const bool isEnabled = true;

  // ==================== Pet Core ====================

  /// ペット一覧の取得
  static List<PetProfileEntity> getMockPets() {
    return [
      PetProfileEntity(
        id: '1',
        name: 'マックス',
        type: 'dog',
        breed: 'ゴールデンレトリバー',
        birthDate: DateTime(2020, 3, 15),
        imagePath: 'assets/images/dogs/shiba.png',
        ownerId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      PetProfileEntity(
        id: '2',
        name: 'ルナ',
        type: 'cat',
        breed: 'ペルシャ',
        birthDate: DateTime(2021, 7, 22),
        imagePath: 'assets/images/cats/cats.png',
        ownerId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// 特定のペットの取得
  static PetProfileEntity? getMockPetById(String id) {
    final pets = getMockPets();
    try {
      return pets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==================== Pet Activities ====================

  /// トリックモックデータ
  static List<TrickEntity> getMockTricks() {
    return [
      // Easy tricks (学習中のトリック)
      TrickEntity(
        id: '1',
        name: 'オスワリ',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/sit.png',
        difficulty: 'easy',
        progress: 80,
        date: DateTime.now().subtract(const Duration(days: 2)),
        youtubeUrl: 'https://youtube.com/watch?v=example1',
        description: '基本的なおすわりコマンドのトレーニングです。初心者に最適です。',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      TrickEntity(
        id: '2',
        name: 'お手',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/shake.png',
        difficulty: 'easy',
        progress: 60,
        isCompleted: false,
        youtubeUrl: 'https://youtu.be/example2',
        description: 'コマンドでペットにお手をさせるトレーニングです。',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      TrickEntity(
        id: '3',
        name: '伏せ',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/down.png',
        difficulty: 'medium',
        progress: 30,
        isCompleted: false,
        description: 'コマンドでペットに伏せをさせるトレーニングです。',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      // Easy tricks (まだ学習していないトリック)
      TrickEntity(
        id: '4',
        name: '待て',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/stay.png',
        difficulty: 'easy',
        description: 'ペットが解放されるまでその位置にとどまるようにトレーニングします。',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      TrickEntity(
        id: '5',
        name: 'おいで',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/come.png',
        difficulty: 'easy',
        description: '安全性と絆を深めるための基本的な呼び戻しコマンドです。',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      TrickEntity(
        id: '6',
        name: 'おかわり',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/paw.png',
        difficulty: 'easy',
        description: 'ペットが足を差し出す楽しいトリックです。',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),

      // Medium tricks
      TrickEntity(
        id: '7',
        name: 'ゴロン',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/roll.png',
        difficulty: 'medium',
        description: 'コマンドでペットに回転させるトレーニングです。',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      TrickEntity(
        id: '8',
        name: '回れ',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/spin.png',
        difficulty: 'medium',
        description: 'ペットが円を描いて回転する楽しいトリックです。',
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
      ),
      TrickEntity(
        id: '9',
        name: 'バン',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/play_dead.png',
        difficulty: 'medium',
        description: 'ペットが死んだフリをするドラマチックなトリックです。',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      TrickEntity(
        id: '10',
        name: 'ワンワン',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/speak.png',
        difficulty: 'medium',
        description: 'コマンドでペットに鳴かせるトレーニングです。',
        createdAt: DateTime.now().subtract(const Duration(days: 16)),
      ),

      // Hard tricks
      TrickEntity(
        id: '11',
        name: '特定物の持ってきて',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/fetch.png',
        difficulty: 'hard',
        description: '指定された特定の物を持ってくる上級トリックです。',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      TrickEntity(
        id: '12',
        name: 'バック',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/backwards.png',
        difficulty: 'hard',
        description: 'コマンドで後ろ向きに歩くチャレンジングなトリックです。',
        createdAt: DateTime.now().subtract(const Duration(days: 22)),
      ),
      TrickEntity(
        id: '13',
        name: 'おやつバランス',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/balance.png',
        difficulty: 'hard',
        description: '鼻の上におやつをバランスさせ、解放されるまで保つ印象的なトリックです。',
        createdAt: DateTime.now().subtract(const Duration(days: 28)),
      ),
      TrickEntity(
        id: '14',
        name: '足の間をくぐる',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/weave.png',
        difficulty: 'hard',
        description: '歩きながらペットが飼い主の足の間をくぐっていく複雑なトリックです。',
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
      TrickEntity(
        id: '15',
        name: 'フープジャンプ',
        petId: 'pet1',
        imagePath: 'assets/images/tricks/jump_hoop.png',
        difficulty: 'hard',
        description: '輪っかをジャンプでくぐるスペクタキュラーなトリックです。',
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
    ];
  }

  /// ビデオブックマークモックデータ
  static List<VideoBookmarkEntity> getMockVideoBookmarks() {
    return [
      VideoBookmarkEntity(
        id: '1',
        videoId: '1', // 첫 번째 트릭의 ID
        youtubeVideoId: 'example1',
        positionSec: 45,
        label: '基本姿勢の説明',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      VideoBookmarkEntity(
        id: '2',
        videoId: '1',
        youtubeVideoId: 'example1',
        positionSec: 120,
        label: '実践練習',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  /// ビデオ進行状況モックデータ
  static Map<String, VideoProgressEntity> getMockVideoProgress() {
    return {
      '1': VideoProgressEntity(
        videoId: '1',
        lastPositionSec: 89,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      '2': VideoProgressEntity(
        videoId: '2',
        lastPositionSec: 156,
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    };
  }

  // ==================== Pet Feeding ====================

  /// 食事スケジュールモックデータ（メモリベースで更新可能）
  static final List<Map<String, dynamic>> _feedingSchedules = [
    {
      'id': '1',
      'petId': '1',
      'petName': 'Max',
      'mealType': '朝食',
      'time': '08:00',
      'amount': '100g',
      'foodType': 'ドライフード',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': '2',
      'petId': '1',
      'petName': 'Max',
      'mealType': '昼食',
      'time': '12:00',
      'amount': '100g',
      'foodType': 'ドライフード',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': '3',
      'petId': '1',
      'petName': 'Max',
      'mealType': '夕食',
      'time': '18:00',
      'amount': '100g',
      'foodType': 'ドライフード',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
  ];

  /// 食事スケジュールモックデータの取得
  static List<Map<String, dynamic>> getMockFeedingSchedules() {
    return List.from(_feedingSchedules);
  }

  /// 食事スケジュールの更新
  static void updateFeedingSchedule(
    String mealType,
    String time,
    String amount,
  ) {
    final index = _feedingSchedules.indexWhere(
      (schedule) => schedule['mealType'] == mealType,
    );

    if (index != -1) {
      _feedingSchedules[index]['time'] = time;
      _feedingSchedules[index]['amount'] = amount;
      _feedingSchedules[index]['updatedAt'] = DateTime.now();
    }
  }

  /// 新しい給餌記録の追加
  static final List<Map<String, dynamic>> _feedingRecords = [];

  /// 給餌記録モックデータの取得（新しく追加された記録を含む）
  static List<Map<String, dynamic>> getMockFeedingRecordsWithNew() {
    return List.from(_feedingRecords);
  }

  /// 新しい給餌記録の追加
  static void addMockFeedingRecord(Map<String, dynamic> record) {
    _feedingRecords.add(record);
  }

  /// ペットのサイズと適正給餌量モックデータ
  static Map<String, Map<String, dynamic>> getMockPetSizesAndFeedingAmounts() {
    return {
      '1': {
        // petId '1'
        'name': 'マックス',
        'size': '中型', // 小型, 中型, 大型
        'recommendedAmount': 150, // g 단위 제외한 숫자만
        'imagePath': 'assets/images/dogs/shiba.png',
      },
      '2': {
        // petId '2'
        'name': 'ルナ',
        'size': '小型',
        'recommendedAmount': 80,
        'imagePath': 'assets/images/cats/cats.png',
      },
      '3': {
        // petId '3'
        'name': 'バディ',
        'size': '大型',
        'recommendedAmount': 250,
        'imagePath': 'assets/images/dogs/golden.png',
      },
    };
  }

  /// 펫 사이즈별 적정 급여량 가이드
  static Map<String, Map<String, dynamic>> getPetSizeFeedingGuide() {
    return {
      '小型': {
        'description': '小型犬・猫 (体重5kg以下)',
        'recommendedRange': '60-100g',
        'tips': '소량으로 나누어 주는 것이 좋습니다',
      },
      '中型': {
        'description': '中型犬・猫 (体重5-20kg)',
        'recommendedRange': '100-200g',
        'tips': '하루 2-3회로 나누어 주세요',
      },
      '大型': {
        'description': '大型犬 (体重20kg以上)',
        'recommendedRange': '200-400g',
        'tips': '운동량에 따라 조절이 필요합니다',
      },
    };
  }

  /// 펫 상태 옵션 목 데이터
  static List<Map<String, dynamic>> getPetStatusOptions() {
    return [
      {
        'id': 'feeding',
        'title': '식사유무',
        'icon': Icons.restaurant,
        'description': '오늘의 식사 상태를 기록합니다',
        'options': ['아침 식사 완료', '점심 식사 완료', '저녁 식사 완료', '식사 거부'],
      },
      {
        'id': 'walking',
        'title': '산책유무',
        'icon': Icons.directions_walk,
        'description': '산책 상태를 기록합니다',
        'options': ['산책 완료', '산책 거부', '짧은 산책', '긴 산책'],
      },
      {
        'id': 'health',
        'title': '오늘의 몸상태',
        'icon': Icons.favorite,
        'description': '건강 상태를 체크합니다',
        'options': ['건강함', '피곤함', '식욕부진', '활발함'],
      },
      {
        'id': 'diet',
        'title': '식사 관련 추가사항',
        'icon': Icons.monitor_weight,
        'description': '다이어트 등 특별한 식사 관리',
        'options': ['다이어트 중', '영양 보충', '알레르기 주의', '특별 식단'],
      },
      {
        'id': 'medication',
        'title': '투약일정',
        'icon': Icons.medication,
        'description': '투약 상태를 관리합니다',
        'options': ['아침 투약 완료', '점심 투약 완료', '저녁 투약 완료', '투약 거부'],
      },
    ];
  }

  /// 펫별 현재 상태 데이터 (메모리 기반으로 업데이트 가능)
  static final Map<String, Map<String, dynamic>> _petCurrentStatus = {
    '1': {
      // Max
      'selectedStatuses': ['feeding', 'walking'],
      'feedingStatus': '점심 식사 완료',
      'walkingStatus': '산책 완료',
      'lastUpdated': DateTime.now(),
    },
    '2': {
      // Luna
      'selectedStatuses': ['health', 'diet'],
      'healthStatus': '건강함',
      'dietStatus': '다이어트 중',
      'lastUpdated': DateTime.now(),
    },
    '3': {
      // Buddy
      'selectedStatuses': ['feeding', 'medication'],
      'feedingStatus': '아침 식사 완료',
      'medicationStatus': '아침 투약 완료',
      'lastUpdated': DateTime.now(),
    },
  };

  /// 펫별 현재 상태 가져오기
  static Map<String, dynamic>? getPetCurrentStatus(String petId) {
    return _petCurrentStatus[petId];
  }

  /// 펫 상태 업데이트
  static void updatePetStatus(
    String petId,
    List<String> selectedStatuses,
    Map<String, String> statusValues,
  ) {
    if (_petCurrentStatus.containsKey(petId)) {
      _petCurrentStatus[petId]!['selectedStatuses'] = selectedStatuses;
      _petCurrentStatus[petId]!.addAll(statusValues);
      _petCurrentStatus[petId]!['lastUpdated'] = DateTime.now();
    }
  }

  /// 오늘의 급여 데이터 (스케줄 화면용)
  static List<Map<String, dynamic>> getMockTodayMealsForSchedule() {
    return [
      {'mealType': '朝食', 'time': '08:00', 'status': 'completed'},
      {'mealType': '昼食', 'time': '12:00', 'status': 'pending'},
      {'mealType': '夕食', 'time': '18:00', 'status': 'pending'},
    ];
  }

  /// 급여 스케줄 데이터 (스케줄 화면용)
  static List<Map<String, dynamic>> getMockFeedingSchedulesForSchedule() {
    return [
      {'mealType': '朝食', 'time': '08:00', 'amount': '150g'},
      {'mealType': '昼食', 'time': '12:00', 'amount': '200g'},
      {'mealType': '夕食', 'time': '18:00', 'amount': '180g'},
      {'mealType': '間食', 'time': '15:00', 'amount': '50g'},
    ];
  }

  /// 급여 통계 데이터 (기록 화면용)
  static Map<String, dynamic> getMockFeedingStatisticsForRecords() {
    return {
      'totalFeedings': 28,
      'completionRate': 0.85,
      'averageAmount': 175.5,
      'totalAmount': 4914.0,
      'targetAmount': 5000.0,
    };
  }

  /// 급여 기록 데이터 (기록 화면용, 기존 데이터와 새로운 기록 포함)
  static List<Map<String, dynamic>> getMockFeedingRecordsForRecords() {
    final baseRecords = [
      {
        'id': '1',
        'petId': '1',
        'petName': 'マックス',
        'fedTime': DateTime.now().subtract(const Duration(days: 1)),
        'amount': 200.0,
        'foodType': 'ドッグフード',
        'foodBrand': 'ロイヤルカナン',
        'status': 'completed',
        'notes': 'よく食べました',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '2',
        'petId': '1',
        'petName': 'マックス',
        'fedTime': DateTime.now().subtract(const Duration(days: 2)),
        'amount': 180.0,
        'foodType': 'ドッグフード',
        'foodBrand': 'ロイヤルカナン',
        'status': 'completed',
        'notes': '普通に食べました',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '3',
        'petId': '2',
        'petName': 'Luna',
        'fedTime': DateTime.now().subtract(const Duration(days: 1)),
        'amount': 120.0,
        'foodType': 'キャットフード',
        'foodBrand': 'サイエンスダイエット',
        'status': 'completed',
        'notes': '完食',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '4',
        'petId': '3',
        'petName': 'Buddy',
        'fedTime': DateTime.now().subtract(const Duration(days: 3)),
        'amount': 250.0,
        'foodType': 'ドッグフード',
        'foodBrand': 'ヒルズ',
        'status': 'completed',
        'notes': '食欲旺盛',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];

    // 새로운 기록과 기존 기록을 합침
    return [...baseRecords, ..._feedingRecords];
  }

  /// 급여 분석 데이터
  static Map<String, dynamic> getMockFeedingAnalysisData() {
    return {
      'currentAmount': 200.0,
      'changeAmount': 15.0,
      'targetAmount': 180.0,
      'monthlyData': {
        '1月': 185.0,
        '2月': 190.0,
        '3月': 188.0,
        '4月': 195.0,
        '5月': 200.0,
        '6月': 195.0,
        '7月': 210.0,
        '8月': 205.0,
        '9月': 200.0,
        '10月': 195.0,
        '11月': 190.0,
        '12月': 200.0,
      },
      'lastYearData': {
        '1月': 170.0,
        '2月': 175.0,
        '3月': 180.0,
        '4月': 185.0,
        '5月': 190.0,
        '6月': 185.0,
        '7月': 195.0,
        '8月': 190.0,
        '9月': 185.0,
        '10月': 180.0,
        '11月': 175.0,
        '12月': 180.0,
      },
    };
  }

  /// 급수 관련 데이터
  static Map<String, dynamic> getMockWateringData() {
    return {
      'currentAmount': 500.0,
      'dailyTarget': 600.0,
      'weeklyData': [
        {'day': '月', 'amount': 550.0},
        {'day': '火', 'amount': 480.0},
        {'day': '水', 'amount': 520.0},
        {'day': '木', 'amount': 490.0},
        {'day': '金', 'amount': 530.0},
        {'day': '土', 'amount': 510.0},
        {'day': '日', 'amount': 470.0},
      ],
      'schedule': [
        {'time': '08:00', 'amount': 100.0, 'status': 'completed'},
        {'time': '12:00', 'amount': 150.0, 'status': 'completed'},
        {'time': '16:00', 'amount': 120.0, 'status': 'pending'},
        {'time': '20:00', 'amount': 80.0, 'status': 'pending'},
      ],
    };
  }

  /// 트레이닝 관련 데이터
  static Map<String, dynamic> getMockTrainingData() {
    return {
      'basicTraining': [
        {'command': '座れ', 'status': 'completed', 'progress': 100},
        {'command': '待て', 'status': 'completed', 'progress': 100},
        {'command': '来い', 'status': 'in_progress', 'progress': 75},
        {'command': '伏せ', 'status': 'not_started', 'progress': 0},
      ],
      'advancedTricks': [
        {'trick': 'お手', 'status': 'completed', 'progress': 100},
        {'trick': 'おかわり', 'status': 'in_progress', 'progress': 60},
        {'trick': '回れ', 'status': 'not_started', 'progress': 0},
        {'trick': 'ジャンプ', 'status': 'not_started', 'progress': 0},
      ],
      'schedule': [
        {'day': '月', 'duration': 30, 'focus': '基本コマンド'},
        {'day': '水', 'duration': 25, 'focus': '高度な技'},
        {'day': '金', 'duration': 35, 'focus': '復習'},
        {'day': '土', 'duration': 40, 'focus': '新しい技'},
      ],
    };
  }

  /// 건강 관리 데이터
  static Map<String, dynamic> getMockHealthData() {
    return {
      'currentWeight': 5.2,
      'targetWeight': 5.0,
      'weightChange': 0.2,
      'vaccinationSchedule': [
        {'vaccine': '狂犬病', 'date': '2024-01-15', 'status': 'completed'},
        {'vaccine': '混合ワクチン', 'date': '2024-03-20', 'status': 'completed'},
        {'vaccine': 'フィラリア予防', 'date': '2024-06-01', 'status': 'pending'},
        {'vaccine': 'ノミ・マダニ予防', 'date': '2024-07-01', 'status': 'pending'},
      ],
      'healthCheckups': [
        {'date': '2024-01-10', 'result': '健康', 'notes': '定期健診'},
        {'date': '2024-03-15', 'result': '健康', 'notes': 'ワクチン接種時'},
        {'date': '2024-06-01', 'result': '予定', 'notes': '次回健診予定'},
      ],
      'medications': [
        {'name': 'サプリメントA', 'schedule': '毎日', 'status': '継続中'},
        {'name': '薬B', 'schedule': '1日2回', 'status': '完了'},
        {'name': '薬C', 'schedule': '必要時', 'status': '保管中'},
      ],
    };
  }

  /// 오늘의 식사 상태 목 데이터
  static List<Map<String, dynamic>> getMockTodayMeals() {
    final now = DateTime.now();
    final currentHour = now.hour;

    return [
      {
        'mealType': '朝食',
        'time': '08:00',
        'status': currentHour >= 8 ? 'completed' : 'pending',
        'amount': '100g',
      },
      {
        'mealType': '昼食',
        'time': '12:00',
        'status': currentHour >= 12 ? 'completed' : 'pending',
        'amount': '100g',
      },
      {
        'mealType': '夕食',
        'time': '18:00',
        'status': currentHour >= 18 ? 'completed' : 'pending',
        'amount': '100g',
      },
    ];
  }

  /// 레시피 목 데이터
  static List<RecipeModel> getMockRecipes() {
    return [
      const RecipeModel(
        id: '1',
        name: 'Doggy Meatloaf with Vegetables',
        image: 'assets/images/recipes/meatloaf.png',
        description: 'Healthy homemade meatloaf with fresh vegetables',
        cookingTime: '45 min',
        difficulty: 'Medium',
        ingredients: [
          'Ground beef (1 lb)',
          'Carrots (2 medium)',
          'Green beans (1 cup)',
          'Eggs (2)',
          'Breadcrumbs (1/2 cup)',
          'Olive oil (2 tbsp)',
        ],
        instructions: [
          'Preheat oven to 350°F (175°C)',
          'Mix ground beef with chopped vegetables',
          'Add eggs and breadcrumbs, mix well',
          'Form into loaf shape',
          'Bake for 45 minutes',
          'Let cool before serving',
        ],
        servings: 4,
        rating: 4.5,
        isFavorite: true,
      ),
      const RecipeModel(
        id: '2',
        name: 'Peanut Butter and Banana Biscuits',
        image: 'assets/images/recipes/biscuits.png',
        description: 'Delicious treats with natural ingredients',
        cookingTime: '30 min',
        difficulty: 'Easy',
        ingredients: [
          'Whole wheat flour (2 cups)',
          'Peanut butter (1/2 cup)',
          'Banana (1 ripe)',
          'Honey (2 tbsp)',
          'Egg (1)',
          'Water (1/4 cup)',
        ],
        instructions: [
          'Preheat oven to 350°F (175°C)',
          'Mash banana in a bowl',
          'Mix with peanut butter and honey',
          'Add flour and egg, mix well',
          'Roll out dough and cut into shapes',
          'Bake for 20-25 minutes',
        ],
        servings: 12,
        rating: 4.8,
        isFavorite: false,
      ),
      const RecipeModel(
        id: '3',
        name: 'Blueberry Cream Cupcake',
        image: 'assets/images/recipes/cupcake.png',
        description: 'Special occasion treat with fresh blueberries',
        cookingTime: '60 min',
        difficulty: 'Hard',
        ingredients: [
          'All-purpose flour (2 cups)',
          'Sugar (1 cup)',
          'Butter (1/2 cup)',
          'Eggs (2)',
          'Milk (1 cup)',
          'Blueberries (1 cup)',
          'Vanilla extract (1 tsp)',
        ],
        instructions: [
          'Preheat oven to 350°F (175°C)',
          'Cream butter and sugar together',
          'Add eggs one at a time',
          'Alternate flour and milk',
          'Fold in blueberries',
          'Bake for 25-30 minutes',
        ],
        servings: 6,
        rating: 4.2,
        isFavorite: true,
      ),
      const RecipeModel(
        id: '4',
        name: 'Salmon and Sweet Potato Bowl',
        image: 'assets/images/recipes/salmon_bowl.png',
        description: 'Nutritious bowl with omega-3 rich salmon',
        cookingTime: '40 min',
        difficulty: 'Medium',
        ingredients: [
          'Salmon fillet (1 lb)',
          'Sweet potato (2 medium)',
          'Brown rice (1 cup)',
          'Broccoli (1 cup)',
          'Olive oil (2 tbsp)',
          'Lemon (1)',
        ],
        instructions: [
          'Cook brown rice according to package',
          'Roast sweet potato cubes',
          'Steam broccoli',
          'Grill salmon with lemon',
          'Assemble in bowls',
          'Serve warm',
        ],
        servings: 2,
        rating: 4.6,
        isFavorite: false,
      ),
      const RecipeModel(
        id: '5',
        name: 'Chicken and Rice Casserole',
        image: 'assets/images/recipes/casserole.png',
        description: 'Comforting casserole perfect for meal prep',
        cookingTime: '50 min',
        difficulty: 'Easy',
        ingredients: [
          'Chicken breast (2 lbs)',
          'White rice (2 cups)',
          'Chicken broth (4 cups)',
          'Mixed vegetables (2 cups)',
          'Cheese (1 cup)',
          'Herbs and spices',
        ],
        instructions: [
          'Preheat oven to 375°F (190°C)',
          'Layer rice in casserole dish',
          'Add chicken and vegetables',
          'Pour broth over top',
          'Cover and bake for 45 minutes',
          'Add cheese and bake 5 more minutes',
        ],
        servings: 6,
        rating: 4.4,
        isFavorite: true,
      ),
      const RecipeModel(
        id: '6',
        name: 'Apple and Oat Cookies',
        image: 'assets/images/recipes/cookies.png',
        description: 'Healthy cookies with fiber-rich oats',
        cookingTime: '25 min',
        difficulty: 'Easy',
        ingredients: [
          'Oats (2 cups)',
          'Apple (1 medium, grated)',
          'Honey (1/4 cup)',
          'Cinnamon (1 tsp)',
          'Egg (1)',
          'Vanilla extract (1 tsp)',
        ],
        instructions: [
          'Preheat oven to 350°F (175°C)',
          'Mix oats with grated apple',
          'Add honey and spices',
          'Form into cookies',
          'Bake for 15-20 minutes',
          'Cool completely',
        ],
        servings: 8,
        rating: 4.7,
        isFavorite: false,
      ),
    ];
  }

  /// 난이도별 레시피 필터링
  static List<RecipeModel> getRecipesByDifficulty(String difficulty) {
    return getMockRecipes()
        .where(
          (recipe) =>
              recipe.difficulty.toLowerCase() == difficulty.toLowerCase(),
        )
        .toList();
  }

  /// 즐겨찾기 레시피만 가져오기
  static List<RecipeModel> getFavoriteRecipes() {
    return getMockRecipes().where((recipe) => recipe.isFavorite).toList();
  }

  /// 검색어로 레시피 필터링
  static List<RecipeModel> searchRecipes(String query) {
    if (query.isEmpty) return getMockRecipes();

    return getMockRecipes().where((recipe) {
      return recipe.name.toLowerCase().contains(query.toLowerCase()) ||
          recipe.description.toLowerCase().contains(query.toLowerCase()) ||
          recipe.ingredients.any(
            (ingredient) =>
                ingredient.toLowerCase().contains(query.toLowerCase()),
          );
    }).toList();
  }

  /// ID로 레시피 가져오기
  static RecipeModel? getRecipeById(String id) {
    try {
      return getMockRecipes().firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 최고 평점 레시피 가져오기
  static List<RecipeModel> getTopRatedRecipes({int limit = 5}) {
    final recipes = getMockRecipes();
    recipes.sort((a, b) => b.rating.compareTo(a.rating));
    return recipes.take(limit).toList();
  }

  /// 빠른 조리 레시피 가져오기 (30분 이하)
  static List<RecipeModel> getQuickRecipes() {
    return getMockRecipes().where((recipe) {
      final time = int.tryParse(recipe.cookingTime.split(' ').first) ?? 0;
      return time <= 30;
    }).toList();
  }

  /// 급여 기록 목 데이터
  static List<FeedingRecordEntity> getMockFeedingRecords() {
    return [
      FeedingRecordEntity(
        id: '1',
        petId: 'pet1',
        petName: '멍멍이',
        fedTime: DateTime.now().subtract(const Duration(hours: 2)),
        amount: 120.0,
        foodType: '건식사료',
        foodBrand: '로얄캐닌',
        status: FeedingStatus.completed,
        notes: '잘 먹었음',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      FeedingRecordEntity(
        id: '2',
        petId: 'pet1',
        petName: '멍멍이',
        fedTime: DateTime.now().subtract(const Duration(hours: 8)),
        amount: 110.0,
        foodType: '건식사료',
        foodBrand: '로얄캐닌',
        status: FeedingStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }

  /// 급여 통계 목 데이터
  static FeedingStatistics getMockFeedingStatistics() {
    return const FeedingStatistics(
      totalFeedings: 2,
      completedFeedings: 2,
      skippedFeedings: 0,
      totalAmount: 230.0,
      averageAmount: 115.0,
      completionRate: 1.0,
      feedingsByHour: {'08': 1, '10': 1},
    );
  }

  // ==================== Pet Health ====================

  /// 백신 기록 목 데이터
  static List<VaccineRecordEntity> getMockVaccineRecords() {
    return [
      VaccineRecordEntity(
        id: '1',
        name: '종합백신 (DHPPL)',
        date: DateTime.now().subtract(const Duration(days: 30)),
        doctor: '김수의사',
        lot: 'VAC123456',
        validUntil: DateTime.now().add(const Duration(days: 335)),
        notes: '정상 접종 완료',
      ),
      VaccineRecordEntity(
        id: '2',
        name: '광견병 백신',
        date: DateTime.now().subtract(const Duration(days: 60)),
        doctor: '이수의사',
        lot: 'RAB789012',
        validUntil: DateTime.now().add(const Duration(days: 305)),
        notes: '부작용 없음',
      ),
    ];
  }

  /// 체중 기록 목 데이터
  static List<WeightRecordEntity> getMockWeightRecords() {
    return [
      WeightRecordEntity(
        id: '1',
        petId: 'pet1',
        petName: '멍멍이',
        weight: 5.2,
        recordedDate: DateTime.now(),
        notes: '정상 체중',
        createdAt: DateTime.now(),
      ),
      WeightRecordEntity(
        id: '2',
        petId: 'pet1',
        petName: '멍멍이',
        weight: 5.0,
        recordedDate: DateTime.now().subtract(const Duration(days: 30)),
        notes: '약간 증가',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      WeightRecordEntity(
        id: '3',
        petId: 'pet1',
        petName: '멍멍이',
        weight: 4.8,
        recordedDate: DateTime.now().subtract(const Duration(days: 60)),
        notes: '정상 범위',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
  }

  // ==================== Pet Profile ====================

  /// 펫 프로필 목 데이터
  static List<PetProfileEntity> getMockPetProfiles() {
    return [
      PetProfileEntity(
        id: 'pet1',
        name: '멍멍이',
        type: 'dog',
        breed: '골든 리트리버',
        birthDate: DateTime(2021, 3, 15),
        imagePath: 'assets/images/pets/golden_retriever.jpg',
        ownerId: 'owner1',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
        additionalInfo: {
          'weight': 25.5,
          'gender': 'male',
          'isNeutered': true,
          'microchipId': 'CHIP123456789',
        },
      ),
      PetProfileEntity(
        id: 'pet2',
        name: '야옹이',
        type: 'cat',
        breed: '러시안 블루',
        birthDate: DateTime(2022, 7, 10),
        imagePath: 'assets/images/pets/russian_blue.jpg',
        ownerId: 'owner1',
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now(),
        additionalInfo: {
          'weight': 4.2,
          'gender': 'female',
          'isNeutered': true,
          'microchipId': 'CHIP987654321',
        },
      ),
    ];
  }

  // ==================== Home Dashboard ====================

  /// 날씨 정보 목 데이터
  static WeatherInfo getMockWeatherInfo() {
    return const WeatherInfo(
      temperature: 23.0,
      condition: '맑음',
      iconCode: 'sunny',
      location: '서울특별시',
    );
  }

  /// 예약 정보 목 데이터
  static List<AppointmentSummary> getMockAppointments() {
    return [
      AppointmentSummary(
        id: '1',
        title: 'Max 건강검진',
        scheduledTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
        type: '건강검진',
        petName: 'Max',
      ),
      AppointmentSummary(
        id: '2',
        title: 'Luna 미용',
        scheduledTime: DateTime.now().add(const Duration(days: 3, hours: 14)),
        type: '미용',
        petName: 'Luna',
      ),
    ];
  }

  /// 건강 요약 목 데이터
  static HealthSummary getMockHealthSummary() {
    return const HealthSummary(
      totalPets: 2,
      healthyPets: 2,
      petsNeedingAttention: 0,
      alerts: [],
    );
  }

  /// 산책 요약 목 데이터
  static WalkSummary getMockWalkSummary() {
    return const WalkSummary(
      todayWalks: 2,
      todayDistance: 2.5,
      todayDuration: Duration(minutes: 45),
      weeklyGoal: 15,
      weeklyProgress: 8,
    );
  }

  // ==================== Facility ====================

  /// 시설 목 데이터
  static List<Facility> getMockFacilities() {
    return [
      // 트리밍 샵 데이터
      Facility(
        id: '1',
        name: 'Pet Beauty Salon',
        description: '전문적인 펫 트리밍 서비스',
        address: '서울시 강남구 역삼동 123-45',
        phone: '02-1234-5678',
        email: 'info@petsalon.com',
        type: FacilityType.grooming,
        rating: 4.8,
        reviewCount: 156,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: true,
        hasHistory: true,
        lastVisit: DateTime(2024, 1, 15),
      ),
      Facility(
        id: '2',
        name: 'Happy Grooming',
        description: '친근하고 편안한 트리밍 환경',
        address: '서울시 서초구 서초동 456-78',
        phone: '02-2345-6789',
        email: 'contact@happygrooming.com',
        type: FacilityType.grooming,
        rating: 4.5,
        reviewCount: 89,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: false,
        hasHistory: true,
        lastVisit: DateTime(2024, 2, 20),
      ),
      const Facility(
        id: '3',
        name: 'Premium Pet Care',
        description: '프리미엄 펫 케어 서비스',
        address: '서울시 마포구 합정동 789-12',
        phone: '02-3456-7890',
        email: 'service@premiumpet.com',
        type: FacilityType.grooming,
        rating: 4.9,
        reviewCount: 234,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: true,
        hasHistory: false,
      ),
      const Facility(
        id: '7',
        name: 'ペットサロン花子',
        description: '丁寧なトリミングサービス',
        address: '서울시 용산구 한남동 123-45',
        phone: '02-7890-1234',
        email: 'hanako@petsalon.jp',
        type: FacilityType.grooming,
        rating: 4.2,
        reviewCount: 67,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: true,
        hasHistory: false,
      ),
      // 병원 데이터
      Facility(
        id: '4',
        name: 'Animal Medical Center',
        description: '24시간 응급 진료 가능한 동물병원',
        address: '서울시 송파구 문정동 321-54',
        phone: '02-4567-8901',
        email: 'emergency@animalmed.com',
        type: FacilityType.hospital,
        rating: 4.7,
        reviewCount: 312,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: true,
        hasHistory: true,
        lastVisit: DateTime(2024, 3, 10),
      ),
      Facility(
        id: '5',
        name: 'Pet Care Hospital',
        description: '전문 수의사가 진료하는 동물병원',
        address: '서울시 영등포구 여의도동 654-87',
        phone: '02-5678-9012',
        email: 'info@petcarehospital.com',
        type: FacilityType.hospital,
        rating: 4.6,
        reviewCount: 178,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: false,
        hasHistory: true,
        lastVisit: DateTime(2024, 1, 25),
      ),
      const Facility(
        id: '6',
        name: 'あいうえお動物病院',
        description: '小型動物専門診療',
        address: '서울시 강서구 화곡동 987-21',
        phone: '02-6789-0123',
        email: 'clinic@vetclinic.com',
        type: FacilityType.hospital,
        rating: 4.4,
        reviewCount: 95,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: false,
        hasHistory: false,
      ),
      Facility(
        id: '8',
        name: 'ZOO Animal Hospital',
        description: 'English speaking veterinarians',
        address: '서울시 종로구 인사동 456-78',
        phone: '02-8901-2345',
        email: 'info@zoovet.com',
        type: FacilityType.hospital,
        rating: 4.1,
        reviewCount: 203,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: false,
        hasHistory: true,
        lastVisit: DateTime(2024, 2, 5),
      ),
    ];
  }

  // ==================== Walk ====================

  /// 산책 기록 목 데이터
  static List<WalkRecordEntity> getMockWalkRecords() {
    return [
      WalkRecordEntity(
        id: '1',
        title: '아침 산책',
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        duration: const Duration(minutes: 30),
        distance: 1.2,
        route: [],
        petId: '1',
        petName: 'Max',
        petImage: 'assets/images/dogs/shiba.png',
        ownerId: 'user1',
        ownerName: 'Sarah',
        ownerAvatar: 'assets/images/placeholder.png',
        status: WalkStatus.completed,
        notes: '날씨가 좋아서 즐거운 산책이었다',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 30),
        ),
      ),
      WalkRecordEntity(
        id: '2',
        title: '저녁 산책',
        startTime: DateTime.now().subtract(const Duration(hours: 6)),
        endTime: DateTime.now().subtract(const Duration(hours: 5, minutes: 15)),
        duration: const Duration(minutes: 45),
        distance: 2.1,
        route: [],
        petId: '1',
        petName: 'Max',
        petImage: 'assets/images/dogs/shiba.png',
        ownerId: 'user1',
        ownerName: 'Sarah',
        ownerAvatar: 'assets/images/placeholder.png',
        status: WalkStatus.completed,
        notes: '공원에서 다른 강아지들과 놀았다',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(
          const Duration(hours: 5, minutes: 15),
        ),
      ),
    ];
  }

  // ==================== Notification ====================

  /// 알림 목 데이터
  static List<NotificationModel> getMockNotifications() {
    return [
      NotificationModel(
        id: '1',
        title: 'Max 산책 시간',
        body: 'Max의 산책 시간입니다. 30분 후에 산책을 시작하세요.',
        type: NotificationType.walk,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        data: {
          'petId': '1',
          'petName': 'マックス',
          'actionUrl': '/walk',
          'metadata': {
            'recommendedDuration': 30,
            'weather': '맑음',
            'temperature': 22,
          },
        },
      ),
      NotificationModel(
        id: '2',
        title: 'Luna 식사 시간',
        body: 'Luna의 저녁 식사 시간입니다.',
        type: NotificationType.feeding,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: NotificationStatus.read,
        data: {
          'petId': '2',
          'petName': 'Luna',
          'actionUrl': '/feeding-schedule/2',
          'metadata': {
            'amount': 100,
            'scheduledTime': '18:00',
            'mealTime': 'dinner',
          },
        },
      ),
      NotificationModel(
        id: '3',
        title: 'Max 건강검진 예약',
        body: 'Max의 건강검진 예약이 내일 오후 2시에 있습니다.',
        type: NotificationType.health,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        data: {
          'petId': '1',
          'petName': 'マックス',
          'actionUrl': '/vaccines',
          'metadata': {
            'vaccineType': '종합백신',
            'appointmentDate': '2024-01-15',
            'appointmentTime': '14:00',
            'hospitalName': '펫케어 동물병원',
          },
        },
      ),
      NotificationModel(
        id: '4',
        title: 'Luna 미용 예약',
        body: 'Luna의 미용 예약이 3일 후 오전 10시에 있습니다.',
        type: NotificationType.reservation,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        data: {
          'petId': '2',
          'petName': 'Luna',
          'actionUrl': '/reservation',
          'metadata': {
            'facilityName': '멍멍이 미용실',
            'services': ['미용', '목욕', '네일케어'],
            'price': 50000,
          },
        },
      ),
      NotificationModel(
        id: '5',
        title: '급여 분석 결과',
        body: 'Max의 급여 패턴 분석 결과가 준비되었습니다.',
        type: NotificationType.system,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        data: {
          'petId': '1',
          'petName': 'マックス',
          'actionUrl': '/feeding-analysis/1',
          'metadata': {'averageIntake': 85, 'daysObserved': 7},
        },
      ),
    ];
  }

  /// 알림 설정 목 데이터
  static NotificationSettings getMockNotificationSettings() {
    return const NotificationSettings(
      enabled: true,
      typeSettings: {
        NotificationType.feeding: true,
        NotificationType.walk: true,
        NotificationType.health: true,
        NotificationType.medication: true,
        NotificationType.system: true,
        NotificationType.general: true,
        NotificationType.reservation: true,
      },
      soundEnabled: true,
      vibrationEnabled: true,
      badgeEnabled: true,
    );
  }

  // ==================== AI ====================

  /// AI 채팅 기록 목 데이터
  static List<AiMessageEntity> getMockAiChatHistory() {
    return [
      AiMessageEntity(
        id: '1',
        content: '안녕하세요! AI 펫 어시스턴트입니다. 무엇을 도와드릴까요?',
        type: MessageType.assistant,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      AiMessageEntity(
        id: '2',
        content: 'Max가 식사를 거부하고 있어요. 어떻게 해야 할까요?',
        type: MessageType.user,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      AiMessageEntity(
        id: '3',
        content:
            'Max의 식사 거부는 여러 원인이 있을 수 있습니다. 먼저 건강 상태를 확인해보시고, 사료를 바꿔보거나 소량으로 나누어 주는 것을 시도해보세요.',
        type: MessageType.assistant,
        timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
      ),
    ];
  }

  /// AI 채팅 세션 목 데이터
  static List<AiChatSessionEntity> getMockAiChatSessions() {
    return [
      AiChatSessionEntity(
        id: '1',
        title: 'Max 식사 문제 상담',
        messages: getMockAiChatHistory(),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 7)),
        petId: '1',
      ),
    ];
  }

  /// AI 추천 질문 목 데이터 (간단한 형태)
  static List<Map<String, dynamic>> getMockAiSuggestedQuestions() {
    return [
      {
        'id': '1',
        'question': '반려동물이 식사를 거부할 때는 어떻게 해야 하나요?',
        'category': 'health',
      },
      {
        'id': '2',
        'question': '산책 중 반려동물이 다른 강아지를 무서워해요',
        'category': 'behavior',
      },
      {'id': '3', 'question': '고양이의 적정 사료량은 얼마인가요?', 'category': 'feeding'},
    ];
  }

  // ==================== Notification Stats ====================

  /// 알림 통계 목업 데이터 생성
  static List<Map<String, dynamic>> getMockNotificationStats({
    int days = 30,
    int notificationsPerDay = 5,
  }) {
    final stats = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int day = 0; day < days; day++) {
      final date = now.subtract(Duration(days: day));

      for (int i = 0; i < notificationsPerDay; i++) {
        final sentCount = 50 + (i * 10);
        final openedCount = (sentCount * (0.6 + (i * 0.05))).round();
        final clickedCount = (openedCount * (0.3 + (i * 0.02))).round();

        stats.add({
          'id': 'stat_${date.millisecondsSinceEpoch}_$i',
          'title': '알림 #${i + 1}',
          'date': date.toIso8601String(),
          'sentCount': sentCount,
          'openedCount': openedCount,
          'clickedCount': clickedCount,
          'openRate': openedCount / sentCount,
          'clickRate': clickedCount / sentCount,
        });
      }
    }

    return stats;
  }

  /// 사용자 참여도 목업 데이터 생성
  static List<Map<String, dynamic>> getMockUserEngagement({
    int days = 30,
    int users = 5,
  }) {
    final engagements = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int userIndex = 0; userIndex < users; userIndex++) {
      for (int day = 0; day < days; day++) {
        final date = now.subtract(Duration(days: day));
        final totalNotifications = 10 + (day % 5);
        final openedNotifications =
            (totalNotifications * (0.5 + (userIndex * 0.1))).round();

        engagements.add({
          'userId': 'user_$userIndex',
          'date': date.toIso8601String(),
          'totalNotifications': totalNotifications,
          'openedNotifications': openedNotifications,
          'engagementRate': openedNotifications / totalNotifications,
        });
      }
    }

    return engagements;
  }

  // ==================== Link Registration ====================

  /// 링크 등록 목업 데이터
  static Map<String, dynamic> getMockLinkRegistrationResult(String link) {
    // 링크에서 펫 ID 추출
    final petId = _extractPetIdFromLink(link);

    return {
      'success': true,
      'petId': petId,
      'message': 'ペットプロフィールが正常に追加されました',
      'petData': _getMockPetDataByLink(petId),
    };
  }

  /// 링크에서 펫 ID 추출
  static String _extractPetIdFromLink(String link) {
    try {
      final uri = Uri.parse(link);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length >= 2 && pathSegments[0] == 'share') {
        return pathSegments[1];
      }
    } catch (e) {
      // 파싱 실패 시 기본값 반환
    }

    return 'unknown-pet-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 링크별 펫 데이터 반환
  static Map<String, dynamic> _getMockPetDataByLink(String petId) {
    // 펫 ID에 따른 다른 데이터 반환
    switch (petId) {
      case 'maxi-123':
        return {
          'id': petId,
          'name': 'Maxi',
          'type': 'dog',
          'breed': 'Shiba Inu',
          'age': 2,
          'weight': 5.2,
          'imageUrl': 'assets/images/dogs/shiba.png',
          'ownerName': '田中太郎',
          'createdAt': DateTime.now().subtract(const Duration(days: 30)),
        };
      case 'luna-456':
        return {
          'id': petId,
          'name': 'ルナ',
          'type': 'cat',
          'breed': 'Persian',
          'age': 1,
          'weight': 3.8,
          'imageUrl': 'assets/images/cats/cats.png',
          'ownerName': '佐藤花子',
          'createdAt': DateTime.now().subtract(const Duration(days: 15)),
        };
      case 'buddy-789':
        return {
          'id': petId,
          'name': 'バディ',
          'type': 'dog',
          'breed': 'Golden Retriever',
          'age': 3,
          'weight': 25.5,
          'imageUrl': 'assets/images/dogs/golden.png',
          'ownerName': '山田次郎',
          'createdAt': DateTime.now().subtract(const Duration(days: 7)),
        };
      default:
        return {
          'id': petId,
          'name': 'Unknown Pet',
          'type': 'unknown',
          'breed': 'Unknown',
          'age': 0,
          'weight': 0.0,
          'imageUrl': 'assets/images/dogs/shiba.png',
          'ownerName': 'Unknown Owner',
          'createdAt': DateTime.now(),
        };
    }
  }

  /// 링크 유효성 검증
  static bool isValidLink(String link) {
    try {
      final uri = Uri.parse(link);
      return uri.host.contains('aipet.app') &&
          uri.pathSegments.contains('share') &&
          uri.pathSegments.length >= 2;
    } catch (e) {
      return false;
    }
  }

  /// 예시 링크 목록
  static List<String> getMockExampleLinks() {
    return [
      'https://aipet.app/share/maxi-123',
      'https://aipet.app/share/luna-456',
      'https://aipet.app/share/buddy-789',
    ];
  }

  // ==================== Facility Screens ====================

  /// 병원 예약 화면용 시설 목업 데이터
  static List<Facility> getMockHospitalFacilities() {
    return [
      Facility(
        id: '1',
        name: 'Animal Medical Center',
        description: '24시간 緊急 診療可能な動物病院',
        address: '東京都千代田区永田町1-7-1',
        phone: '03-3262-1212',
        email: 'emergency@animalmed.com',
        type: FacilityType.hospital,
        rating: 4.7,
        reviewCount: 312,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: true,
        hasHistory: true,
        lastVisit: DateTime(2024, 3, 10),
      ),
      Facility(
        id: '2',
        name: 'Pet Care Hospital',
        description: '전문 수의사가 진료하는 동물병원',
        address: '서울시 영등포구 여의도동 654-87',
        phone: '02-5678-9012',
        email: 'info@petcarehospital.com',
        type: FacilityType.hospital,
        rating: 4.6,
        reviewCount: 178,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: false,
        hasHistory: true,
        lastVisit: DateTime(2024, 1, 25),
      ),
      const Facility(
        id: '3',
        name: 'Veterinary Clinic',
        description: '소형동물 전문 진료',
        address: '서울시 강서구 화곡동 987-21',
        phone: '02-6789-0123',
        email: 'clinic@vetclinic.com',
        type: FacilityType.hospital,
        rating: 4.4,
        reviewCount: 95,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: false,
        hasHistory: false,
      ),
    ];
  }

  /// 미용 예약 화면용 시설 목업 데이터
  static List<Facility> getMockGroomingFacilities() {
    return [
      Facility(
        id: '1',
        name: 'Pet Beauty Salon',
        description: 'ペットのカット、バス、爪切りなどのサービスを提供しています。',
        address: '東京都千代田区永田町1-7-1',
        phone: '03-3262-1212',
        email: 'info@petsalon.com',
        type: FacilityType.grooming,
        rating: 4.8,
        reviewCount: 156,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: true,
        hasHistory: true,
        lastVisit: DateTime(2024, 1, 15),
      ),
      Facility(
        id: '2',
        name: 'Happy Grooming',
        description: 'ペットのカット、バス、爪切りなどのサービスを提供しています。',
        address: '東京都千代田区永田町1-7-1',
        phone: '03-3262-1212',
        email: 'contact@happygrooming.com',
        type: FacilityType.grooming,
        rating: 4.5,
        reviewCount: 89,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: false,
        hasHistory: true,
        lastVisit: DateTime(2024, 2, 20),
      ),
      const Facility(
        id: '3',
        name: 'Premium Pet Care',
        description: 'ペットのカット、バス、爪切りなどのサービスを提供しています。',
        address: '東京都千代田区永田町1-7-1',
        phone: '03-3262-1212',
        email: 'service@premiumpet.com',
        type: FacilityType.grooming,
        rating: 4.9,
        reviewCount: 234,
        imagePath: 'assets/images/placeholder.png',
        isFavorite: true,
        hasHistory: false,
      ),
    ];
  }

  /// 예약 화면용 시설 목업 데이터
  static Facility getMockFacilityById(String facilityId) {
    return Facility(
      id: facilityId,
      name: 'Shinny Fur Saloon',
      description: 'ペットのカット、バス、爪切りなどのサービスを提供しています。',
      address: '東京都千代田区永田町1-7-1',
      phone: '03-3262-1212',
      email: 'contact@shinnyfur.com',
      type: FacilityType.grooming,
      rating: 4.6,
      reviewCount: 230,
      imagePath: 'assets/images/placeholder.png',
      isFavorite: false,
      hasHistory: false,
    );
  }

  /// 시설 상세 화면용 시설 목업 데이터
  static Facility getMockFacilityDetailById(String facilityId) {
    return Facility(
      id: facilityId,
      name: 'Shinny Fur Saloon',
      description: 'ペットのカット、バス、爪切りなどのサービスを提供しています。',
      address: '東京都千代田区永田町1-7-1',
      phone: '03-3262-1212',
      email: 'contact@shinnyfur.com',
      type: FacilityType.grooming,
      rating: 4.6,
      reviewCount: 230,
      imagePath: 'assets/images/placeholder.png',
      isFavorite: false,
      hasHistory: false,
    );
  }

  // ==================== Pet Registration ====================

  /// 강아지 품종 목 데이터
  static List<Map<String, dynamic>> getMockDogBreeds() {
    return [
      {
        'breed': 'poodle',
        'name': 'プードル',
        'image': 'assets/images/breeds/poodle.png',
      },
      {
        'breed': 'golden_retriever',
        'name': 'ゴールデンレトリーバー',
        'image': 'assets/images/breeds/golden_retriever.png',
      },
      {
        'breed': 'labrador',
        'name': 'ラブラドール',
        'image': 'assets/images/breeds/labrador.png',
      },
      {
        'breed': 'shiba_inu',
        'name': '柴犬',
        'image': 'assets/images/breeds/shiba_inu.png',
      },
      {
        'breed': 'bulldog',
        'name': 'ブルドッグ',
        'image': 'assets/images/breeds/bulldog.png',
      },
      {
        'breed': 'chihuahua',
        'name': 'チワワ',
        'image': 'assets/images/breeds/chihuahua.png',
      },
      {
        'breed': 'beagle',
        'name': 'ビーグル',
        'image': 'assets/images/breeds/beagle.png',
      },
      {
        'breed': 'german_shepherd',
        'name': 'ジャーマンシェパード',
        'image': 'assets/images/breeds/german_shepherd.png',
      },
      {
        'breed': 'yorkshire_terrier',
        'name': 'ヨークシャーテリア',
        'image': 'assets/images/breeds/yorkshire_terrier.png',
      },
      {
        'breed': 'dachshund',
        'name': 'ダックスフンド',
        'image': 'assets/images/breeds/dachshund.png',
      },
    ];
  }

  /// 고양이 품종 목 데이터
  static List<Map<String, dynamic>> getMockCatBreeds() {
    return [
      {
        'breed': 'persian',
        'name': 'ペルシャ',
        'image': 'assets/images/breeds/persian.png',
      },
      {
        'breed': 'maine_coon',
        'name': 'メインクーン',
        'image': 'assets/images/breeds/maine_coon.png',
      },
      {
        'breed': 'siamese',
        'name': 'シャム',
        'image': 'assets/images/breeds/siamese.png',
      },
      {
        'breed': 'ragdoll',
        'name': 'ラグドール',
        'image': 'assets/images/breeds/ragdoll.png',
      },
      {
        'breed': 'british_shorthair',
        'name': 'ブリティッシュショートヘア',
        'image': 'assets/images/breeds/british_shorthair.png',
      },
      {
        'breed': 'scottish_fold',
        'name': 'スコティッシュフォールド',
        'image': 'assets/images/breeds/scottish_fold.png',
      },
    ];
  }

  /// 펫 타입 선택 목 데이터
  static List<Map<String, dynamic>> getMockPetTypes() {
    return [
      {
        'type': 'dog',
        'name': 'いぬ',
        'icon': Icons.pets,
        'description': '充実스럽고 활발한 반려견',
        'color': const Color(0xFF8B5A2B), // AppColors.pointBrown equivalent
        'image': 'assets/images/pets/dog.png',
      },
      {
        'type': 'cat',
        'name': 'ねこ',
        'icon': Icons.pets,
        'description': '우아하고 독립적인 반려묘',
        'color': const Color(0xFF6B4423), // Darker brown for cats
        'image': 'assets/images/pets/cat.png',
      },
      {
        'type': 'rabbit',
        'name': 'うさぎ',
        'icon': Icons.cruelty_free,
        'description': '귀엽고 온순한 반려토끼',
        'color': const Color(0xFFF2A65A), // Orange-ish color
        'image': 'assets/images/pets/rabbit.png',
      },
      {
        'type': 'hamster',
        'name': 'ハムスター',
        'icon': Icons.circle,
        'description': '작고 사랑스러운 반려햄스터',
        'color': const Color(0xFFD4A574), // Light brown
        'image': 'assets/images/pets/hamster.png',
      },
    ];
  }

  /// 펫 성별 판단 (이름 기반)
  static String getPetGenderByName(String petName) {
    final maleNames = [
      'max',
      'buddy',
      'charlie',
      'rocky',
      'jack',
      'oscar',
      'leo',
      'milo',
    ];
    final femaleNames = [
      'luna',
      'bella',
      'molly',
      'lucy',
      'sophie',
      'chloe',
      'zoe',
      'ruby',
    ];

    final lowerName = petName.toLowerCase();

    if (maleNames.any((name) => lowerName.contains(name))) {
      return 'male';
    } else if (femaleNames.any((name) => lowerName.contains(name))) {
      return 'female';
    }

    return 'unknown';
  }

  // ==================== UI Constants ====================

  /// 월 이름 목 데이터 (차트용)
  static List<String> getMockMonthNames() {
    return [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月',
    ];
  }

  /// 요일 이름 목 데이터 (스케줄용)
  static List<String> getMockDayNames() {
    return ['월', '화', '수', '목', '금', '토', '일'];
  }

  /// 요일 이름 목 데이터 (일본어)
  static List<String> getMockDayNamesJapanese() {
    return ['月', '火', '水', '木', '金', '土', '日'];
  }

  // ==================== YouTube Mock Data ====================

  /// YouTube 비디오 목 정보
  static Map<String, dynamic> getMockYouTubeVideoInfo(String videoId) {
    return {
      'title': 'Dog Training Video - $videoId',
      'description':
          'Learn how to train your dog with this comprehensive guide.',
      'duration': 300, // 5분
      'thumbnailUrl': 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
      'uploadDate': DateTime.now().subtract(const Duration(days: 7)),
      'viewCount': 15420,
      'likeCount': 892,
      'channelName': 'Pet Training Pro',
    };
  }

  /// 기본 비디오 제목 템플릿
  static String getDefaultVideoTitle(String videoId) {
    return 'Dog Training Video - $videoId';
  }

  // ==================== Router Constants ====================

  /// 라우터 기본 쿼리 파라미터
  static Map<String, String> getDefaultFeedingScheduleParams() {
    return {'mealType': '朝食', 'time': '08:00', 'amount': '100g', 'petId': '1'};
  }
}

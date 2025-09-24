import 'package:aipet_frontend/shared/testing/mock_data/core/base_mock_service.dart';

/// Pet Feeding Feature 전용 Mock 데이터 서비스
class PetFeedingMockService extends BaseMockService {
  // ==================== 레시피 데이터 ====================

  /// Mock 레시피 목록
  static List<Map<String, dynamic>> getMockRecipes() {
    return [
      {
        'id': 'recipe_1',
        'name': '수제 치킨 딜라이트',
        'description': '신선한 치킨과 야채로 만든 건강한 펫 간식',
        'image': 'assets/images/recipes/chicken_delight.png',
        'cookingTime': '45분',
        'difficulty': '쉬움',
        'servings': 4,
        'rating': 4.8,
        'isFavorite': true,
        'ingredients': [
          '닭가슴살 200g',
          '고구마 100g',
          '당근 50g',
          '브로콜리 50g',
          '현미 100g',
        ],
        'instructions': [
          '닭가슴살을 잘게 썰어 삶아주세요',
          '고구마와 당근을 깍둑썰기 해주세요',
          '브로콜리를 적당한 크기로 나누어 주세요',
          '현미를 따로 삶아 준비해주세요',
          '모든 재료를 섞어 익혀서 완성합니다',
        ],
        'nutritionInfo': {
          'calories': 120,
          'protein': 15.2,
          'fat': 3.8,
          'carbs': 8.5,
        },
        'tags': ['저지방', '고단백', '수제'],
        'category': 'main_meal',
        'createdAt': DateTime.now().subtract(const Duration(days: 10)),
        'updatedAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': 'recipe_2',
        'name': '연어 야채볼',
        'description': '오메가3가 풍부한 연어와 신선한 야채의 조합',
        'image': 'assets/images/recipes/salmon_veggie_ball.png',
        'cookingTime': '30분',
        'difficulty': '중간',
        'servings': 6,
        'rating': 4.5,
        'isFavorite': false,
        'ingredients': ['연어살 150g', '감자 100g', '시금치 30g', '계란 1개', '귀리 50g'],
        'instructions': [
          '연어살을 잘게 다져주세요',
          '감자를 삶아서 으깨주세요',
          '시금치를 데쳐서 잘게 썰어주세요',
          '모든 재료를 섞어 볼 모양으로 만들어주세요',
          '오븐에서 20분간 구워주세요',
        ],
        'nutritionInfo': {
          'calories': 95,
          'protein': 12.8,
          'fat': 2.3,
          'carbs': 6.2,
        },
        'tags': ['오메가3', '항산화', '면역력'],
        'category': 'treat',
        'createdAt': DateTime.now().subtract(const Duration(days: 15)),
        'updatedAt': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': 'recipe_3',
        'name': '바나나 오트 쿠키',
        'description': '달콤한 바나나와 귀리로 만든 건강한 간식',
        'image': 'assets/images/recipes/banana_oat_cookie.png',
        'cookingTime': '25분',
        'difficulty': '쉬움',
        'servings': 8,
        'rating': 4.3,
        'isFavorite': true,
        'ingredients': ['바나나 2개', '귀리 100g', '코코넛오일 1스푼', '계피 약간'],
        'instructions': [
          '바나나를 으깨주세요',
          '귀리와 섞어주세요',
          '코코넛오일과 계피를 넣고 반죽해주세요',
          '쿠키 모양으로 만들어주세요',
          '180도 오븐에서 15분간 구워주세요',
        ],
        'nutritionInfo': {
          'calories': 85,
          'protein': 2.1,
          'fat': 3.2,
          'carbs': 14.8,
        },
        'tags': ['무설탕', '천연감미', '소화촉진'],
        'category': 'snack',
        'createdAt': DateTime.now().subtract(const Duration(days: 20)),
        'updatedAt': DateTime.now().subtract(const Duration(days: 8)),
      },
    ];
  }

  /// 카테고리별 레시피 조회
  static List<Map<String, dynamic>> getMockRecipesByCategory(String category) {
    return getMockRecipes()
        .where((recipe) => recipe['category'] == category)
        .toList();
  }

  /// 인기 레시피 조회
  static List<Map<String, dynamic>> getMockTopRatedRecipes({int limit = 5}) {
    final recipes = List<Map<String, dynamic>>.from(getMockRecipes());
    recipes.sort(
      (a, b) => (b['rating'] as double).compareTo(a['rating'] as double),
    );
    return recipes.take(limit).toList();
  }

  /// 즐겨찾기 레시피 조회
  static List<Map<String, dynamic>> getMockFavoriteRecipes() {
    return getMockRecipes()
        .where((recipe) => recipe['isFavorite'] == true)
        .toList();
  }

  /// 빠른 요리 레시피 (30분 이하)
  static List<Map<String, dynamic>> getMockQuickRecipes() {
    return getMockRecipes().where((recipe) {
      final cookingTime = recipe['cookingTime'] as String;
      final minutes = int.tryParse(cookingTime.split('분').first) ?? 0;
      return minutes <= 30;
    }).toList();
  }

  /// 난이도별 레시피 조회
  static List<Map<String, dynamic>> getMockRecipesByDifficulty(
    String difficulty,
  ) {
    return getMockRecipes()
        .where((recipe) => recipe['difficulty'] == difficulty)
        .toList();
  }

  // ==================== 급여 데이터 ====================

  /// Mock 펫 급여 데이터
  static Map<String, dynamic> getMockPetFeedingData({String? petId}) {
    return {
      'currentWeight': petId == '1' ? 15.8 : 3.5,
      'targetWeight': petId == '1' ? 16.0 : 3.6,
      'dailyCalorieNeeds': petId == '1' ? 800 : 200,
      'recommendedDailyAmount': petId == '1' ? '320g' : '80g',
      'feedingFrequency': petId == '1' ? 2 : 3,
      'currentFood': {
        'brand': '프리미엄 펫푸드',
        'type': 'dry',
        'flavor': '연어&쌀',
        'packageSize': '3kg',
        'expiryDate': DateTime.now().add(const Duration(days: 180)),
      },
      'feedingHistory': [
        {
          'date': DateTime.now(),
          'amount': petId == '1' ? '160g' : '40g',
          'time': '07:30',
          'type': 'breakfast',
        },
        {
          'date': DateTime.now(),
          'amount': petId == '1' ? '160g' : '40g',
          'time': '18:30',
          'type': 'dinner',
        },
      ],
      'allergies': petId == '1' ? ['글루텐'] : ['유제품'],
      'preferences': petId == '1' ? ['생선', '쌀'] : ['닭고기', '연어'],
    };
  }

  /// 급여 추천 데이터
  static Map<String, dynamic> getMockFeedingRecommendations({String? petId}) {
    return {
      'recommendedBrands': [
        {
          'name': '로얄캐닌',
          'type': 'premium',
          'rating': 4.8,
          'price': '45,000원',
          'features': ['연령별 맞춤', '영양균형'],
        },
        {
          'name': '힐즈',
          'type': 'prescription',
          'rating': 4.7,
          'price': '52,000원',
          'features': ['수의사 추천', '치료식'],
        },
        {
          'name': '오리젠',
          'type': 'natural',
          'rating': 4.6,
          'price': '68,000원',
          'features': ['천연재료', '고단백'],
        },
      ],
      'feedingTips': [
        '정해진 시간에 규칙적으로 급여해주세요',
        '신선한 물을 항상 준비해주세요',
        '급여량은 펫의 활동량에 따라 조절하세요',
        '새로운 사료 교체 시 점진적으로 바꿔주세요',
      ],
      'warningSignals': [
        '식욕 부진이 2일 이상 계속될 때',
        '급격한 체중 변화가 있을 때',
        '소화불량 증상이 반복될 때',
      ],
    };
  }

  // ==================== 메뉴 계획 데이터 ====================

  /// Mock 주간 메뉴 데이터
  static Map<String, dynamic> getMockMenuData({String? petId}) {
    return {
      'weeklyMenu': {
        'monday': {
          'breakfast': {'recipe': 'recipe_1', 'portion': '160g'},
          'dinner': {'recipe': 'recipe_2', 'portion': '160g'},
        },
        'tuesday': {
          'breakfast': {'recipe': 'recipe_2', 'portion': '160g'},
          'dinner': {'recipe': 'recipe_1', 'portion': '160g'},
        },
        'wednesday': {
          'breakfast': {'recipe': 'recipe_1', 'portion': '160g'},
          'dinner': {'recipe': 'recipe_3', 'portion': '160g'},
          'snack': {'recipe': 'recipe_3', 'portion': '50g'},
        },
        'thursday': {
          'breakfast': {'recipe': 'recipe_2', 'portion': '160g'},
          'dinner': {'recipe': 'recipe_1', 'portion': '160g'},
        },
        'friday': {
          'breakfast': {'recipe': 'recipe_1', 'portion': '160g'},
          'dinner': {'recipe': 'recipe_2', 'portion': '160g'},
          'snack': {'recipe': 'recipe_3', 'portion': '50g'},
        },
        'saturday': {
          'breakfast': {'recipe': 'recipe_3', 'portion': '160g'},
          'dinner': {'recipe': 'recipe_1', 'portion': '160g'},
        },
        'sunday': {
          'breakfast': {'recipe': 'recipe_2', 'portion': '160g'},
          'dinner': {'recipe': 'recipe_3', 'portion': '160g'},
        },
      },
      'nutritionSummary': {
        'totalCalories': 5600,
        'avgDailyCalories': 800,
        'proteinRatio': 25.5,
        'fatRatio': 12.8,
        'carbRatio': 18.7,
      },
      'shoppingList': [
        {'item': '닭가슴살', 'amount': '1kg', 'priority': 'high'},
        {'item': '연어살', 'amount': '500g', 'priority': 'high'},
        {'item': '고구마', 'amount': '3개', 'priority': 'medium'},
        {'item': '바나나', 'amount': '6개', 'priority': 'low'},
      ],
    };
  }

  /// 오늘의 메뉴 추천
  static Map<String, dynamic> getMockTodayMenuRecommendation({String? petId}) {
    final recipes = getMockRecipes();
    return {
      'breakfast': recipes[0],
      'dinner': recipes[1],
      'snack': recipes[2],
      'totalCalories': 300,
      'nutritionBalance': {
        'protein': 'good',
        'fat': 'optimal',
        'carbs': 'balanced',
      },
      'preparation': {'totalTime': '45분', 'difficulty': '쉬움', 'steps': 3},
    };
  }

  // ==================== 급여 기록 데이터 ====================

  /// Mock 급여 기록 목록
  static List<Map<String, dynamic>> getMockFeedingRecords({String? petId}) {
    final allRecords = [
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'feedTime': DateTime.now().subtract(const Duration(hours: 2)),
        'foodType': '건사료',
        'amount': '160g',
        'calories': 320,
        'notes': '완식함',
        'mealType': 'breakfast',
        'foodBrand': '로얄캐닌',
      },
      {
        'id': MockHelper.generateId(),
        'petId': '1',
        'feedTime': DateTime.now().subtract(const Duration(hours: 14)),
        'foodType': '건사료',
        'amount': '160g',
        'calories': 320,
        'notes': '잔식 있음',
        'mealType': 'dinner',
        'foodBrand': '로얄캐닌',
      },
      {
        'id': MockHelper.generateId(),
        'petId': '2',
        'feedTime': DateTime.now().subtract(const Duration(hours: 1)),
        'foodType': '습식',
        'amount': '85g',
        'calories': 95,
        'notes': '완식함',
        'mealType': 'lunch',
        'foodBrand': '힐즈',
      },
    ];

    if (petId != null) {
      return allRecords.where((record) => record['petId'] == petId).toList();
    }
    return allRecords;
  }
}

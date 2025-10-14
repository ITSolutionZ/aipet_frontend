import 'dart:async';

import 'package:aipet_frontend/features/allergy/data/providers/allergy_providers.dart';
import 'package:aipet_frontend/features/allergy/domain/entities/product_entity.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/features/shopping/data/models/rakuten_pet_product_model.dart';
import 'package:aipet_frontend/features/shopping/data/providers/rakuten_products_provider.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 알레르기 제품 선택 화면
///
/// フード/サプリメント/おやつ/生食から選択してアレルギー関連製品を登録する画面
class AllergyProductSelectionScreen extends ConsumerStatefulWidget {
  /// 알레르기 발생 여부 (true: 발생, false: 미발생)
  final bool hasAllergy;

  /// 선택된 펫 ID
  final String petId;

  const AllergyProductSelectionScreen({
    super.key,
    required this.hasAllergy,
    required this.petId,
  });

  @override
  ConsumerState<AllergyProductSelectionScreen> createState() =>
      _AllergyProductSelectionScreenState();
}

class _AllergyProductSelectionScreenState
    extends ConsumerState<AllergyProductSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  final Set<String> _selectedProductIds = <String>{}; // 선택된 제품 ID 추적
  final List<String> _rawFoodIngredients = <String>[]; // 생식 재료 리스트

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // 초기 카테고리 제품 로드 (펫 종류와 탭 결합)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductsForPetAndCategory();
    });

    // 탭 변경 리스너
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadProductsForPetAndCategory();
        // 탭 변경 시 검색어 초기화
        _searchController.clear();
      }
    });
  }

  /// 탭 인덱스로 카테고리명 가져오기 (펫 종류에 따라 동적 생성)
  String _getCategoryName(int index) {
    final petType = _getPetTypeFromSelectedPet();

    switch (index) {
      case 0:
        return _getFoodCategory(petType);
      case 1:
        return _getSupplementCategory(petType);
      case 2:
        return _getSnackCategory(petType);
      case 3:
        return _getRawFoodCategory(petType);
      default:
        return _getFoodCategory(petType);
    }
  }

  /// 선택된 펫의 종류 가져오기
  String _getPetTypeFromSelectedPet() {
    final petsAsync = ref.read(petProfilesNotifierProvider);
    return petsAsync.when(
      data: (pets) {
        final selectedPet = pets.firstWhere(
          (pet) => pet.id == widget.petId,
          orElse: () => pets.first,
        );
        return _getPetType(selectedPet);
      },
      loading: () => 'ドッグ',
      error: (_, __) => 'ドッグ',
    );
  }

  /// 펫 종류별 푸드 카테고리
  String _getFoodCategory(String petType) {
    switch (petType) {
      case 'ドッグ':
        return 'ドッグフード';
      case 'キャット':
        return 'キャットフード';
      case 'ウサギ':
        return 'うさぎフード';
      case '鳥':
        return '鳥フード';
      case 'ハムスター':
        return 'ハムスターフード';
      default:
        return 'ドッグフード キャットフード';
    }
  }

  /// 펫 종류별 서플리먼트 카테고리
  String _getSupplementCategory(String petType) {
    switch (petType) {
      case 'ドッグ':
        return 'ドッグサプリメント';
      case 'キャット':
        return 'キャットサプリメント';
      case 'ウサギ':
        return 'うさぎサプリメント';
      case '鳥':
        return '鳥サプリメント';
      case 'ハムスター':
        return 'ハムスターサプリメント';
      default:
        return 'ドッグサプリメント キャットサプリメント';
    }
  }

  /// 펫 종류별 간식 카테고리
  String _getSnackCategory(String petType) {
    switch (petType) {
      case 'ドッグ':
        return 'ドッグおやつ';
      case 'キャット':
        return 'キャットおやつ';
      case 'ウサギ':
        return 'うさぎおやつ';
      case '鳥':
        return '鳥おやつ';
      case 'ハムスター':
        return 'ハムスターおやつ';
      default:
        return 'ドッグおやつ キャットおやつ';
    }
  }

  /// 펫 종류별 생식 카테고리
  String _getRawFoodCategory(String petType) {
    switch (petType) {
      case 'ドッグ':
        return 'ドッグ生食';
      case 'キャット':
        return 'キャット生食';
      case 'ウサギ':
        return 'うさぎ生食';
      case '鳥':
        return '鳥生食';
      case 'ハムスター':
        return 'ハムスター生食';
      default:
        return 'ドッグ生食 キャット生食';
    }
  }

  /// 펫 종류와 카테고리를 결합한 상품 로드
  void _loadProductsForPetAndCategory() {
    final petsAsync = ref.read(petProfilesNotifierProvider);
    petsAsync.whenData((pets) {
      final selectedPet = pets.firstWhere(
        (pet) => pet.id == widget.petId,
        orElse: () => pets.first,
      );

      final petType = _getPetType(selectedPet);
      final category = _getCategoryName(_tabController.index);

      // 펫 종류별 맞춤 검색어 생성
      final searchKeyword = _createPetSpecificKeyword(petType, category);

      final notifier = ref.read(rakutenProductsProvider.notifier);
      notifier.searchPetProducts(keyword: searchKeyword);
    });
  }

  /// 펫 종류별 맞춤 검색어 생성
  String _createPetSpecificKeyword(String petType, String category) {
    // 토끼, 새, 햄스터 등은 해당 동물 전용 검색어 사용
    if (petType == 'ウサギ' || petType == '鳥' || petType == 'ハムスター') {
      return category; // 이미 펫 종류별 카테고리이므로 그대로 사용
    }

    // 개/고양이는 기존 방식 유지 (호환성)
    return '$petType $category';
  }

  /// 펫 종류 판단 (개/고양이/토끼/기타)
  String _getPetType(dynamic pet) {
    final breed = pet.breed?.toLowerCase() ?? '';

    // 개 품종들
    final dogBreeds = [
      'golden retriever',
      'labrador',
      'bulldog',
      'poodle',
      'chihuahua',
      'shiba',
      'akita',
      'husky',
      'beagle',
      'dachshund',
      'pomeranian',
      'maltese',
      'yorkshire',
      'corgi',
      'german shepherd',
      'rottweiler',
      'ドッグ',
      'dog',
      '개',
    ];

    // 고양이 품종들
    final catBreeds = [
      'persian',
      'maine coon',
      'ragdoll',
      'scottish fold',
      'british shorthair',
      'american shorthair',
      'siamese',
      'munchkin',
      'russian blue',
      'キャット',
      'cat',
      '고양이',
      'fold',
    ];

    // 토끼 품종들
    final rabbitBreeds = [
      'holland lop',
      'mini lop',
      'netherland dwarf',
      'lionhead',
      'angora',
      'flemish giant',
      'mini rex',
      'rabbit',
      'うさぎ',
      '토끼',
      'ラビット',
    ];

    // 새 품종들
    final birdBreeds = [
      'budgerigar',
      'canary',
      'cockatiel',
      'lovebird',
      'parakeet',
      'parrot',
      'finch',
      'bird',
      '鳥',
      '새',
      'バード',
    ];

    // 햄스터 품종들
    final hamsterBreeds = [
      'golden hamster',
      'syrian hamster',
      'dwarf hamster',
      'roborovski',
      'winter white',
      'campbell',
      'hamster',
      'ハムスター',
      '햄스터',
    ];

    // 개 품종 확인
    for (final dogBreed in dogBreeds) {
      if (breed.contains(dogBreed)) {
        return 'ドッグ';
      }
    }

    // 고양이 품종 확인
    for (final catBreed in catBreeds) {
      if (breed.contains(catBreed)) {
        return 'キャット';
      }
    }

    // 토끼 품종 확인
    for (final rabbitBreed in rabbitBreeds) {
      if (breed.contains(rabbitBreed)) {
        return 'ウサギ';
      }
    }

    // 새 품종 확인
    for (final birdBreed in birdBreeds) {
      if (breed.contains(birdBreed)) {
        return '鳥';
      }
    }

    // 햄스터 품종 확인
    for (final hamsterBreed in hamsterBreeds) {
      if (breed.contains(hamsterBreed)) {
        return 'ハムスター';
      }
    }

    // 기본값: 개로 설정 (일반적으로 개가 더 많음)
    return 'ドッグ';
  }

  /// 탭 이름과 사용자 입력을 결합한 검색
  void _searchWithCategoryAndUserInput(String userInput) {
    final category = _getCategoryName(_tabController.index);
    // 알레르기 확인용이므로 먹는 제품만 검색 (용품 제외)
    final combinedKeyword = '$category $userInput';

    final notifier = ref.read(rakutenProductsProvider.notifier);
    notifier.searchPetProducts(keyword: combinedKeyword);
  }

  /// 실시간 검색 (디바운싱 적용)
  void _performRealTimeSearch(String userInput) {
    // 이전 타이머 취소
    _searchDebounceTimer?.cancel();

    // 새로운 타이머 시작 (300ms 후 검색 실행)
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      // 생식 탭이 아닌 경우에만 실시간 검색
      if (_tabController.index != 3) {
        _searchWithCategoryAndUserInput(userInput);
      }
    });
  }

  /// 제품명을 정리하여 반환 (브랜드와 핵심 상품명만)
  String _cleanProductName(String originalName) {
    String cleaned = originalName;

    // 광고적인 문구 제거
    final adPatterns = [
      r'【.*?】', // 【】로 둘러싸인 광고 문구
      r'\[.*?\]', // []로 둘러싸인 광고 문구
      r'★.*?★', // ★로 둘러싸인 광고 문구
      r'楽天.*?位', // 楽天連続1位 등
      r'限定.*?OFF', // 限定OFF 관련
      r'SNS.*?話題', // SNS話題 관련
      r'獣医師.*?奨', // 獣医師推奨 관련
      r'No\.\d+', // No.1, No.2 등
      r'\d+%', // 90%, 5% 등
      r'高級品', // 高級品
      r'話題', // 話題
      r'人気', // 人気
      r'おすすめ', // おすすめ
      r'お得', // お得
      r'送料無料', // 送料無料
      r'レビュー.*?\d+', // レビュー関連
      r'※.*?出荷', // ※일시적으로 구 패키지로 출荷 등
      r'<.*?>', // <> 안의 모든 내용
      r'\(.*?\)', // () 안의 모든 내용
    ];

    for (final pattern in adPatterns) {
      cleaned = cleaned.replaceAll(RegExp(pattern), '');
    }

    // 무게, 크기, 수량 정보 제거
    final sizePatterns = [
      r'\d+\.?\d*[kg|g|KG|G]', // 3.5kg, 500g 등
      r'\d+[ml|ML|l|L]', // 500ml, 1L 등
      r'\d+[個|枚|本|袋|缶|パック]', // 12개, 5매 등
      r'\d+x\d+', // 3x5 등
      r'\d+\.\d+[kg|g|KG|G]', // 1.2kg 등
      r'\d+/\d+', // 12/24 등
      r'\(.*?[kg|g|キロ|グラム].*?\)', // (3キロ...), (500g) 등
      r'\(.*?[g|G]×\d+\)', // (g×2) 등
      r'\(.*?\d+[kg|g|キロ|グラム].*?\)', // (3kg), (500g) 등
      r'g\s*\(.*?\)', // g (3キロ...) 등
      r'g\s*×\d+', // g×2 등
      r'[g|G]\s*\d*', // g, G, g500 등
    ];

    for (final pattern in sizePatterns) {
      cleaned = cleaned.replaceAll(RegExp(pattern), '');
    }

    // 연령/생애단계 정보 제거
    final agePatterns = [
      r'仔犬', // 강아지
      r'子猫', // 새끼고양이
      r'成犬', // 성견
      r'成猫', // 성묘
      r'高齢犬', // 노령견
      r'高齢猫', // 노령묘
      r'シニア', // 시니어
      r'パピー', // 퍼피
      r'キトン', // 키튼
      r'ジュニア', // 주니어
      r'\d+ヶ月', // 3개월 등
      r'\d+歳', // 1세 등
    ];

    for (final pattern in agePatterns) {
      cleaned = cleaned.replaceAll(RegExp(pattern), '');
    }

    // 추가 단위 및 수량 정보 제거
    final additionalPatterns = [
      r'\d+[g|G]\s*\(', // 500g ( 등
      r'\(.*?\d+[g|G].*?\)', // (500g), (3kg) 등
      r'\(.*?×.*?\)', // (×2), (×3) 등
      r'×\d+', // ×2, ×3 등
      r'\d+\s*×\s*\d+', // 500 × 2 등
      r'\(.*?\)', // 남은 괄호 내용들
      r'g\s*$', // 끝에 있는 g
      r'G\s*$', // 끝에 있는 G
      r'\s+g\s+', // 앞뒤 공백과 함께 있는 g
      r'\s+G\s+', // 앞뒤 공백과 함께 있는 G
    ];

    for (final pattern in additionalPatterns) {
      cleaned = cleaned.replaceAll(RegExp(pattern), '');
    }

    // 불필요한 공백 및 특수문자 정리
    cleaned = cleaned
        .replaceAll(RegExp(r'\s+'), ' ') // 연속된 공백을 하나로
        .replaceAll(RegExp(r'[　]'), ' ') // 전각 공백을 반각으로
        .replaceAll(RegExp(r'[,、]'), ' ') // 쉼표를 공백으로
        .trim(); // 앞뒤 공백 제거

    // 빈 문자열이면 원본 반환
    return cleaned.isEmpty ? originalName : cleaned;
  }

  /// 제품명에서 메이커(브랜드) 정보를 추출
  String _extractMaker(String productName) {
    // 주요 펫 푸드 메이커들 (더 많은 브랜드 추가)
    final makers = [
      'ロイヤルカナン',
      'ヒルズ',
      'オリジン',
      'アカナ',
      'カルナ4',
      'ベストブリード',
      'ガッツィ',
      'ベルカンド',
      'プラチナム',
      'サイエンスダイエット',
      'プロプラン',
      'アイムス',
      'ユーカヌバ',
      'ウェルネス',
      'ナチュラルバランス',
      'アーテミス',
      'ブルーバッファロー',
      'メリアル',
      'ネスレ',
      'ペディグリー',
      'フィリックス',
      'シーバ',
      'フォルツァ',
      'モンプチ',
      'アーロン',
      'グランデル',
      'ロータス',
      'オーシャン',
      'シンプリー',
      'ファーストチョイ스',
      'アニモンダ',
      'カナガン',
      'ウルフオブウォールストリート',
      'ファーマイナ',
      'プロテイン',
      'ハピドッグ',
      'ハピキャット',
      'ネイチャーズプロテクション',
      'プリスクリプション',
      'ハルマ',
      'サクラ',
      'マルカン',
      'ドギーマン',
      'イースター',
      'サンクス',
      'ビッツ',
      'ポッピン',
      'トップブリード',
      'マルキョー',
      'サンライズ',
      'ファインペッツ',
      'ハートランド',
      'ビクトリア',
      'ドクターズ',
      'ベスト',
      'ナチュラル',
      'オーガニック',
      'プレミアム',
    ];

    // 제품명에서 메이커 찾기 (더 정확한 매칭)
    for (final maker in makers) {
      if (productName.contains(maker)) {
        return maker;
      }
    }

    // 메이커를 찾지 못한 경우, 제품명의 첫 번째 단어를 메이커로 사용
    final cleanedName = productName.trim();
    if (cleanedName.isNotEmpty) {
      // 공백이나 특수문자로 분리하여 첫 번째 단어 추출
      final words = cleanedName.split(RegExp(r'[\s　\-・_]+'));
      if (words.isNotEmpty && words.first.isNotEmpty) {
        return words.first;
      }
    }

    // 모든 것이 실패한 경우 기본값
    return 'メーカー不明';
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel(); // 타이머 정리
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pointDark),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // 탭바
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.pointBrown,
                  unselectedLabelColor: AppColors.pointGray,
                  indicatorColor: AppColors.pointBrown,
                  labelStyle: AppFonts.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'フード'),
                    Tab(text: 'サプリメント'),
                    Tab(text: 'おやつ'),
                    Tab(text: '生食'),
                  ],
                ),
              ),

              // 검색바
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: _getSearchHintText(),
                    hintStyle: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointGray,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.pointGray,
                    ),
                    filled: true,
                    fillColor: AppColors.pointOffWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      borderSide: BorderSide(
                        color: AppColors.pointGray.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      borderSide: BorderSide(
                        color: AppColors.pointGray.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      borderSide: const BorderSide(
                        color: AppColors.pointBrown,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      // 실시간 검색: 디바운싱 적용으로 빠른 반응성
                      _performRealTimeSearch(value);
                    } else {
                      // 검색어 완전 삭제 시 → 펫 종류 + 탭으로 복귀
                      _searchDebounceTimer?.cancel(); // 타이머 취소
                      _loadProductsForPetAndCategory();
                    }
                  },
                  onSubmitted: (value) {
                    // 생식 탭인 경우 엔터키로 재료 추가
                    if (_tabController.index == 3 && value.trim().isNotEmpty) {
                      _addRawFoodIngredient(value.trim());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductList('フード'),
          _buildProductList('サプリメント'),
          _buildProductList('おやつ'),
          _buildRawFoodInputTab(), // 생식 탭은 특별한 입력 UI
        ],
      ),
    );
  }

  Widget _buildProductList(String category) {
    final productsState = ref.watch(rakutenProductsProvider);

    // 로딩 중
    if (productsState.isLoading && productsState.products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 에러 발생
    if (productsState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.pointGray.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'エラーが発生しました',
                style: AppFonts.bodyLarge.copyWith(color: AppColors.pointGray),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                productsState.error!,
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 제품 목록 표시
    final products = productsState.products;

    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            '商品がありません',
            style: AppFonts.bodyLarge.copyWith(color: AppColors.pointGray),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildRakutenProductCard(product);
      },
    );
  }

  /// Rakuten 제품 카드
  Widget _buildRakutenProductCard(RakutenPetProduct product) {
    final isSelected = _selectedProductIds.contains(product.itemCode);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isSelected
            ? (widget.hasAllergy
                  ? const Color(0xFFFF6B9D).withValues(
                      alpha: 0.1,
                    ) // 알레르기 제품은 분홍색 배경
                  : const Color(
                      0xFF4CAF50,
                    ).withValues(alpha: 0.1)) // 비알레르기 제품은 초록색 배경
            : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: isSelected
            ? Border.all(
                color: widget.hasAllergy
                    ? const Color(0xFFFF6B9D) // 알레르기 제품은 분홍색 테두리
                    : const Color(0xFF4CAF50), // 비알레르기 제품은 초록색 테두리
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _selectRakutenProduct(product),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // 선택 마크 (왼쪽에 표시)
              if (_selectedProductIds.contains(product.itemCode))
                Container(
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Icon(
                    Icons.check_circle,
                    color: widget.hasAllergy
                        ? const Color(0xFFFF6B9D) // 알레르기 제품은 분홍색
                        : const Color(0xFF4CAF50), // 비알레르기 제품은 초록색
                    size: 24,
                  ),
                ),
              // 제품 이미지
              if (product.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  child: Image.network(
                    product.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: AppColors.pointOffWhite,
                        child: const Icon(
                          Icons.shopping_bag,
                          color: AppColors.pointGray,
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.pointOffWhite,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: AppColors.pointGray,
                    size: 32,
                  ),
                ),
              const SizedBox(width: AppSpacing.md),

              // 제품 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 메이커 (브랜드)
                    Text(
                      _extractMaker(product.itemName),
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 제품명 (정리된 버전)
                    Text(
                      _cleanProductName(product.itemName),
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Rakuten 제품 선택/해제
  void _selectRakutenProduct(RakutenPetProduct rakutenProduct) {
    final isAlreadySelected = _selectedProductIds.contains(
      rakutenProduct.itemCode,
    );

    // Rakuten 제품을 ProductEntity로 변환
    final product = ProductEntity(
      id: rakutenProduct.itemCode,
      name: rakutenProduct.itemName,
      category: _getCategoryName(_tabController.index),
      price: rakutenProduct.itemPrice.toInt(),
      brandId: rakutenProduct.shopCode,
      ingredients: rakutenProduct.itemCaption, // 상품 설명을 성분으로 임시 사용
      imageUrl: rakutenProduct.imageUrl, // 상품 이미지 URL 추가
    );

    // 디버깅용 로그
    debugPrint('🔍 Product Selection Debug:');
    debugPrint('  - Pet ID: ${widget.petId}');
    debugPrint('  - Product ID: ${product.id}');
    debugPrint('  - Product Name: ${product.name}');
    debugPrint('  - Has Allergy: ${widget.hasAllergy}');
    debugPrint('  - Is Already Selected: $isAlreadySelected');

    if (isAlreadySelected) {
      // 이미 선택된 제품이면 선택 해제
      ref
          .read(selectedAllergyProductsProvider.notifier)
          .removeProduct(widget.petId, product.id, widget.hasAllergy);

      setState(() {
        _selectedProductIds.remove(product.id);
      });

      final message = widget.hasAllergy
          ? 'アレルギー商品から削除しました'
          : 'アレルギーなし商品から削除しました';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.pointGray,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // 선택되지 않은 제품이면 선택
      ref
          .read(selectedAllergyProductsProvider.notifier)
          .addProduct(widget.petId, product, widget.hasAllergy);

      setState(() {
        _selectedProductIds.add(product.id);
      });

      // Provider 상태 확인 로그
      final currentState = ref.read(selectedAllergyProductsProvider);
      debugPrint('🔍 After Product Addition:');
      debugPrint('  - Provider State Keys: ${currentState.keys}');
      debugPrint('  - Pet Data: ${currentState[widget.petId]}');

      final message = widget.hasAllergy ? 'アレルギー商品に追加しました' : 'アレルギーなし商品に追加しました';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.pointBrown,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // 추가 후 상태 확인
    final currentState = ref.read(selectedAllergyProductsProvider);
    debugPrint('  - Current State Keys: ${currentState.keys}');
    debugPrint('  - Pet Data: ${currentState[widget.petId]}');
  }

  /// 생식 입력 탭 (검색창 사용)
  Widget _buildRawFoodInputTab() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // 안내 메시지
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointOffWhite,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: AppColors.pointBrown.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.restaurant,
                  color: AppColors.pointBrown,
                  size: 32,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '生食用食材を入力してください',
                  style: AppFonts.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '例: チーズ、にんじん、牛乳、りんごなど',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 추가된 생식 재료 리스트
          Expanded(child: _buildRawFoodIngredientsList()),
        ],
      ),
    );
  }

  /// 생식 재료 리스트
  Widget _buildRawFoodIngredientsList() {
    if (_rawFoodIngredients.isEmpty) {
      return Center(
        child: Text(
          'まだ食材が追加されていません',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
        ),
      );
    }

    return ListView.builder(
      itemCount: _rawFoodIngredients.length,
      itemBuilder: (context, index) {
        final ingredient = _rawFoodIngredients[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: AppColors.pointBrown.withValues(alpha: 0.3),
            ),
          ),
          child: ListTile(
            leading: const Icon(Icons.restaurant, color: AppColors.pointBrown),
            title: Text(
              ingredient,
              style: AppFonts.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.pointDark,
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                _removeRawFoodIngredient(index);
              },
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.pointGray,
              ),
            ),
            onTap: () {
              _selectRawFoodIngredient(ingredient);
            },
          ),
        );
      },
    );
  }

  /// 검색 힌트 텍스트 반환
  String _getSearchHintText() {
    switch (_tabController.index) {
      case 0:
        return 'ドッグフード・キャットフード名を入力してください';
      case 1:
        return 'サプリメント名を入力してください';
      case 2:
        return 'おやつ名を入力してください';
      case 3:
        return '生食用食材名を入力 (例: チーズ、にんじん)';
      default:
        return '商品名を入力してください';
    }
  }

  /// 생식 재료 추가
  void _addRawFoodIngredient(String ingredient) {
    if (ingredient.isNotEmpty && !_rawFoodIngredients.contains(ingredient)) {
      setState(() {
        _rawFoodIngredients.add(ingredient);
      });
      // 검색창 초기화
      _searchController.clear();
    }
  }

  /// 생식 재료 제거
  void _removeRawFoodIngredient(int index) {
    setState(() {
      _rawFoodIngredients.removeAt(index);
    });
  }

  /// 생식 재료 선택 (알레르기/비알레르기 추가)
  void _selectRawFoodIngredient(String ingredient) {
    // 생식 재료를 ProductEntity로 변환
    final product = ProductEntity(
      id: 'raw_food_${ingredient}_${DateTime.now().millisecondsSinceEpoch}',
      name: ingredient,
      category: '生食',
      price: 0,
      brandId: 'raw_food',
      ingredients: ingredient,
      imageUrl: null, // 생식 재료는 이미지 없음
    );

    // Provider에 제품 추가
    ref
        .read(selectedAllergyProductsProvider.notifier)
        .addProduct(widget.petId, product, widget.hasAllergy);

    // Provider 상태 확인 로그
    final currentState = ref.read(selectedAllergyProductsProvider);
    debugPrint('🔍 After Raw Food Addition:');
    debugPrint('  - Pet ID: ${widget.petId}');
    debugPrint('  - Ingredient: $ingredient');
    debugPrint('  - Provider State Keys: ${currentState.keys}');
    debugPrint('  - Pet Data: ${currentState[widget.petId]}');

    final message = widget.hasAllergy
        ? 'アレルギー食材に追加しました: $ingredient'
        : 'アレルギーなし食材に追加しました: $ingredient';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.pointBrown,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

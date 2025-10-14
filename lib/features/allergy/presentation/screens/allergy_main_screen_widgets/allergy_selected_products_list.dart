import 'package:aipet_frontend/features/allergy/data/providers/allergy_providers.dart';
import 'package:aipet_frontend/features/allergy/domain/entities/product_entity.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'allergy_products_tab.dart';
import 'category_tab_view_widget.dart';

/// 선택된 제품 리스트 섹션
class AllergySelectedProductsList extends ConsumerStatefulWidget {
  final PetProfileEntity selectedPet;
  final VoidCallback onAnalyze;
  final bool isAnalyzing;

  const AllergySelectedProductsList({
    super.key,
    required this.selectedPet,
    required this.onAnalyze,
    required this.isAnalyzing,
  });

  @override
  ConsumerState<AllergySelectedProductsList> createState() =>
      _AllergySelectedProductsListState();
}

class _AllergySelectedProductsListState
    extends ConsumerState<AllergySelectedProductsList>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedProductsMap = ref.watch(selectedAllergyProductsProvider);
    final allergyData = selectedProductsMap[widget.selectedPet.id];

    // 디버깅용 로그
    debugPrint('🔍 AllergySelectedProductsList Debug:');
    debugPrint('  - Pet ID: ${widget.selectedPet.id}');
    debugPrint('  - Pet Name: ${widget.selectedPet.name}');
    debugPrint('  - Selected Products Map Keys: ${selectedProductsMap.keys}');
    debugPrint('  - Allergy Data: $allergyData');
    debugPrint(
      '  - Allergy Products Count: ${allergyData?.allergyProducts.length ?? 0}',
    );
    debugPrint(
      '  - Non-Allergy Products Count: ${allergyData?.nonAllergyProducts.length ?? 0}',
    );

    final hasAllergyProducts = allergyData?.allergyProducts.isNotEmpty ?? false;
    final hasNonAllergyProducts =
        allergyData?.nonAllergyProducts.isNotEmpty ?? false;
    final allergyCount = allergyData?.allergyProducts.length ?? 0;
    final nonAllergyCount = allergyData?.nonAllergyProducts.length ?? 0;

    // 디버깅을 위해 항상 제품 리스트 표시
    debugPrint(
      '  - Showing product list (Allergy: $allergyCount, Non-Allergy: $nonAllergyCount)',
    );

    // 실제 데이터가 있는지 확인
    if (allergyData != null) {
      debugPrint('  - Allergy Data exists: ${allergyData.toString()}');
      if (allergyData.allergyProducts.isNotEmpty) {
        debugPrint(
          '  - Allergy Products: ${allergyData.allergyProducts.map((p) => p.name).toList()}',
        );
      }
      if (allergyData.nonAllergyProducts.isNotEmpty) {
        debugPrint(
          '  - Non-Allergy Products: ${allergyData.nonAllergyProducts.map((p) => p.name).toList()}',
        );
      }
    } else {
      debugPrint('  - No allergy data found for pet: ${widget.selectedPet.id}');
    }

    return Container(
      height: 350,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        children: [
          // 메인 탭바
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.pointOffWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.medium),
                topRight: Radius.circular(AppRadius.medium),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AllergyMainTabButton(
                    isSelected: _mainTabController.index == 0,
                    icon: Icons.warning_amber_rounded,
                    label: 'あった',
                    count: allergyCount,
                    color: const Color(0xFFFF6B9D),
                    onTap: () {
                      _mainTabController.animateTo(0);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AllergyMainTabButton(
                    isSelected: _mainTabController.index == 1,
                    icon: Icons.check_circle,
                    label: 'なかった',
                    count: nonAllergyCount,
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      _mainTabController.animateTo(1);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          // 탭뷰
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                _buildAllergyProductsTab(allergyData?.allergyProducts ?? []),
                _buildNonAllergyProductsTab(
                  allergyData?.nonAllergyProducts ?? [],
                ),
              ],
            ),
          ),
          // 분석 버튼 (양쪽 모두 있을 때만 표시)
          if (hasAllergyProducts && hasNonAllergyProducts)
            _buildAnalyzeButton(),
        ],
      ),
    );
  }

  Widget _buildAllergyProductsTab(List<ProductEntity> products) {
    if (products.isEmpty) {
      return const AllergyProductsEmptyTab(
        icon: Icons.warning_amber_rounded,
        color: Color(0xFFFF6B9D),
        message: 'アレルギー商品がありません',
      );
    }

    return _buildCategoryTabView(products, true);
  }

  Widget _buildNonAllergyProductsTab(List<ProductEntity> products) {
    if (products.isEmpty) {
      return const AllergyProductsEmptyTab(
        icon: Icons.check_circle,
        color: Color(0xFF4CAF50),
        message: 'アレルギーなし商品がありません',
      );
    }

    return _buildCategoryTabView(products, false);
  }

  Widget _buildCategoryTabView(
    List<ProductEntity> products,
    bool isAllergyTab,
  ) {
    debugPrint('🔍 _buildCategoryTabView:');
    debugPrint('  - isAllergyTab: $isAllergyTab');
    debugPrint('  - Total products: ${products.length}');
    debugPrint(
      '  - Products: ${products.map((p) => '${p.name} (${p.category})').toList()}',
    );

    // 카테고리별 분류 (다양한 프리푸드 카테고리를 포함)
    final productsByCategory = <String, List<ProductEntity>>{
      'フード': products.where((p) => _isFoodCategory(p.category)).toList(),
      'サプリメント': products
          .where((p) => _isSupplementCategory(p.category))
          .toList(),
      'おやつ': products.where((p) => _isSnackCategory(p.category)).toList(),
      '生食': products.where((p) => _isRawFoodCategory(p.category)).toList(),
    };

    debugPrint('  - Products by category:');
    productsByCategory.forEach((category, categoryProducts) {
      debugPrint('    - $category: ${categoryProducts.length} products');
    });

    return CategoryTabViewWidget(
      productsByCategory: productsByCategory,
      isAllergyTab: isAllergyTab,
      onRemoveProduct: (productId) {
        ref
            .read(selectedAllergyProductsProvider.notifier)
            .removeProduct(widget.selectedPet.id, productId, isAllergyTab);
      },
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: ElevatedButton(
        onPressed: widget.isAnalyzing ? null : widget.onAnalyze,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointBrown,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        child: widget.isAnalyzing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '分析中...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.analytics, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'アレルギー原料を分析',
                    style: AppFonts.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 프리푸드 카테고리 판별
  bool _isFoodCategory(String category) {
    return category == 'フード' ||
        category == 'ドッグフード' ||
        category == 'キャットフード' ||
        category == 'うさぎフード' ||
        category == '鳥フード' ||
        category == 'ハムスターフード' ||
        category.contains('フード');
  }

  /// 서플리먼트 카테고리 판별
  bool _isSupplementCategory(String category) {
    return category == 'サプリメント' ||
        category == 'ドッグサプリメント' ||
        category == 'キャットサプリメント' ||
        category == 'うさぎサプリメント' ||
        category == '鳥サプリメント' ||
        category == 'ハムスターサプリメント' ||
        category.contains('サプリメント');
  }

  /// 스낵 카테고리 판별
  bool _isSnackCategory(String category) {
    return category == 'おやつ' ||
        category == 'ドッグおやつ' ||
        category == 'キャットおやつ' ||
        category == 'うさぎおやつ' ||
        category == '鳥おやつ' ||
        category == 'ハムスターおやつ' ||
        category.contains('おやつ');
  }

  /// 생식 카테고리 판별
  bool _isRawFoodCategory(String category) {
    return category == '生食' ||
        category == 'ドッグ生食' ||
        category == 'キャット生食' ||
        category == 'うさぎ生食' ||
        category == '鳥生食' ||
        category == 'ハムスター生食' ||
        category.contains('生食');
  }
}

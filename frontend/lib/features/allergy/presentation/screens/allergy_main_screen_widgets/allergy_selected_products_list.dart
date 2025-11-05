import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../../shared/shared.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../utils/category_helper.dart';
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
    _mainTabController = TabController(
      length: AllergyConstants.mainTabCount,
      vsync: this,
    );
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

    final hasAllergyProducts = allergyData?.allergyProducts.isNotEmpty ?? false;
    final hasNonAllergyProducts =
        allergyData?.nonAllergyProducts.isNotEmpty ?? false;
    final allergyCount = allergyData?.allergyProducts.length ?? 0;
    final nonAllergyCount = allergyData?.nonAllergyProducts.length ?? 0;

    return Container(
      height: AllergyConstants.productListHeight,
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
    // CategoryHelper를 사용한 제품 분류
    final productsByCategory = CategoryHelper.categorizeProducts(
      products: products,
      getCategoryName: (product) => product.category,
    );

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
}

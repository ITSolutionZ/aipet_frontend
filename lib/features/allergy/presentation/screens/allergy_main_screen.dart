import 'package:aipet_frontend/features/allergy/data/providers/allergy_providers.dart';
import 'package:aipet_frontend/features/allergy/data/providers/allergy_service_providers.dart';
import 'package:aipet_frontend/features/allergy/domain/entities/product_entity.dart';
import 'package:aipet_frontend/features/allergy/presentation/screens/allergy_analysis_result_screen.dart';
import 'package:aipet_frontend/features/allergy/presentation/screens/allergy_product_selection_screen.dart';
import 'package:aipet_frontend/features/allergy/presentation/widgets/allergy_pet_selector.dart';
import 'package:aipet_frontend/features/allergy/presentation/widgets/saved_analysis_accordion.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/mock_data/brand_mock_data.dart';
import 'package:aipet_frontend/shared/shared.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 알레르기 메인 화면
///
/// 홈에서 이동하는 알레르기 통합 화면입니다.
/// - 상단: 알레르기 원료 분석 안내
/// - 중간: 알레르기 발생/미발생 필터 선택
/// - 하단: 커뮤니티 게시글 목록
class AllergyMainScreen extends ConsumerStatefulWidget {
  const AllergyMainScreen({super.key});

  @override
  ConsumerState<AllergyMainScreen> createState() => _AllergyMainScreenState();
}

class _AllergyMainScreenState extends ConsumerState<AllergyMainScreen>
    with SingleTickerProviderStateMixin {
  /// 선택된 필터 (null: 전체, true: 발생, false: 미발생)
  bool? _selectedFilter;

  /// 선택된 펫
  PetProfileEntity? _selectedPet;

  /// 메인 탭 컨트롤러 (알레르기 있던/없던)
  TabController? _mainTabController;

  /// 분석 진행 상태
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petProfilesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SavedAnalysisAccordion(),
        actions: [
          // 펫 선택 위젯
          petsAsync.when(
            data: (pets) {
              if (pets.isEmpty) return const SizedBox.shrink();

              // 첫 로드 시 첫 번째 펫 자동 선택
              if (_selectedPet == null && pets.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _selectedPet = pets.first;
                    });
                  }
                });
              }

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: AllergyPetSelector(
                  selectedPet: _selectedPet,
                  pets: pets,
                  onPetSelected: (pet) {
                    setState(() {
                      _selectedPet = pet;
                    });
                  },
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // 상단 안내 섹션
                    _buildInfoSection(),
                    const SizedBox(height: AppSpacing.md),
                    // 알레르기 발생/미발생 선택 섹션
                    _buildFilterSection(),
                    const SizedBox(height: AppSpacing.md),
                    // 선택된 펫 정보 표시
                    if (_selectedPet != null) _buildSelectedPetInfo(),
                    const SizedBox(height: AppSpacing.sm),
                    // 선택된 제품 리스트
                    if (_selectedPet != null)
                      Expanded(child: _buildSelectedProductsList()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 상단 안내 섹션
  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'うちの子に\nどんな食物アレルギーがあるか\n調べてみませんか？',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '今まで食べたフードの原料を分析して、',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          Text(
            '重複する原料を見つけ出し、',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          Text(
            'アレルギーの疑いがある原料を特定します。',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 필터 선택 섹션
  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(
              label: 'アレルギー あった',
              isSelected: _selectedFilter == true,
              color: const Color(0xFFFF6B9D),
              onTap: () {
                setState(() {
                  _selectedFilter = true;
                });

                // 제품 선택 화면으로 이동
                if (_selectedPet != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllergyProductSelectionScreen(
                        hasAllergy: true,
                        petId: _selectedPet!.id,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildFilterButton(
              label: 'アレルギー なかった',
              isSelected: _selectedFilter == false,
              color: const Color(0xFF4CAF50),
              onTap: () {
                setState(() {
                  _selectedFilter = false;
                });

                // 제품 선택 화면으로 이동
                if (_selectedPet != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllergyProductSelectionScreen(
                        hasAllergy: false,
                        petId: _selectedPet!.id,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 필터 버튼
  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected
                ? color
                : AppColors.pointDark.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(Icons.add, color: color, size: 32),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppFonts.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 선택된 펫 정보 표시
  Widget _buildSelectedPetInfo() {
    if (_selectedPet == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.pointBrown.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // 펫 이미지
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.pureWhite,
            backgroundImage: _selectedPet!.imagePath != null
                ? AssetImage(_selectedPet!.imagePath!)
                : const AssetImage('assets/icons/aipet_logo.png'),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${_selectedPet!.name}のアレルギー情報を検索中',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 선택된 제품 리스트
  Widget _buildSelectedProductsList() {
    if (_selectedPet == null) return const SizedBox.shrink();

    final allergyData = ref.watch(
      selectedAllergyProductsProvider,
    )[_selectedPet!.id];

    final hasAllergyProducts = allergyData?.allergyProducts.isNotEmpty ?? false;
    final hasNonAllergyProducts =
        allergyData?.nonAllergyProducts.isNotEmpty ?? false;
    final allergyCount = allergyData?.allergyProducts.length ?? 0;
    final nonAllergyCount = allergyData?.nonAllergyProducts.length ?? 0;

    if (!hasAllergyProducts && !hasNonAllergyProducts) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: AppColors.pointGray.withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '選択した商品がありません',
                style: AppFonts.bodyLarge.copyWith(color: AppColors.pointGray),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '上のボタンから商品を追加してください',
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 500, // 고정 높이 지정
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        children: [
          // 탭바
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.pointGray.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: TabBar(
              controller: _mainTabController,
              labelColor: AppColors.pointBrown,
              unselectedLabelColor: AppColors.pointGray,
              indicatorColor: AppColors.pointBrown,
              labelStyle: AppFonts.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 16),
                      const SizedBox(width: 4),
                      Text('あった ($allergyCount)'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 16),
                      const SizedBox(width: 4),
                      Text('なかった ($nonAllergyCount)'),
                    ],
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
                _buildAllergyProductsTab(),
                _buildNonAllergyProductsTab(),
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

  /// 알레르기 있던 제품 탭
  Widget _buildAllergyProductsTab() {
    final allergyData = ref.watch(
      selectedAllergyProductsProvider,
    )[_selectedPet!.id];
    final products = allergyData?.allergyProducts ?? [];

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'アレルギー商品がありません',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
          ],
        ),
      );
    }

    return _buildCategoryTabView(products, true);
  }

  /// 알레르기 없던 제품 탭
  Widget _buildNonAllergyProductsTab() {
    final allergyData = ref.watch(
      selectedAllergyProductsProvider,
    )[_selectedPet!.id];
    final products = allergyData?.nonAllergyProducts ?? [];

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'アレルギーなし商品がありません',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
          ],
        ),
      );
    }

    return _buildCategoryTabView(products, false);
  }

  /// 카테고리별 탭뷰
  Widget _buildCategoryTabView(
    List<ProductEntity> products,
    bool isAllergyTab,
  ) {
    // 카테고리별 분류
    final productsByCategory = <String, List<ProductEntity>>{
      '사료': products.where((p) => p.category == '사료').toList(),
      '영양제': products.where((p) => p.category == '영양제').toList(),
      '간식': products.where((p) => p.category == '간식').toList(),
      '생식': products.where((p) => p.category == '생식').toList(),
    };

    return CategoryTabViewWidget(
      productsByCategory: productsByCategory,
      isAllergyTab: isAllergyTab,
      onRemoveProduct: (productId) {
        if (_selectedPet != null) {
          ref
              .read(selectedAllergyProductsProvider.notifier)
              .removeProduct(_selectedPet!.id, productId, isAllergyTab);
        }
      },
    );
  }

  /// 분석 버튼
  Widget _buildAnalyzeButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _performAnalysis,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointBrown,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        child: _isAnalyzing
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

  /// 분석 실행
  Future<void> _performAnalysis() async {
    if (_selectedPet == null || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // OpenAI 분석 실행
      final analysisService = ref.read(allergyAnalysisServiceProvider);
      final result = await ref
          .read(selectedAllergyProductsProvider.notifier)
          .analyzeAllergyIngredients(_selectedPet!.id, analysisService);

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });

        // 분석 결과 페이지로 이동
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllergyAnalysisResultScreen(
              analysisResult: result,
              petName: _selectedPet!.name,
              petId: _selectedPet!.id,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });

        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分析エラー: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

/// 카테고리별 탭뷰를 위한 StatefulWidget
class CategoryTabViewWidget extends StatefulWidget {
  final Map<String, List<ProductEntity>> productsByCategory;
  final bool isAllergyTab;
  final ValueChanged<String> onRemoveProduct;

  const CategoryTabViewWidget({
    super.key,
    required this.productsByCategory,
    required this.isAllergyTab,
    required this.onRemoveProduct,
  });

  @override
  State<CategoryTabViewWidget> createState() => _CategoryTabViewWidgetState();
}

class _CategoryTabViewWidgetState extends State<CategoryTabViewWidget>
    with SingleTickerProviderStateMixin {
  late TabController _categoryTabController;

  @override
  void initState() {
    super.initState();
    _categoryTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _categoryTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 카테고리 탭바
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.pointGray.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: TabBar(
            controller: _categoryTabController,
            labelColor: AppColors.pointBrown,
            unselectedLabelColor: AppColors.pointGray,
            indicatorColor: AppColors.pointBrown,
            labelStyle: AppFonts.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: '사료 (${widget.productsByCategory['사료']?.length ?? 0})'),
              Tab(
                text: '영양제 (${widget.productsByCategory['영양제']?.length ?? 0})',
              ),
              Tab(text: '간식 (${widget.productsByCategory['간식']?.length ?? 0})'),
              Tab(text: '생식 (${widget.productsByCategory['생식']?.length ?? 0})'),
            ],
          ),
        ),
        // 제품 리스트
        Expanded(
          child: TabBarView(
            controller: _categoryTabController,
            children: [
              _buildProductList(widget.productsByCategory['사료'] ?? [], '사료'),
              _buildProductList(widget.productsByCategory['영양제'] ?? [], '영양제'),
              _buildProductList(widget.productsByCategory['간식'] ?? [], '간식'),
              _buildProductList(widget.productsByCategory['생식'] ?? [], '생식'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductList(List<ProductEntity> products, String category) {
    if (products.isEmpty) {
      return Center(
        child: Text(
          '$categoryの商品がありません',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: products.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    final brand = BrandMockData.brands.firstWhere(
      (b) => b.id == product.brandId,
      orElse: () => BrandMockData.brands.first,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.pointGray.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 브랜드명
                Text(
                  brand.japaneseName,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // 제품명
                Text(
                  product.name,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // 삭제 버튼
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.pointGray, size: 20),
            onPressed: () => widget.onRemoveProduct(product.id),
          ),
        ],
      ),
    );
  }
}

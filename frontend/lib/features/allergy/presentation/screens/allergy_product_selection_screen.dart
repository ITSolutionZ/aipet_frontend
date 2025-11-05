import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/pet_profile/pet_profile.dart';
import '../../../../../features/shopping/shopping.dart';
import '../controllers/allergy_product_selection_controller.dart';
import '../utils/pet_category_mapper.dart';
import '../widgets/product_selection/product_list_tab.dart';
import '../widgets/product_selection/raw_food_input_tab.dart';



/// アレルギー商品選択画面
///
/// フード/サプリメント/おやつ/生食から選択してアレルギー関連商品を登録する画面
class AllergyProductSelectionScreen extends ConsumerStatefulWidget {
  /// アレルギー発生有無 (true: 発生, false: 未発生)
  final bool hasAllergy;

  /// 選択されたペットID
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
  late AllergyProductSelectionController _controller;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  final Set<String> _selectedProductIds = <String>{};
  final List<String> _rawFoodIngredients = <String>[];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _controller = AllergyProductSelectionController(
      ref,
      petId: widget.petId,
      hasAllergy: widget.hasAllergy,
    );

    // 初期カテゴリ商品ロード
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });

    // タブ変更リスナー
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadProducts();
        _searchController.clear();
      }
    });
  }

  /// 商品ロード (petsを取得してcontrollerに渡す)
  void _loadProducts() {
    final petsAsync = ref.read(petProfilesProvider);
    if (petsAsync.isLoading || petsAsync.hasError) return;

    final pets = petsAsync.asData?.value ?? [];
    _controller.loadProductsForPetAndCategory(_tabController.index, pets);
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _tabController.dispose();
    _searchController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petProfilesProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: _buildAppBar(),
      body: petsAsync.when(
        data: (pets) => _buildBody(pets),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラー: $error'),
        ),
      ),
    );
  }

  /// AppBar構築
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
            _buildTabBar(),
            _buildSearchBar(),
          ],
        ),
      ),
    );
  }

  /// タブバー
  Widget _buildTabBar() {
    return Container(
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
    );
  }

  /// 検索バー
  Widget _buildSearchBar() {
    return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
          hintText: PetCategoryMapper.getSearchHint(_tabController.index),
          hintStyle: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          prefixIcon: const Icon(Icons.search, color: AppColors.pointGray),
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
                      _performRealTimeSearch(value);
                    } else {
            _searchDebounceTimer?.cancel();
            _loadProducts();
                    }
                  },
                  onSubmitted: (value) {
                    if (_tabController.index == 3 && value.trim().isNotEmpty) {
                      _addRawFoodIngredient(value.trim());
                    }
                  },
      ),
    );
  }

  /// ボディ構築
  Widget _buildBody(List<PetProfileEntity> pets) {
    final productsState = ref.watch(rakutenProductsProvider);

    return TabBarView(
      controller: _tabController,
            children: [
        ProductListTab(
          category: 'フード',
          products: productsState.products,
          isLoading: productsState.isLoading,
          error: productsState.error,
          hasAllergy: widget.hasAllergy,
          selectedProductIds: _selectedProductIds,
          onProductTap: (product) => _controller.selectRakutenProduct(
            context,
            product,
            _tabController.index,
            _selectedProductIds,
            (newIds) => setState(() => _selectedProductIds
              ..clear()
              ..addAll(newIds)),
            pets,
          ),
        ),
        ProductListTab(
          category: 'サプリメント',
          products: productsState.products,
          isLoading: productsState.isLoading,
          error: productsState.error,
          hasAllergy: widget.hasAllergy,
          selectedProductIds: _selectedProductIds,
          onProductTap: (product) => _controller.selectRakutenProduct(
            context,
            product,
            _tabController.index,
            _selectedProductIds,
            (newIds) => setState(() => _selectedProductIds
              ..clear()
              ..addAll(newIds)),
            pets,
          ),
        ),
        ProductListTab(
          category: 'おやつ',
          products: productsState.products,
          isLoading: productsState.isLoading,
          error: productsState.error,
          hasAllergy: widget.hasAllergy,
          selectedProductIds: _selectedProductIds,
          onProductTap: (product) => _controller.selectRakutenProduct(
            context,
            product,
            _tabController.index,
            _selectedProductIds,
            (newIds) => setState(() => _selectedProductIds
              ..clear()
              ..addAll(newIds)),
            pets,
          ),
        ),
        RawFoodInputTab(
          ingredients: _rawFoodIngredients,
          onRemove: _removeRawFoodIngredient,
          onSelect: (ingredient) => _controller.selectRawFoodIngredient(
            context,
            ingredient,
          ),
        ),
      ],
    );
  }

  /// リアルタイム検索
  void _performRealTimeSearch(String userInput) {
    _searchDebounceTimer?.cancel();

    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_tabController.index != 3) {
        final petsAsync = ref.read(petProfilesProvider);
        if (petsAsync.isLoading || petsAsync.hasError) return;

        final pets = petsAsync.asData?.value ?? [];
        _controller.searchWithCategoryAndUserInput(
          _tabController.index,
          userInput,
          pets,
        );
      }
    });
  }

  /// 生食材料を追加
  void _addRawFoodIngredient(String ingredient) {
    if (ingredient.isNotEmpty && !_rawFoodIngredients.contains(ingredient)) {
      setState(() {
        _rawFoodIngredients.add(ingredient);
      });
      _searchController.clear();
    }
  }

  /// 生食材料を削除
  void _removeRawFoodIngredient(int index) {
    setState(() {
      _rawFoodIngredients.removeAt(index);
    });
  }
}

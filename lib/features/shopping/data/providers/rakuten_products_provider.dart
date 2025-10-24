import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/rakuten_pet_product_model.dart';
import '../services/rakuten_api_service.dart';

part 'rakuten_products_provider.g.dart';

/// ラクテン商品検索状態
class RakutenProductsState {
  final List<RakutenPetProduct> products;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String currentKeyword;
  final String currentSort;
  final List<Map<String, dynamic>> petTags;
  final List<String> selectedTagIds;
  final bool isLoadingTags;

  const RakutenProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.currentKeyword = 'ペット',
    this.currentSort = 'standard',
    this.petTags = const [],
    this.selectedTagIds = const [],
    this.isLoadingTags = false,
  });

  RakutenProductsState copyWith({
    List<RakutenPetProduct>? products,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? currentKeyword,
    String? currentSort,
    List<Map<String, dynamic>>? petTags,
    List<String>? selectedTagIds,
    bool? isLoadingTags,
  }) {
    return RakutenProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      currentKeyword: currentKeyword ?? this.currentKeyword,
      currentSort: currentSort ?? this.currentSort,
      petTags: petTags ?? this.petTags,
      selectedTagIds: selectedTagIds ?? this.selectedTagIds,
      isLoadingTags: isLoadingTags ?? this.isLoadingTags,
    );
  }
}

/// ラクテン商品検索コントローラー
@riverpod
class RakutenProductsNotifier extends _$RakutenProductsNotifier {
  @override
  RakutenProductsState build() {
    return const RakutenProductsState();
  }

  final RakutenApiService _apiService = RakutenApiService();

  /// ペット商品を検索
  Future<void> searchPetProducts({
    String? keyword,
    String? sort,
    bool reset = true,
  }) async {
    if (reset) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        products: [],
        currentPage: 1,
        hasMore: true,
        currentKeyword: keyword ?? state.currentKeyword,
        currentSort: sort ?? state.currentSort,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final products = await _apiService.searchPetProducts(
        keyword: keyword ?? state.currentKeyword,
        page: state.currentPage,
        hits: 30,
        sort: state.currentSort,
      );

      state = state.copyWith(
        isLoading: false,
        products: reset ? products : [...state.products, ...products],
        hasMore: products.length == 30,
        currentPage: reset ? 2 : state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// ペットフードを検索
  Future<void> searchPetFood({bool reset = true}) async {
    if (reset) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        products: [],
        currentPage: 1,
        hasMore: true,
        currentKeyword: 'ペットフード',
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final products = await _apiService.searchPetFood(
        page: state.currentPage,
        hits: 30,
        sort: state.currentSort,
      );

      state = state.copyWith(
        isLoading: false,
        products: reset ? products : [...state.products, ...products],
        hasMore: products.length == 30,
        currentPage: reset ? 2 : state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// ペット用品を検索
  Future<void> searchPetSupplies({bool reset = true}) async {
    if (reset) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        products: [],
        currentPage: 1,
        hasMore: true,
        currentKeyword: 'ペット用品',
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final products = await _apiService.searchPetSupplies(
        page: state.currentPage,
        hits: 30,
        sort: state.currentSort,
      );

      state = state.copyWith(
        isLoading: false,
        products: reset ? products : [...state.products, ...products],
        hasMore: products.length == 30,
        currentPage: reset ? 2 : state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 犬用品を検索
  Future<void> searchDogProducts({bool reset = true}) async {
    if (reset) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        products: [],
        currentPage: 1,
        hasMore: true,
        currentKeyword: '犬用品',
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final products = await _apiService.searchDogItems(
        page: state.currentPage,
        hits: 30,
        sort: state.currentSort,
      );

      state = state.copyWith(
        isLoading: false,
        products: reset ? products : [...state.products, ...products],
        hasMore: products.length == 30,
        currentPage: reset ? 2 : state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 猫用品を検索
  Future<void> searchCatProducts({bool reset = true}) async {
    if (reset) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        products: [],
        currentPage: 1,
        hasMore: true,
        currentKeyword: '猫用品',
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final products = await _apiService.searchCatItems(
        page: state.currentPage,
        hits: 30,
        sort: state.currentSort,
      );

      state = state.copyWith(
        isLoading: false,
        products: reset ? products : [...state.products, ...products],
        hasMore: products.length == 30,
        currentPage: reset ? 2 : state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 価格帯で検索
  Future<void> searchByPriceRange({
    required int minPrice,
    required int maxPrice,
    bool reset = true,
  }) async {
    if (reset) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        products: [],
        currentPage: 1,
        hasMore: true,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final products = await _apiService.searchPetProductsByPrice(
        minPrice: minPrice,
        maxPrice: maxPrice,
        keyword: state.currentKeyword,
        page: state.currentPage,
        hits: 30,
        sort: state.currentSort,
      );

      state = state.copyWith(
        isLoading: false,
        products: reset ? products : [...state.products, ...products],
        hasMore: products.length == 30,
        currentPage: reset ? 2 : state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// レビュー順で検索
  Future<void> searchByReview({bool reset = true}) async {
    await searchPetProducts(sort: '-reviewCount', reset: reset);
  }

  /// 価格安い順で検索
  Future<void> searchByPriceLow({bool reset = true}) async {
    await searchPetProducts(sort: '+itemPrice', reset: reset);
  }

  /// 価格高い順で検索
  Future<void> searchByPriceHigh({bool reset = true}) async {
    await searchPetProducts(sort: '-itemPrice', reset: reset);
  }

  /// 次のページを読み込み
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    await searchPetProducts(reset: false);
  }

  /// エラーをクリア
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// ペットタグを読み込み
  Future<void> loadPetTags() async {
    if (state.petTags.isNotEmpty) return; // 既に読み込み済み

    state = state.copyWith(isLoadingTags: true);

    try {
      final tags = await _apiService.searchPetTags();
      state = state.copyWith(petTags: tags, isLoadingTags: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingTags: false,
        error: 'Failed to load tags: $e',
      );
    }
  }

  /// タグを選択/選択解除
  void toggleTag(String tagId) {
    final currentSelectedTags = List<String>.from(state.selectedTagIds);

    if (currentSelectedTags.contains(tagId)) {
      currentSelectedTags.remove(tagId);
    } else {
      currentSelectedTags.add(tagId);
    }

    state = state.copyWith(selectedTagIds: currentSelectedTags);
  }

  /// タグで商品を検索
  Future<void> searchByTags({List<String>? tagIds, bool reset = true}) async {
    final tagsToSearch = tagIds ?? state.selectedTagIds;
    if (tagsToSearch.isEmpty) return;

    if (reset) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        products: [],
        currentPage: 1,
        hasMore: true,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      // タグIDをカンマ区切りで結合 (将来的に使用予定)
      // ignore: unused_local_variable
      final tagIdString = tagsToSearch.join(',');
      final products = await _apiService.searchPetProducts(
        keyword: state.currentKeyword,
        page: state.currentPage,
        hits: 30,
        sort: state.currentSort,
      );

      state = state.copyWith(
        isLoading: false,
        products: reset ? products : [...state.products, ...products],
        hasMore: products.length == 30,
        currentPage: reset ? 2 : state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 状態をリセット
  void reset() {
    state = const RakutenProductsState();
  }
}

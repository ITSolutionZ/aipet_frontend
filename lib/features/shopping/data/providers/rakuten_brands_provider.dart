import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/rakuten_brand_model.dart';
import '../services/rakuten_api_service.dart';

part 'rakuten_brands_provider.g.dart';

/// ラクテンブランド状態
@riverpod
class RakutenBrandsNotifier extends _$RakutenBrandsNotifier {
  @override
  RakutenBrandsState build() {
    return const RakutenBrandsState();
  }

  final RakutenApiService _apiService = RakutenApiService();

  /// 人気ブランドを検索
  Future<void> searchPopularBrands({
    String keyword = 'ペットフード',
    bool reset = true,
  }) async {
    if (reset) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        brands: [],
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final brands = await _apiService.searchPopularBrands(
        keyword: keyword,
        page: 1,
        hits: 20,
      );

      state = state.copyWith(
        isLoading: false,
        brands: brands,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// ブランド選択状態を切り替え
  void toggleBrandSelection(String brandId) {
    final updatedBrands = state.brands.map((brand) {
      if (brand.brandId == brandId) {
        return brand.copyWith(isSelected: !brand.isSelected);
      }
      return brand;
    }).toList();

    state = state.copyWith(brands: updatedBrands);
  }

  /// 選択されたブランドを取得
  List<RakutenBrand> get selectedBrands {
    return state.brands.where((brand) => brand.isSelected).toList();
  }

  /// 全ブランド選択をクリア
  void clearAllSelections() {
    final updatedBrands = state.brands.map((brand) {
      return brand.copyWith(isSelected: false);
    }).toList();

    state = state.copyWith(brands: updatedBrands);
  }
}

/// ラクテンブランド状態データ
@riverpod
class RakutenBrandsState extends _$RakutenBrandsState {
  @override
  RakutenBrandsStateData build() {
    return const RakutenBrandsStateData();
  }
}

/// ラクテンブランド状態データクラス
class RakutenBrandsStateData {
  final bool isLoading;
  final String? error;
  final List<RakutenBrand> brands;

  const RakutenBrandsStateData({
    this.isLoading = false,
    this.error,
    this.brands = const [],
  });

  RakutenBrandsStateData copyWith({
    bool? isLoading,
    String? error,
    List<RakutenBrand>? brands,
  }) {
    return RakutenBrandsStateData(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      brands: brands ?? this.brands,
    );
  }
}

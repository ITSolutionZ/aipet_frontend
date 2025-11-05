import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
import '../../../../app/controllers/base_controller.dart';
import '../../../../../features/shopping/shopping.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';
import '../utils/pet_category_mapper.dart';


/// アレルギー商品選択コントローラー
///
/// 商品検索、選択、生食材料管理のビジネスロジックを担当
class AllergyProductSelectionController extends BaseController {
  final String petId;
  final bool hasAllergy;

  AllergyProductSelectionController(
    super.ref, {
    required this.petId,
    required this.hasAllergy,
  });

  /// ペットタイプとタブに基づいて商品をロード
  void loadProductsForPetAndCategory(int tabIndex, List<PetProfileEntity> pets) {
    if (pets.isEmpty) return;

    final selectedPet = pets.firstWhere(
      (pet) => pet.id == petId,
      orElse: () => pets.first,
    );

    final petType = PetCategoryMapper.getPetType(selectedPet);
    final category = PetCategoryMapper.getCategoryByTabIndex(
      tabIndex,
      petType,
    );

    // ペット専用検索キーワード生成
    final searchKeyword = PetCategoryMapper.createPetSpecificKeyword(
      petType,
      category,
    );

    final notifier = ref.read(rakutenProductsProvider.notifier);
    notifier.searchPetProducts(keyword: searchKeyword);
  }

  /// カテゴリとユーザー入力を結合して検索
  void searchWithCategoryAndUserInput(
    int tabIndex,
    String userInput,
    List<PetProfileEntity> pets,
  ) {
    if (pets.isEmpty) return;

    final selectedPet = pets.firstWhere(
      (pet) => pet.id == petId,
      orElse: () => pets.first,
    );

    final petType = PetCategoryMapper.getPetType(selectedPet);
    final category = PetCategoryMapper.getCategoryByTabIndex(
      tabIndex,
      petType,
    );

    // アレルギー確認用なので食べ物商品のみ検索 (用品除外)
    final combinedKeyword = '$category $userInput';

    final notifier = ref.read(rakutenProductsProvider.notifier);
    notifier.searchPetProducts(keyword: combinedKeyword);
  }

  /// 楽天商品を選択/解除
  void selectRakutenProduct(
    BuildContext context,
    RakutenPetProduct rakutenProduct,
    int tabIndex,
    Set<String> selectedProductIds,
    Function(Set<String>) updateSelectedIds,
    List<PetProfileEntity> pets,
  ) {
    final isAlreadySelected = selectedProductIds.contains(
      rakutenProduct.itemCode,
    );

    if (pets.isEmpty) return;

    final selectedPet = pets.firstWhere(
      (pet) => pet.id == petId,
      orElse: () => pets.first,
    );

    final petType = PetCategoryMapper.getPetType(selectedPet);
    final category = PetCategoryMapper.getCategoryByTabIndex(
      tabIndex,
      petType,
    );

    // Rakuten商品をProductEntityに変換
    final product = ProductEntity(
      id: rakutenProduct.itemCode,
      name: rakutenProduct.itemName,
      category: category,
      price: rakutenProduct.itemPrice.toInt(),
      brandId: rakutenProduct.shopCode,
      ingredients: rakutenProduct.itemCaption, // 商品説明を成分として一時使用
      imageUrl: rakutenProduct.imageUrl,
    );

    if (isAlreadySelected) {
      // すでに選択された商品なら選択解除
      ref
          .read(selectedAllergyProductsProvider.notifier)
          .removeProduct(petId, product.id, hasAllergy);

      final newSelectedIds = Set<String>.from(selectedProductIds)
        ..remove(product.id);
      updateSelectedIds(newSelectedIds);

      final message =
          hasAllergy ? 'アレルギー商品から削除しました' : 'アレルギーなし商品から削除しました';

      SnackBarService.showInfo(
        context,
        message,
        duration: const Duration(seconds: 2),
      );
    } else {
      // 選択されていない商品なら選択
      ref
          .read(selectedAllergyProductsProvider.notifier)
          .addProduct(petId, product, hasAllergy);

      final newSelectedIds = Set<String>.from(selectedProductIds)
        ..add(product.id);
      updateSelectedIds(newSelectedIds);

      final message =
          hasAllergy ? 'アレルギー商品に追加しました' : 'アレルギーなし商品に追加しました';

      // 既存スナックバーを削除後、新しいスナックバーを表示
      ScaffoldMessenger.of(context).clearSnackBars();
      SnackBarService.showSuccess(
        context,
        message,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// 生食食材を選択 (アレルギー/非アレルギーに追加)
  void selectRawFoodIngredient(BuildContext context, String ingredient) {
    // 生食材料をProductEntityに変換
    final product = ProductEntity(
      id: 'raw_food_${ingredient}_${DateTime.now().millisecondsSinceEpoch}',
      name: ingredient,
      category: '生食',
      price: 0,
      brandId: 'raw_food',
      ingredients: ingredient,
      imageUrl: null, // 生食材料は画像なし
    );

    // Providerに商品追加
    ref
        .read(selectedAllergyProductsProvider.notifier)
        .addProduct(petId, product, hasAllergy);

    final message = hasAllergy
        ? 'アレルギー食材に追加しました: $ingredient'
        : 'アレルギーなし食材に追加しました: $ingredient';

    // 既存スナックバーを削除後、新しいスナックバーを表示
    ScaffoldMessenger.of(context).clearSnackBars();
    SnackBarService.showInfo(
      context,
      message,
      duration: const Duration(seconds: 2),
    );
  }
}

import '../../../../shared/domain/entities/pet_profile_entity.dart';

/// ペットタイプとカテゴリのマッピングユーティリティ
///
/// ペットの品種からタイプを判定し、適切なカテゴリを返す
class PetCategoryMapper {
  /// ペットタイプを判定 (品種から)
  ///
  /// [pet] ペットエンティティ
  /// 戻り値: 'ドッグ', 'キャット', 'ウサギ', '鳥', 'ハムスター'
  static String getPetType(PetProfileEntity pet) {
    final breed = pet.breed?.toLowerCase() ?? '';

    if (_isDog(breed)) return 'ドッグ';
    if (_isCat(breed)) return 'キャット';
    if (_isRabbit(breed)) return 'ウサギ';
    if (_isBird(breed)) return '鳥';
    if (_isHamster(breed)) return 'ハムスター';

    // デフォルト: 犬
    return 'ドッグ';
  }

  /// フードカテゴリを取得
  static String getFoodCategory(String petType) {
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

  /// サプリメントカテゴリを取得
  static String getSupplementCategory(String petType) {
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

  /// おやつカテゴリを取得
  static String getSnackCategory(String petType) {
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

  /// 生食カテゴリを取得
  static String getRawFoodCategory(String petType) {
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

  /// タブインデックスからカテゴリ名を取得
  ///
  /// [tabIndex] タブインデックス (0: フード, 1: サプリ, 2: おやつ, 3: 生食)
  /// [petType] ペットタイプ
  static String getCategoryByTabIndex(int tabIndex, String petType) {
    switch (tabIndex) {
      case 0:
        return getFoodCategory(petType);
      case 1:
        return getSupplementCategory(petType);
      case 2:
        return getSnackCategory(petType);
      case 3:
        return getRawFoodCategory(petType);
      default:
        return getFoodCategory(petType);
    }
  }

  /// ペット専用検索キーワードを生成
  static String createPetSpecificKeyword(String petType, String category) {
    // うさぎ、鳥、ハムスターなどは専用キーワードを使用
    if (petType == 'ウサギ' || petType == '鳥' || petType == 'ハムスター') {
      return category; // すでにペットタイプ別カテゴリなのでそのまま使用
    }

    // 犬/猫は既存方式を維持 (互換性)
    return '$petType $category';
  }

  // ===== ペットタイプ判定ヘルパーメソッド =====

  /// 犬品種判定
  static bool _isDog(String breed) {
    const dogBreeds = [
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

    return dogBreeds.any((dogBreed) => breed.contains(dogBreed));
  }

  /// 猫品種判定
  static bool _isCat(String breed) {
    const catBreeds = [
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

    return catBreeds.any((catBreed) => breed.contains(catBreed));
  }

  /// うさぎ品種判定
  static bool _isRabbit(String breed) {
    const rabbitBreeds = [
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

    return rabbitBreeds.any((rabbitBreed) => breed.contains(rabbitBreed));
  }

  /// 鳥品種判定
  static bool _isBird(String breed) {
    const birdBreeds = [
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

    return birdBreeds.any((birdBreed) => breed.contains(birdBreed));
  }

  /// ハムスター品種判定
  static bool _isHamster(String breed) {
    const hamsterBreeds = [
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

    return hamsterBreeds.any((hamsterBreed) => breed.contains(hamsterBreed));
  }

  /// タブインデックスから検索ヒントテキストを取得
  static String getSearchHint(int tabIndex) {
    switch (tabIndex) {
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
}

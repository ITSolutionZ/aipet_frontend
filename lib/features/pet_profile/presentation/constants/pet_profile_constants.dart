import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// Pet Profile UI Constants
///
/// Pet Profile 기능의 UI 관련 상수들 (공통 상수 사용)

class PetProfileConstants {
  PetProfileConstants._();

  // UI Dimensions (공통 상수 사용)
  static const double profileImageSize = AppConstants.profileImageSize;
  static const double profileImageRadius = AppConstants.profileImageRadius;
  static const double cardElevation = AppConstants.defaultCardElevation;
  static const double buttonHeight = AppConstants.defaultButtonHeight;
  static const double iconSize = AppConstants.defaultIconSize;

  // Spacing (공통 상수 사용)
  static const EdgeInsets defaultPadding = AppConstants.defaultPadding;
  static const EdgeInsets cardPadding = AppConstants.cardPadding;
  static const EdgeInsets buttonPadding = AppConstants.buttonPadding;
  static const double defaultSpacing = AppConstants.spacingMD;
  static const double smallSpacing = AppConstants.spacingSM;
  static const double largeSpacing = AppConstants.spacingLG;

  // Animation Durations (공통 상수 사용)
  static const Duration defaultAnimation = AppConstants.defaultAnimation;
  static const Duration fastAnimation = AppConstants.fastAnimation;
  static const Duration slowAnimation = AppConstants.slowAnimation;

  // Text Styles Keys
  static const String profileNameStyle = 'profileName';
  static const String profileDetailStyle = 'profileDetail';
  static const String sectionHeaderStyle = 'sectionHeader';
  static const String bodyTextStyle = 'bodyText';

  // Form Validation (공통 상수 사용)
  static const int maxNameLength = AppConstants.maxNameLength;
  static const int minNameLength = AppConstants.minNameLength;
  static const double maxWeight = AppConstants.maxWeight;
  static const double minWeight = AppConstants.minWeight;

  // Share Settings (공통 상수 사용)
  static const int maxFamilyManagers = AppConstants.maxFamilyManagers;
  static const Duration defaultLinkExpiry = AppConstants.defaultLinkExpiry;

  // Image Upload (공통 상수 사용)
  static const int maxImageSizeMB = AppConstants.maxImageSizeMB;
  static const List<String> allowedImageTypes = AppConstants.allowedImageTypes;

  // Tab Names (Japanese)
  static const String basicInfoTab = '基本情報';
  static const String healthTab = '健康';
  static const String nutritionTab = '栄養';
  static const String shareTab = '共有';

  // Button Texts (Japanese)
  static const String editButton = '編集';
  static const String saveButton = '保存';
  static const String cancelButton = 'キャンセル';
  static const String shareButton = '共有';
  static const String deleteButton = '削除';
  static const String addButton = '追加';

  // Status Messages (Japanese)
  static const String saveSuccess = '保存されました';
  static const String saveError = '保存に失敗しました';
  static const String loadError = '読み込みに失敗しました';
  static const String noDataMessage = 'データがありません';
  static const String accessDeniedMessage = 'アクセスが拒否されました';

  // Validation Messages (Japanese)
  static const String nameRequiredMessage = '名前を入力してください';
  static const String nameTooLongMessage = '名前は50文字以内で入力してください';
  static const String invalidWeightMessage = '体重は0.1kg以上200kg以下で入力してください';
  static const String futureBirthDateMessage = '生年月日は未来の日付を設定できません';

  // Color Keys
  static const String primaryColor = 'primary';
  static const String secondaryColor = 'secondary';
  static const String errorColor = 'error';
  static const String successColor = 'success';
  static const String warningColor = 'warning';

  // Feature Flags
  static const bool enableAdvancedHealthTracking = false;
  static const bool enableSocialSharing = true;
  static const bool enableOfflineMode = false;

  // API Endpoints (for future use)
  static const String profileEndpoint = '/api/pet-profiles';
  static const String imageUploadEndpoint = '/api/pet-profiles/images';
  static const String shareEndpoint = '/api/pet-profiles/share';
}

/// Pet Profile Screen Routes
class PetProfileRoutes {
  PetProfileRoutes._();

  static const String profile = '/pet-profile';
  static const String edit = '/pet-profile/edit';
  static const String share = '/pet-profile/share';
  static const String qrScanner = '/pet-profile/qr-scanner';
  static const String linkRegistration = '/pet-profile/link-registration';
  static const String vaccine = '/pet-profile/vaccine';
  static const String sharingProfiles = '/pet-profile/sharing-profiles';
}

/// Pet Type Icons and Display Names
class PetTypeConstants {
  PetTypeConstants._();

  static const Map<String, String> typeIcons = {
    'dog': '🐕',
    'cat': '🐱',
    'bird': '🐦',
    'hamster': '🐹',
    'rabbit': '🐰',
    'turtle': '🐢',
  };

  static const Map<String, String> typeNames = {
    'dog': '犬',
    'cat': '猫',
    'bird': '鳥',
    'hamster': 'ハムスター',
    'rabbit': 'うさぎ',
    'turtle': '亀',
  };

  static String getIcon(String type) => typeIcons[type.toLowerCase()] ?? '🐾';
  static String getName(String type) => typeNames[type.toLowerCase()] ?? 'ペット';
}

/// Visibility Level Display
class VisibilityLevelConstants {
  VisibilityLevelConstants._();

  static const Map<String, String> levelNames = {
    'private': '非公開',
    'family': '家族のみ',
    'public': '公開',
  };

  static const Map<String, IconData> levelIcons = {
    'private': Icons.lock,
    'family': Icons.family_restroom,
    'public': Icons.public,
  };

  static String getName(String level) => levelNames[level.toLowerCase()] ?? '非公開';
  static IconData getIcon(String level) => levelIcons[level.toLowerCase()] ?? Icons.lock;
}

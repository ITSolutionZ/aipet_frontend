import 'package:flutter/material.dart';

/// Pet Profile UI Constants
///
/// Pet Profile 기능의 UI 관련 상수들

class PetProfileConstants {
  PetProfileConstants._();

  // UI Dimensions
  static const double profileImageSize = 120.0;
  static const double profileImageRadius = 60.0;
  static const double cardElevation = 4.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;

  // Spacing
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(12.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);
  static const double defaultSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;

  // Animation Durations
  static const Duration defaultAnimation = Duration(milliseconds: 300);
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Text Styles Keys
  static const String profileNameStyle = 'profileName';
  static const String profileDetailStyle = 'profileDetail';
  static const String sectionHeaderStyle = 'sectionHeader';
  static const String bodyTextStyle = 'bodyText';

  // Form Validation
  static const int maxNameLength = 50;
  static const int minNameLength = 1;
  static const double maxWeight = 200.0;
  static const double minWeight = 0.1;

  // Share Settings
  static const int maxFamilyManagers = 5;
  static const Duration defaultLinkExpiry = Duration(days: 30);

  // Image Upload
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageTypes = ['.jpg', '.jpeg', '.png'];

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
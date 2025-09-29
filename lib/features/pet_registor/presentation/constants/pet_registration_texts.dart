import 'package:aipet_frontend/shared/shared.dart';

/// 펫 등록 관련 UI 텍스트 상수
///
/// 일본어 UI 텍스트를 중앙 관리하여 일관성과 유지보수성을 향상시킵니다.
class PetRegistrationTexts {
  // 화면 제목
  static const String petTypeSelection = 'ペットの種類を選択';
  static const String whoDoYouLiveWith = '今、誰と暮らしていますか?';
  static const String whatKindOfPet = 'どんな子ですか？';
  static const String enterName = '名前を教えてください';
  static const String petAnniversary = 'ペットとの記念日は？';
  static const String petAnniversarySummary = 'ペットの記念日は？';
  static const String petSizeWeight = 'ペットのサイズと体重は？';
  static const String registrationComplete = '登録完了';

  // 버튼 텍스트 (공통 텍스트 사용)
  static const String next = AppTexts.next;
  static const String back = AppTexts.back;
  static const String complete = AppTexts.complete;
  static const String cancel = AppTexts.cancel;
  static const String save = AppTexts.save;
  static const String noTypeAvailable = '種類がない';
  static const String customPetTypeComingSoon = 'カスタムペットタイプの機能は準備中です';

  // 입력 필드 관련 (공통 텍스트 사용)
  static const String nameHint = 'ペットの名前を入力してください';
  static const String nameRequired = AppTexts.requiredField;
  static const String nameMinLength = AppTexts.tooShort;
  static const String nameMaxLength = AppTexts.tooLong;

  // 펫 타입
  static const String dog = '犬';
  static const String cat = '猫';
  static const String bird = '鳥';
  static const String hamster = 'ハムスター';
  static const String rabbit = 'うさぎ';
  static const String turtle = '亀';

  // 에러 메시지 (공통 텍스트 사용)
  static const String networkError = AppTexts.networkError;
  static const String unknownError = AppTexts.unknownError;
  static const String petNotFound = AppTexts.petNotFound;
  static const String registrationFailed = 'ペットの登録に失敗しました';

  // 성공 메시지 (공통 텍스트 사용)
  static const String registrationSuccess = AppTexts.petRegistered;
  static const String updateSuccess = AppTexts.petUpdated;
  static const String deleteSuccess = AppTexts.petDeleted;

  // 진행 상태 (공통 텍스트 사용)
  static const String loading = AppTexts.loading;
  static const String saving = AppTexts.saving;
  static const String processing = AppTexts.processing;

  // Private constructor to prevent instantiation
  PetRegistrationTexts._();
}

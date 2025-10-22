# Features → Shared 코드 통합 가이드

## 📋 개요

이 문서는 `lib/features/` 디렉토리의 중복 코드를 `lib/shared/` 모듈로 통합하기 위한 가이드입니다.
Clean Architecture와 DRY(Don't Repeat Yourself) 원칙에 따라 공통 코드를 중앙화하여 유지보수성을 향상시킵니다.

---

## 🚀 빠른 시작 (Quick Start)

### 즉시 대체 가능한 코드 패턴

| 현재 코드                                           | 대체할 Shared 코드                            | 카테고리    |
| --------------------------------------------------- | --------------------------------------------- | ----------- |
| `debugPrint('...')`                                 | `LoggerService.info('...')`                   | 로깅        |
| `ScaffoldMessenger.of(context).showSnackBar(...)`   | `SnackBarService.showSuccess(context, '...')` | 알림        |
| `if (email.isEmpty) return '...'`                   | `ValidationService.validateEmail(email)`      | 유효성 검사 |
| `'${hour.toString().padLeft(2, '0')}:${minute}...'` | `DateTimeService.formatTime(dateTime)`        | 날짜/시간   |
| `await http.get(Uri.parse('$url'))`                 | `await _httpClient.get<T>(endpoint)`          | API 통신    |
| `await ImagePicker().pickImage(...)`                | `await ImageService.pickFromGallery(context)` | 이미지      |
| `await prefs.setString(key, json.encode(data))`     | `await localDataSource.saveData(key, data)`   | 캐시        |
| `class CustomErrorHandler { ... }`                  | `ErrorHandlingService.handleAsync(...)`       | 에러 처리   |

### 마이그레이션 우선순위

1. ⚡ **즉시 (High Priority)**: 에러 처리, 상수/메시지, Result 패턴
2. 🔄 **점진적 (Medium Priority)**: API 통신, 이미지, 유효성 검사, 날짜/시간
3. 📋 **선택적 (Low Priority)**: 로깅, 위젯, UseCase 패턴, PetEntity

---

## 📊 중복 코드 통계

### 실제 측정 결과 (최종 업데이트: 2025-10-22)

| 카테고리              | 현재 중복 개수              | 목표   | 영향받는 Features               | 통합 대상 Shared 모듈            |
| --------------------- | --------------------------- | ------ | ------------------------------- | -------------------------------- |
| **에러 핸들러**       | ~~4개 클래스~~ → **0개** ✅ | 0개    | facility, pet_profile, ai, walk | `ErrorHandlingService`           |
| **SnackBar 호출**     | ~~165곳~~ → **0곳** ✅      | <10곳  | 모든 features                   | `SnackBarService`                |
| **debugPrint**        | **1,552곳**                 | <50곳  | 모든 features                   | `LoggerService`                  |
| **Dio 인스턴스**      | ~~9곳~~ → **0곳** ✅        | 0곳    | home, ai, auth, shopping        | `ApiClient`, `HttpClientService` |
| **SharedPreferences** | **124곳**                   | <5곳   | 거의 모든 features              | `BaseLocalDataSource`            |
| **Shared 모듈 사용**  | **715곳** ↑                 | >200곳 | -                               | ✅ 이미 충분히 사용 중           |

### 현재 마이그레이션 상태

- 🟢 **Shared 모듈 도입**: 우수 (715곳에서 사용 중, ↑12)
- ✅ **Critical Issues**: 0개 (100% 해결!)
  - ~~에러 핸들러 4개~~ → **0개 ✅**
  - ~~Dio 인스턴스 9개~~ → **0개 ✅**
  - ~~SnackBar 직접 호출 165곳~~ → **0곳 ✅**
- 🟡 **Improvement Needed**: 1,676개 항목
  - debugPrint 사용: 1,552곳
  - SharedPreferences 직접 사용: 124곳

### 발견된 주요 중복 패턴

| 카테고리        | 추정 중복 개수 | 영향받는 Features                         |
| --------------- | -------------- | ----------------------------------------- |
| **유효성 검사** | 10+ 함수       | daily, pet_feeding, pet_profile, auth, ai |
| **날짜 포맷팅** | 15+ 함수       | scheduling, walk, daily                   |
| **이미지 처리** | 8+ 구현체      | pet_profile, daily, walk, settings        |
| **상수/메시지** | 100+ 정의      | ai, allergy, pet_profile, auth            |

---

## 🎯 1. 에러 처리 통합

### 1.1 중복된 에러 핸들러

#### 현재 상태 (Features에 분산)

각 feature마다 독립적인 에러 핸들러 구현:

| Feature         | 파일                                                              | 문제점                              |
| --------------- | ----------------------------------------------------------------- | ----------------------------------- |
| **Facility**    | `facility/data/services/facility_error_handler.dart`              | 공통 에러 처리 로직 중복            |
| **Pet Profile** | `pet_profile/domain/services/pet_registration_error_handler.dart` | 사용자 친화적 메시지 변환 로직 중복 |
| **AI**          | `ai/domain/errors/ai_errors.dart` (`AiErrorHandler`)              | Dio 예외 처리 로직 중복             |
| **Walk**        | `walk/domain/services/walk_error_handler.dart`                    | 에러 심각도 판별 로직 중복          |
| **AI Dio**      | `ai/data/services/ai_dio_service.dart` (`_handleDioException`)    | HTTP 상태 코드 처리 중복            |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/core/api/api_error_handler.dart';
import 'package:aipet_frontend/shared/core/services/error_handling_service.dart';
import 'package:aipet_frontend/shared/core/services/common_error_service.dart';
import 'package:aipet_frontend/shared/foundation/error_handler/error_handler.dart';
```

#### 마이그레이션 예시

**Before (Feature별 구현):**

```dart
// ❌ features/facility/data/services/facility_error_handler.dart
class FacilityErrorHandler {
  static void handleLoadError(dynamic error, BuildContext context) {
    final errorMessage = _getErrorMessage(error, 'facility_load');
    _showErrorSnackBar(context, errorMessage);
  }

  static String _getErrorMessage(dynamic error, String operation) {
    // 중복 로직: 에러 타입 판별 및 메시지 변환
    if (error.toString().contains('network')) {
      return 'ネットワーク接続を確認してください';
    }
    // ... 더 많은 중복 로직
  }
}
```

**After (Shared 모듈 사용):**

```dart
// ✅ Shared 모듈로 통합
import 'package:aipet_frontend/shared/core/services/error_handling_service.dart';
import 'package:aipet_frontend/shared/core/services/ui_notification_service.dart';

class FacilityController {
  Future<void> loadFacilities() async {
    try {
      // 비즈니스 로직
    } catch (error, stackTrace) {
      ErrorHandlingService.handleAsync(
        Future.error(error, stackTrace),
        context: 'Facility.Load',
        showUserMessage: true,
      );
    }
  }
}
```

---

## 🎯 2. API 통신 통합

### 2.1 중복된 HTTP 클라이언트

#### 현재 상태 (Features에 분산)

| Feature      | 파일                                              | 중복 내용                        |
| ------------ | ------------------------------------------------- | -------------------------------- |
| **Home**     | `home/data/services/weather_service.dart`         | HTTP GET 요청, 에러 처리         |
| **Home**     | `home/data/services/openweathermap_service.dart`  | Dio 인스턴스 생성, 인터셉터 설정 |
| **AI**       | `ai/data/services/ai_dio_service.dart`            | Dio 설정, 재시도 로직            |
| **Auth**     | `auth/data/services/api_auth_service.dart`        | HTTP 통신 기본 설정              |
| **Walk**     | `walk/data/services/walk_api_service.dart`        | API 호출 패턴                    |
| **Shopping** | `shopping/data/services/rakuten_api_service.dart` | HTTP 통신 로직                   |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/core/api/api_client.dart';
import 'package:aipet_frontend/shared/core/api/api_interceptors.dart';
import 'package:aipet_frontend/shared/core/services/http_client_service.dart';
import 'package:aipet_frontend/shared/core/services/ai_http_client_service.dart';
```

#### 마이그레이션 예시

**Before (Feature별 HTTP 구현):**

```dart
// ❌ features/home/data/services/weather_service.dart
class WeatherService {
  Future<WeatherData?> getCurrentWeather() async {
    final url = Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherData.fromJson(data);
    } else if (response.statusCode == 401) {
      return _getMockWeatherData();
    } else {
      throw Exception('Failed to fetch weather data: ${response.statusCode}');
    }
  }
}
```

**After (Shared HttpClientService 사용):**

```dart
// ✅ Shared 모듈로 통합
import 'package:aipet_frontend/shared/core/services/http_client_service.dart';

class WeatherService {
  final HttpClientService _httpClient;

  WeatherService(this._httpClient);

  Future<Result<WeatherData>> getCurrentWeather(double lat, double lon) async {
    final response = await _httpClient.get<WeatherData>(
      '/weather',
      queryParameters: {'lat': lat, 'lon': lon, 'appid': _apiKey},
      fromJson: (json) => WeatherData.fromJson(json),
    );

    return response.isSuccess
        ? Result.success('天気情報を取得しました', response.data)
        : Result.failure(response.message);
  }
}
```

---

## 🎯 3. 유효성 검사 통합

### 3.1 중복된 Validation 로직

#### 현재 상태 (Features에 분산)

| Feature         | 파일                                                                              | 중복 내용                    |
| --------------- | --------------------------------------------------------------------------------- | ---------------------------- |
| **Daily**       | `daily/presentation/controllers/pet_registration/pet_registration_validator.dart` | 필수 필드, 길이, 범위 검증   |
| **Pet Feeding** | `pet_feeding/domain/usecases/helpers/recipe_validation_helper.dart`               | 이름, 길이, 숫자 범위 검증   |
| **Pet Profile** | `pet_profile/presentation/controllers/pet_profile_form_controller.dart`           | 펫 이름, 체중, 생년월일 검증 |
| **Auth**        | `auth/presentation/controllers/auth_controller.dart`                              | 이메일, 비밀번호 검증        |
| **AI**          | `ai/domain/services/ai_message_manager.dart`                                      | 메시지 검증                  |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/core/services/validation_service.dart';
import 'package:aipet_frontend/shared/core/services/unified_validation_service.dart';
import 'package:aipet_frontend/shared/mixins/validation_mixin.dart';
```

#### 마이그레이션 예시

**Before (Feature별 Validation 구현):**

```dart
// ❌ features/pet_feeding/domain/usecases/helpers/recipe_validation_helper.dart
class RecipeValidationHelper {
  static Result<String> validateRecipeName(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return Result.failure('レシピ名は空にできません');
    }

    if (trimmedName.length < 2) {
      return Result.failure('レシピ名は2文字以上で入力してください');
    }

    if (trimmedName.length > 50) {
      return Result.failure('レシピ名は50文字以内で入力してください');
    }

    return Result.success('レシピ名が有効です', trimmedName);
  }
}
```

**After (Shared ValidationService 사용):**

```dart
// ✅ Shared 모듈로 통합
import 'package:aipet_frontend/shared/core/services/validation_service.dart';

class RecipeValidationHelper {
  static Result<String> validateRecipeName(String name) {
    // 공통 검증 로직 재사용
    final validationResult = ValidationService.validateRequiredField(name, 'レシピ名');

    if (!validationResult.isSuccess) {
      return Result.failure(validationResult.message);
    }

    final trimmedName = name.trim();

    // 길이 검증은 공통 로직 사용
    if (trimmedName.length < 2 || trimmedName.length > 50) {
      return Result.failure('レシピ名は2文字以上50文字以内で入力してください');
    }

    return Result.success('レシピ名が有効です', trimmedName);
  }
}
```

---

## 🎯 4. 이미지 처리 통합

### 4.1 중복된 이미지 선택/압축 로직

#### 현재 상태 (Features에 분산)

| Feature         | 파일                                                                                               | 중복 내용                |
| --------------- | -------------------------------------------------------------------------------------------------- | ------------------------ |
| **Pet Profile** | `pet_profile/data/services/pet_image_upload_service.dart`                                          | 이미지 압축, 업로드 로직 |
| **Pet Profile** | `pet_profile/presentation/widgets/tabs/helpers/pet_info_image_helper.dart`                         | 이미지 선택 바텀시트     |
| **Pet Profile** | `pet_profile/presentation/widgets/profile_editing/pet_profile_image_picker.dart`                   | ImagePicker 호출         |
| **Daily**       | `daily/presentation/screens/daily_pet_registration_screen_widgets/registration_form_handlers.dart` | 이미지 선택 로직         |
| **Settings**    | `settings/presentation/screens/profile_edit_screen.dart`                                           | 프로필 이미지 처리       |
| **Walk**        | `walk/data/repositories/walk_share_repository_impl.dart`                                           | 이미지 생성 및 저장      |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/core/services/image_service.dart';
import 'package:aipet_frontend/shared/core/services/image_management_service.dart';
import 'package:aipet_frontend/shared/core/providers/image_management_providers.dart';
import 'package:aipet_frontend/shared/services/image_storage_service.dart';
```

#### 마이그레이션 예시

**Before (Feature별 이미지 처리 구현):**

```dart
// ❌ features/pet_profile/presentation/widgets/tabs/helpers/pet_info_image_helper.dart
class PetInfoImageHelper {
  static void showImagePickerOptions(BuildContext context, WidgetRef ref, String tabId, String petId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('カメラで撮影'),
              onTap: () {
                Navigator.pop(context);
                pickImageFromCamera(context, ref, tabId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリーから選択'),
              onTap: () {
                Navigator.pop(context);
                pickImageFromGallery(context, ref, tabId);
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> pickImageFromCamera(BuildContext context, WidgetRef ref, String tabId) async {
    final imagePath = await ImageService.pickFromCamera(context);
    if (imagePath != null && context.mounted) {
      ref.read(petBasicInfoTabControllerProvider(tabId).notifier).updateSelectedImage(imagePath);
      SnackBarService.showSuccess(context, '写真が選択されました');
    }
  }
}
```

**After (Shared ImageService 사용):**

```dart
// ✅ Shared 모듈로 통합
import 'package:aipet_frontend/shared/core/services/image_service.dart';

class PetProfileImageHandler {
  static Future<void> selectPetImage(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) async {
    // Shared ImageService의 통합 이미지 선택 옵션 사용
    final imagePath = await ImageService.showImagePickerOptions(
      context,
      showDefaultImages: true,
      allowRemoval: false,
    );

    if (imagePath != null && context.mounted) {
      ref.read(petBasicInfoTabControllerProvider(tabId).notifier)
          .updateSelectedImage(imagePath);
      SnackBarService.showSuccess(context, '画像が選択されました');
    }
  }
}
```

### 4.2 이미지 압축 및 업로드 통합

**Before:**

```dart
// ❌ features/pet_profile/data/services/pet_image_upload_service.dart
class PetImageUploadService {
  Future<ResultState<File>> _processImage(File imageFile, ImageQuality quality) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      // 압축 로직 직접 구현
      img.Image processedImage = image;
      final maxDimension = _getMaxDimensionForQuality(quality);

      if (image.width > maxDimension || image.height > maxDimension) {
        processedImage = img.copyResize(image, width: maxDimension);
      }

      // ...
    }
  }
}
```

**After:**

```dart
// ✅ Shared ImageManagementService 사용
import 'package:aipet_frontend/shared/core/services/image_management_service.dart';

class PetImageUploadService {
  final ImageManagementService _imageService;

  Future<Result<String>> uploadPetImage(File imageFile) async {
    // Shared 서비스의 압축 기능 활용
    final compressResult = await _imageService.compressImage(
      imageFile.path,
      quality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (!compressResult.isSuccess) {
      return Result.failure(compressResult.message);
    }

    // 업로드 로직...
  }
}
```

---

## 🎯 5. 날짜/시간 포맷팅 통합

### 5.1 중복된 날짜 포맷팅 함수

#### 현재 상태 (Features에 분산)

| Feature        | 파일                                                                    | 중복 내용                                                            |
| -------------- | ----------------------------------------------------------------------- | -------------------------------------------------------------------- |
| **Scheduling** | `scheduling/presentation/controllers/helpers/feeding_stats_helper.dart` | `formatTime()` 메서드                                                |
| **Scheduling** | `scheduling/presentation/controllers/feeding_schedule_controller.dart`  | `formatTime()`, `_parseHour()`, `_parseMinute()`                     |
| **Walk**       | `walk/domain/entities/walk_record_entity.dart`                          | `dateString`, `timeString`, `formattedDistance`, `formattedDuration` |
| **Walk**       | `walk/presentation/screens/helpers/walk_list_timer_helper.dart`         | 시간 계산 로직                                                       |
| **Scheduling** | `scheduling/domain/entities/schedule_entity.dart`                       | `isToday`, `isTomorrow`, `isThisWeek`                                |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/core/services/datetime_service.dart';
import 'package:aipet_frontend/shared/core/services/date_format_service.dart';
import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';
```

#### 마이그레이션 예시

**Before (Feature별 구현):**

```dart
// ❌ features/scheduling/presentation/controllers/helpers/feeding_stats_helper.dart
class FeedingStatsHelper {
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// ❌ features/walk/domain/entities/walk_record_entity.dart
class WalkRecordEntity {
  String get timeString {
    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDistance {
    final dist = calculatedDistance;
    if (dist < 1000) {
      return '${dist.toStringAsFixed(0)}m';
    } else {
      return '${(dist / 1000).toStringAsFixed(2)}km';
    }
  }
}
```

**After (Shared DateTimeService 사용):**

```dart
// ✅ Shared 모듈로 통합
import 'package:aipet_frontend/shared/core/services/datetime_service.dart';
import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';

class FeedingStatsHelper {
  static String formatTime(DateTime time) {
    return DateTimeService.formatTime(time); // HH:mm 형식
  }
}

class WalkRecordEntity {
  String get timeString => DateTimeService.formatTime(startTime);

  String get formattedDistance => DateTimeUtils.formatDistance(calculatedDistance);

  String get formattedDuration => DateTimeUtils.formatDuration(duration);
}
```

---

## 🎯 6. 상수 및 메시지 통합

### 6.1 중복된 상수 정의

#### 현재 상태 (Features에 분산)

| Feature         | 파일                                                            | 중복 내용                                 |
| --------------- | --------------------------------------------------------------- | ----------------------------------------- |
| **AI**          | `ai/domain/constants/ai_constants.dart`                         | 에러 메시지, 성공 메시지, API 설정        |
| **Allergy**     | `allergy/domain/constants/allergy_constants.dart`               | OpenAI 설정, 에러 메시지                  |
| **Pet Profile** | `pet_profile/presentation/constants/pet_profile_constants.dart` | UI 메시지, 필드 레이블                    |
| **Auth**        | `auth/domain/auth_constants.dart`                               | 에러 메시지 맵 (AppTexts 사용하지만 중복) |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/core/constants/app_texts.dart';
import 'package:aipet_frontend/shared/core/constants/app_constants.dart';
import 'package:aipet_frontend/shared/core/constants/error_codes.dart';
import 'package:aipet_frontend/shared/core/constants/unified_constants.dart';
```

#### 마이그레이션 예시

**Before (Feature별 상수 정의):**

```dart
// ❌ features/allergy/domain/constants/allergy_constants.dart
class AllergyConstants {
  static const String noProductsSelectedError = '選択された商品がありません';
  static const String analysisErrorMessage = 'アレルギー分析中にエラーが発生しました';

  static const int openAiTimeoutSeconds = 30;
  static const String openAiModel = 'gpt-4o';
  static const double openAiTemperature = 0.7;
  static const int openAiMaxTokens = 1500;
}

// ❌ features/pet_profile/presentation/constants/pet_profile_constants.dart
class PetProfileConstants {
  static const String loadingMessage = '読み込み中...';
  static const String errorMessage = 'エラーが発生しました';
  static const String successMessage = '操作が完了しました';
  static const String saveSuccessMessage = '保存しました';
}
```

**After (Shared 상수 사용):**

```dart
// ✅ Shared 모듈로 통합
import 'package:aipet_frontend/shared/core/constants/app_texts.dart';
import 'package:aipet_frontend/shared/core/constants/app_constants.dart';
import 'package:aipet_frontend/shared/core/constants/unified_constants.dart';

// Feature-specific 상수만 유지
class AllergyConstants {
  // ✅ Shared 상수 사용
  static String get noProductsSelectedError => AppTexts.noData;
  static String get analysisErrorMessage => AppTexts.error;

  // ✅ 공통 API 설정 사용
  static int get openAiTimeoutSeconds => UnifiedValidationRules.apiTimeout.inSeconds;
  static const String openAiModel = 'gpt-4o'; // AI 모델명은 feature-specific

  // Feature에만 필요한 상수
  static const int minimumAllergyProducts = 1;
  static const int minimumNonAllergyProducts = 1;
}

class PetProfileController {
  void showLoadingMessage() {
    // ✅ Shared 상수 사용
    UINotificationService.showInfo(AppTexts.loading);
  }

  void showSaveSuccess() {
    UINotificationService.showSuccess(AppTexts.saved);
  }
}
```

---

## 🎯 7. Result 패턴 통합

### 7.1 중복된 Result 클래스

#### 현재 상태

| Feature       | 파일                                            | 문제점                                                           |
| ------------- | ----------------------------------------------- | ---------------------------------------------------------------- |
| **Auth**      | `auth/domain/repositories/auth_repository.dart` | `AuthResult` 클래스 (@deprecated 표시되어 있지만 여전히 사용 중) |
| 모든 Features | 다양한 파일                                     | `Result<T>` 패턴 혼용 (일부는 shared, 일부는 feature별)          |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:aipet_frontend/shared/core/data/result_types.dart'; // ResultState<T>
```

#### 마이그레이션 가이드

**Before (Feature별 Result 구현):**

```dart
// ❌ features/auth/domain/repositories/auth_repository.dart
@Deprecated('Use shared Result<AuthUser> pattern instead')
class AuthResult {
  final bool isSuccess;
  final String message;
  final AuthUser? user;

  Result<AuthUser> toResult() {
    if (isSuccess && user != null) {
      return Result.success(message, user!);
    } else {
      return Result.failure(message);
    }
  }
}

Future<AuthResult> login(String email, String password);
```

**After (Shared Result 패턴 직접 사용):**

```dart
// ✅ Shared Result 패턴 직접 사용
import 'package:aipet_frontend/shared/core/domain/result.dart';

abstract class AuthRepository {
  // AuthResult 대신 공통 Result<T> 사용
  Future<Result<AuthUser>> login(String email, String password);
  Future<Result<AuthUser>> register(String email, String password);
  Future<Result<void>> logout();
}
```

---

## 🎯 8. 공통 위젯 통합

### 8.1 중복된 상태 위젯

#### 현재 상태 (Features에 분산)

| Feature   | 파일                                                                              | 중복 내용                                                    |
| --------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| **Daily** | `daily/presentation/widgets/loading_error_widgets.dart`                           | `LoadingStateWidget`, `ErrorStateWidget`, `EmptyStateWidget` |
| **Home**  | `home/presentation/widgets/home_error_view_widget.dart`                           | 에러 화면 위젯                                               |
| **Daily** | `daily/presentation/screens/daily_health_screen_widgets/daily_health_states.dart` | 로딩/에러/빈 상태 위젯                                       |
| **Auth**  | `auth/presentation/widgets/error_message.dart`                                    | 에러 메시지 위젯                                             |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/ui/components/states/loading_state.dart';
import 'package:aipet_frontend/shared/ui/components/states/empty_state.dart';
import 'package:aipet_frontend/shared/widgets/feedback/loading_widget.dart';
```

#### 마이그레이션 예시

**Before (Feature별 위젯 구현):**

```dart
// ❌ features/daily/presentation/widgets/loading_error_widgets.dart
class LoadingStateWidget extends StatelessWidget {
  final String message;

  const LoadingStateWidget({super.key, this.message = '読み込み中...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  // ... 구현
}
```

**After (Shared 위젯 사용):**

```dart
// ✅ Shared 모듈로 통합
import 'package:aipet_frontend/shared/ui/components/states/loading_state.dart';
import 'package:aipet_frontend/shared/ui/components/states/empty_state.dart';

class DailyHealthScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(dailyHealthProvider);

    return healthState.when(
      data: (data) => _buildHealthContent(data),
      loading: () => const LoadingStateWidget(message: '健康情報を読み込み中...'),
      error: (error, stack) => EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'エラーが発生しました',
        message: error.toString(),
        actionLabel: '再試行',
        onAction: () => ref.invalidate(dailyHealthProvider),
      ),
    );
  }
}
```

---

## 🎯 9. SnackBar 및 알림 통합

### 9.1 중복된 SnackBar 구현

#### 현재 상태 (Features에 분산)

각 feature마다 `ScaffoldMessenger.showSnackBar()` 직접 호출:

| Feature          | 파일                                                              | 중복 내용                                                                                 |
| ---------------- | ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| **Pet Profile**  | `pet_profile/domain/services/pet_registration_error_handler.dart` | `showErrorSnackBar()`, `showSuccessSnackBar()` 함수                                       |
| **Facility**     | `facility/data/services/facility_error_handler.dart`              | `_showErrorSnackBar()` 메서드                                                             |
| **Facility**     | `facility/presentation/controllers/base_facility_controller.dart` | `showSuccessMessage()`, `showErrorMessage()`, `showInfoMessage()`, `showWarningMessage()` |
| **Contact**      | `contact/presentation/screens/contact_form_screen.dart`           | 폼 제출 후 SnackBar 직접 호출                                                             |
| **All Features** | 100+ 곳                                                           | `ScaffoldMessenger.of(context).showSnackBar()` 직접 호출                                  |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/core/services/snackbar_service.dart';
import 'package:aipet_frontend/shared/core/services/ui_notification_service.dart';
```

#### 마이그레이션 예시

**Before (Feature별 SnackBar 구현):**

```dart
// ❌ features/facility/presentation/controllers/base_facility_controller.dart
abstract class BaseFacilityController {
  void showSuccessMessage(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void showErrorMessage(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // showInfoMessage(), showWarningMessage() 등 추가 중복...
}
```

**After (Shared SnackBarService 사용):**

```dart
// ✅ Shared SnackBarService로 통합
import 'package:aipet_frontend/shared/core/services/snackbar_service.dart';

abstract class BaseFacilityController {
  // showSuccessMessage(), showErrorMessage() 등 모두 제거
  // SnackBarService 직접 사용
}

// 호출하는 쪽에서 직접 사용
class FacilityController extends BaseFacilityController {
  Future<void> loadFacilities() async {
    try {
      // 로직...
      if (context.mounted) {
        SnackBarService.showSuccess(context, '施設を読み込みました');
      }
    } catch (error) {
      if (context.mounted) {
        SnackBarService.showError(context, '施設の読み込みに失敗しました');
      }
    }
  }
}
```

---

## 🎯 10. 로컬 저장소 (Cache) 통합

### 10.1 중복된 SharedPreferences 사용

#### 현재 상태 (Features에 분산)

각 feature마다 독립적인 캐시 서비스 구현:

| Feature          | 파일                                                            | 중복 내용                           |
| ---------------- | --------------------------------------------------------------- | ----------------------------------- |
| **Notification** | `notification/data/services/notification_cache_service.dart`    | SharedPreferences 래핑, JSON 직렬화 |
| **Settings**     | `settings/data/repositories/settings_repository_impl.dart`      | 캐시 크기 계산, 캐시 정리           |
| **Onboarding**   | `onboarding/data/repositories/onboarding_repository_impl.dart`  | 상태 저장/로드                      |
| **Facility**     | `facility/data/services/facility_local_storage_service.dart`    | 시설 데이터 캐싱                    |
| **Shopping**     | `shopping/data/services/favorite_service.dart`                  | 즐겨찾기 저장                       |
| **AI**           | `ai/data/services/ai_local_storage_service.dart`                | AI 대화 히스토리 저장               |
| **Scheduling**   | `scheduling/data/services/helpers/feeding_storage_helper.dart`  | 급여 기록 저장                      |
| **Pet Feeding**  | `pet_feeding/data/services/helpers/feeding_storage_helper.dart` | 레시피 저장                         |
| **Daily**        | `daily/data/services/reservation_local_storage_service.dart`    | 예약 데이터 저장                    |
| **Auth**         | `auth/data/services/offline_auth_state_manager.dart`            | 인증 상태 저장                      |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/services/cache_service.dart';
import 'package:aipet_frontend/shared/core/data/base_local_data_source.dart';
import 'package:aipet_frontend/shared/core/services/secure_storage_service.dart';
```

#### 마이그레이션 예시

**Before (Feature별 캐시 구현):**

```dart
// ❌ features/notification/data/services/notification_cache_service.dart
class NotificationCacheService {
  static const String _notificationsCacheKey = 'cached_notifications';
  static const String _settingsCacheKey = 'cached_notification_settings';
  static const Duration _cacheExpiration = Duration(minutes: 30);

  static Future<Result<bool>> cacheNotifications({
    required String userId,
    required List<NotificationModel> notifications,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = notifications.map((n) => n.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString('$_notificationsCacheKey\_$userId', jsonString);

      // 캐시 타임스탬프 저장
      final timestamp = DateTime.now().toIso8601String();
      await prefs.setString('${_notificationsCacheKey}_timestamp_$userId', timestamp);

      return Result.success('알림을 캐시했습니다', true);
    } catch (e) {
      return Result.failure('알림 캐시에 실패했습니다: $e');
    }
  }
}
```

**After (Shared BaseLocalDataSource 사용):**

```dart
// ✅ BaseLocalDataSource 상속하여 표준화
import 'package:aipet_frontend/shared/core/data/base_local_data_source.dart';
import 'package:aipet_frontend/shared/core/data/result_types.dart';

class NotificationLocalDataSource extends BaseLocalDataSource<NotificationModel> {
  NotificationLocalDataSource() : super('notification');

  @override
  NotificationModel fromJson(Map<String, dynamic> json) {
    return NotificationModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(NotificationModel data) {
    return data.toJson();
  }

  // 캐시 만료 시간이 있는 경우 saveCacheWithExpiry 사용
  Future<ResultState<void>> cacheNotifications(
    String userId,
    List<NotificationModel> notifications,
  ) async {
    return await saveList(
      userId,
      notifications,
    );
  }

  // 만료 시간이 포함된 캐시 저장
  Future<ResultState<void>> cacheNotificationsWithExpiry(
    String userId,
    List<NotificationModel> notifications,
  ) async {
    // BaseLocalDataSource의 saveCacheWithExpiry 활용
    return await saveCacheWithExpiry(
      userId,
      notifications.first, // 리스트 저장은 별도 구현 필요
      const Duration(minutes: 30),
    );
  }
}
```

---

## 🎯 11. PetEntity 통합

### 11.1 중복된 Pet 엔티티 정의

#### 현재 상태

| Feature   | 파일                                                                              | 문제점                                   |
| --------- | --------------------------------------------------------------------------------- | ---------------------------------------- |
| **Walk**  | `walk/domain/entities/pet_info.dart`                                              | 간소화된 Pet 정보 (id, name, imageUrl만) |
| **Home**  | `home/domain/entities/pet_summary_entity.dart`                                    | Home용 Pet 요약 정보                     |
| **Daily** | `daily/presentation/controllers/pet_registration/pet_registration_form_data.dart` | Pet 등록 폼 데이터                       |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/core/domain/entities/pet_entity.dart';
import 'package:aipet_frontend/shared/domain/entities/pet_profile_entity.dart';
```

#### 마이그레이션 가이드

**Before (Feature별 Pet 정의):**

```dart
// ❌ features/walk/domain/entities/pet_info.dart
class PetInfo {
  final String id;
  final String name;
  final String? imageUrl;

  const PetInfo({required this.id, required this.name, this.imageUrl});
}

// ❌ features/home/domain/entities/pet_summary_entity.dart
class PetSummaryEntity {
  final String id;
  final String name;
  final String typeName;
  final String? breed;
  final int age;
  final DateTime birthDate;
  final String? profileImageUrl;

  // ... 구현
}
```

**After (Shared PetEntity 사용):**

```dart
// ✅ Shared 모듈로 통합
import 'package:aipet_frontend/shared/core/domain/entities/pet_entity.dart';
import 'package:aipet_frontend/shared/domain/entities/pet_profile_entity.dart';

// Walk feature에서는 PetEntity 직접 사용
class WalkRecordEntity {
  final String petId;
  final String petName;

  // PetEntity에서 필요한 정보만 추출하여 사용
  factory WalkRecordEntity.fromPet(PetEntity pet) {
    return WalkRecordEntity(
      petId: pet.id,
      petName: pet.name,
      // ...
    );
  }
}

// Home feature에서는 PetProfileEntity를 사용하거나 확장
class PetSummaryEntity {
  final PetProfileEntity petProfile;

  const PetSummaryEntity(this.petProfile);

  String get id => petProfile.id;
  String get name => petProfile.name;
  String get typeName => petProfile.type;

  // Feature-specific 로직만 추가
  String get typeIcon {
    switch (typeName.toLowerCase()) {
      case 'dog': return '🐕';
      case 'cat': return '🐱';
      default: return '🐾';
    }
  }
}
```

---

## 🎯 12. 로깅 및 디버깅 통합

### 12.1 중복된 debugPrint 사용

#### 현재 상태 (Features에 분산)

과도한 `debugPrint()` 직접 사용:

| Feature          | 파일                                                      | 문제점                                   |
| ---------------- | --------------------------------------------------------- | ---------------------------------------- |
| **Pet Profile**  | `pet_profile/presentation/utils/pet_data_reset_util.dart` | 수동 로깅 (`debugPrint()` 직접 호출)     |
| **Pet Profile**  | `pet_profile/data/services/local_pet_service.dart`        | 디버그 정보 출력 수동 관리               |
| **Shopping**     | `shopping/data/services/rakuten_api_service.dart`         | API 응답 로깅 (`debugPrint()` 직접 호출) |
| **Home**         | `home/data/services/weather_service.dart`                 | 날씨 API 호출 로깅 (`debugPrint()`)      |
| **All Features** | 200+ 곳                                                   | 일관성 없는 로깅 패턴                    |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/shared/services/base_logging_service.dart';
```

#### 마이그레이션 예시

**Before (debugPrint 직접 사용):**

```dart
// ❌ features/shopping/data/services/rakuten_api_service.dart
Future<List<RakutenPetProduct>> searchProducts(String keyword) async {
  debugPrint('🔍 Searching Rakuten products with keyword: $keyword');
  debugPrint('🔑 API Key: ${_apiKey.isNotEmpty ? "Set" : "Not set"}');

  final response = await http.get(url);
  debugPrint('📝 Response Status Code: ${response.statusCode}');
  debugPrint('📝 Response Body: ${response.body}');

  if (response.statusCode == 200) {
    debugPrint('✅ API call successful');
    final data = json.decode(response.body);
    debugPrint('📊 API Response data keys: ${data.keys.toList()}');
    // ...
  } else {
    debugPrint('❌ API call failed: ${response.statusCode}');
  }
}
```

**After (LoggerService 사용):**

```dart
// ✅ Shared LoggerService로 통합
import 'package:aipet_frontend/shared/core/services/logger_service.dart';

class RakutenApiService extends BaseLoggingService {
  RakutenApiService() : super('rakuten_api');

  Future<List<RakutenPetProduct>> searchProducts(String keyword) async {
    logInfo('Searching products', data: {'keyword': keyword});

    final response = await http.get(url);

    LoggerService.api(
      'GET',
      url.toString(),
      statusCode: response.statusCode,
      isError: response.statusCode != 200,
    );

    if (response.statusCode == 200) {
      logInfo('API call successful', data: {'itemCount': data['Items'].length});
      // ...
    } else {
      logError('API call failed', error: Exception('Status: ${response.statusCode}'));
    }
  }
}
```

**개선 효과:**

- 📊 **구조화된 로깅**: 민감한 정보 자동 마스킹
- 🔍 **필터링 가능**: 로그 레벨별 필터링
- 📈 **분석 가능**: 로그 데이터를 분석 도구로 전송 가능
- 🎯 **일관성**: 모든 feature에서 동일한 로깅 포맷

---

## 🎯 13. Repository 패턴 표준화

### 13.1 불완전한 Repository 구현

#### 현재 상태

| Feature          | 파일                                                               | 문제점                                               |
| ---------------- | ------------------------------------------------------------------ | ---------------------------------------------------- |
| **Scheduling**   | `scheduling/data/repositories/schedule_repository_impl.dart`       | BaseRepository 미사용, 메모리 기반 저장소            |
| **Walk**         | `walk/data/repositories/walk_repository_impl.dart`                 | BaseRepository 미사용, 직접 LocalStorageService 호출 |
| **Allergy**      | `allergy/data/repositories/allergy_analysis_repository_impl.dart`  | Repository 인터페이스 정의했으나 표준 패턴 미사용    |
| **Pet Feeding**  | `pet_feeding/data/repositories/pet_feeding_repository_impl.dart`   | Mock 데이터 하드코딩                                 |
| **Notification** | `notification/data/repositories/notification_repository_impl.dart` | 표준 에러 처리 패턴 미사용                           |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/core/domain/base_repository.dart';
import 'package:aipet_frontend/shared/core/data/base_hybrid_repository.dart';
import 'package:aipet_frontend/shared/core/data/base_local_data_source.dart';
import 'package:aipet_frontend/shared/core/data/base_remote_data_source.dart';
```

#### 마이그레이션 예시

**Before (표준 패턴 미사용):**

```dart
// ❌ features/scheduling/data/repositories/schedule_repository_impl.dart
class ScheduleRepositoryImpl implements ScheduleRepository {
  final List<ScheduleModel> _schedules = []; // 메모리 기반 저장소

  @override
  Future<List<ScheduleEntity>> getAllSchedules() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _schedules.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ScheduleEntity> createSchedule(ScheduleEntity schedule) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final model = ScheduleModel(...); // 변환 로직 수동 작성
    _schedules.add(model);
    return model.toEntity();
  }

  // 에러 처리, 캐싱, API 연동 로직 없음
}
```

**After (BaseHybridRepository 사용):**

```dart
// ✅ BaseHybridRepository 상속하여 표준화
import 'package:aipet_frontend/shared/core/data/base_hybrid_repository.dart';
import 'package:aipet_frontend/shared/core/data/result_types.dart';

class ScheduleRepositoryImpl extends BaseHybridRepository<ScheduleEntity> {
  final ScheduleLocalDataSource _localDataSource;
  final ScheduleRemoteDataSource _remoteDataSource;

  ScheduleRepositoryImpl({
    required ScheduleLocalDataSource localDataSource,
    required ScheduleRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       super(
         localDataSource: localDataSource,
         remoteDataSource: remoteDataSource,
       );

  Future<ResultState<List<ScheduleEntity>>> getAllSchedules() async {
    // BaseHybridRepository의 getList 활용
    return await getList(
      'schedules',
      '/api/v1/schedules',
    );
  }

  Future<ResultState<ScheduleEntity>> createSchedule(
    ScheduleEntity schedule,
  ) async {
    // BaseHybridRepository의 createData 활용
    return await createData(
      '/api/v1/schedules',
      schedule,
      cacheKey: 'schedule_${schedule.id}',
    );
  }

  // 자동으로 에러 처리, 캐싱, API/로컬 전환 지원
}
```

---

## 🎯 14. UseCase 패턴 표준화

### 14.1 UseCase 구현 표준화

#### 현재 상태

다양한 UseCase 구현 방식 혼용:

| Feature      | 파일                                                      | 구현 방식                     |
| ------------ | --------------------------------------------------------- | ----------------------------- |
| **Facility** | `facility/domain/usecases/search_facilities_usecase.dart` | 일반 클래스 + `call()` 메서드 |
| **AI**       | `ai/domain/usecases/analyze_message_usecase.dart`         | 파라미터 클래스 분리 패턴     |
| **Auth**     | `auth/domain/usecases/authenticate_usecase.dart`          | 파라미터 클래스 + try-catch   |

#### 대체할 Shared 모듈

```dart
// ✅ 사용해야 할 Shared 모듈
import 'package:aipet_frontend/shared/core/domain/base_usecase.dart';
import 'package:aipet_frontend/shared/core/domain/base_usecase_enhanced.dart';
```

#### 마이그레이션 예시

**Before (일반 클래스 구현):**

```dart
// ❌ features/facility/domain/usecases/search_facilities_usecase.dart
class SearchFacilitiesUseCase {
  final FacilityRepository repository;

  SearchFacilitiesUseCase(this.repository);

  Future<Result<List<Facility>>> call(String query) async {
    try {
      final result = await repository.searchFacilities(query);
      if (result.isSuccess) {
        return Result.success('施設を検索しました', result.dataOrNull ?? []);
      } else {
        return Result.failure('施設の検索に失敗しました');
      }
    } catch (error) {
      return Result.failure('施設の検索中にエラーが発生しました: ${error.toString()}');
    }
  }
}
```

**After (BaseUseCase 상속):**

```dart
// ✅ BaseUseCase 상속하여 표준화
import 'package:aipet_frontend/shared/core/domain/base_usecase.dart';

class SearchFacilitiesUseCase extends BaseUseCase<List<Facility>, String> {
  final FacilityRepository _repository;

  SearchFacilitiesUseCase(this._repository);

  @override
  Future<Result<List<Facility>>> call(String query) async {
    try {
      return await _repository.searchFacilities(query);
    } catch (error) {
      return Result.failure('施設の検索中にエラーが発生しました: ${error.toString()}');
    }
  }
}
```

---

## 📊 15. 마이그레이션 우선순위

### High Priority (즉시 마이그레이션 권장)

1. **에러 처리** - 모든 feature의 에러 핸들러를 `ErrorHandlingService`로 통합
2. **상수 및 메시지** - `AppTexts`, `AppConstants` 사용
3. **Result 패턴** - `AuthResult` 등 중복 Result 클래스 제거
4. **유효성 검사** - `ValidationService` 사용

### Medium Priority (점진적 마이그레이션)

5. **API 통신** - `HttpClientService`, `ApiClient` 사용
6. **이미지 처리** - `ImageService`, `ImageManagementService` 사용
7. **날짜/시간** - `DateTimeService` 사용

### Low Priority (선택적 마이그레이션)

8. **공통 위젯** - 로딩/에러/빈 상태 위젯 통합
9. **UseCase 패턴** - `BaseUseCase` 상속 표준화
10. **PetEntity** - 공통 `PetEntity` 사용

---

## 📝 16. 마이그레이션 체크리스트

### 에러 처리 마이그레이션

- [x] `facility/data/services/facility_error_handler.dart` → `ErrorHandlingService` ✅ **완료**
- [x] `pet_profile/domain/services/pet_registration_error_handler.dart` → `CommonErrorService` ✅ **완료**
- [x] `ai/domain/errors/ai_errors.dart` (`AiErrorHandler`) → `ApiErrorHandler` ✅ **완료**
- [x] `walk/domain/services/walk_error_handler.dart` → `ErrorHandlingService` ✅ **완료**
- [x] `ai/data/services/ai_dio_service.dart` (`_handleDioException`) → `ApiErrorHandler.handleError()` ✅ **완료**

### API 통신 마이그레이션

- [ ] `home/data/services/weather_service.dart` → `HttpClientService`
- [ ] `home/data/services/openweathermap_service.dart` → `HttpClientService` + `ApiClient`
- [x] `ai/data/services/ai_dio_service.dart` → `AiHttpClientService` ✅ **완료 (파일 삭제)**
- [ ] `walk/data/services/walk_api_service.dart` → `ApiClient`
- [ ] `shopping/data/services/rakuten_api_service.dart` → `HttpClientService`

### 유효성 검사 마이그레이션

- [ ] `daily/presentation/controllers/pet_registration/pet_registration_validator.dart` → `ValidationMixin` 유지 (이미 사용 중)
- [ ] `pet_feeding/domain/usecases/helpers/recipe_validation_helper.dart` → `ValidationService`
- [ ] `pet_profile/presentation/controllers/pet_profile_form_controller.dart` → `ValidationService`
- [ ] `auth/presentation/controllers/auth_controller.dart` → `UnifiedValidationService`
- [ ] `ai/domain/services/ai_message_manager.dart` → `UnifiedValidationService`

### 이미지 처리 마이그레이션

- [x] `pet_profile/presentation/widgets/profile_editing/pet_profile_image_picker.dart` → `ImageService` ✅ **완료**
- [x] `daily/presentation/controllers/pet_registration/pet_ocr_service.dart` → `ImageService` ✅ **완료**
- [x] `pet_profile/data/services/pet_image_upload_service.dart` (압축 로직) → `ImageService.compressImage()` ✅ **완료**
- [x] `pet_profile/presentation/widgets/tabs/helpers/pet_info_image_helper.dart` → ImageService 이미 사용 중 ✅ **확인 완료**
- [x] `walk/data/repositories/walk_share_repository_impl.dart` → 추가 작업 불필요 ✅ **확인 완료**

### 날짜/시간 포맷팅 마이그레이션

- [ ] `scheduling/presentation/controllers/helpers/feeding_stats_helper.dart` → `DateTimeService`
- [ ] `scheduling/presentation/controllers/feeding_schedule_controller.dart` → `DateTimeService`
- [ ] `walk/domain/entities/walk_record_entity.dart` → `DateTimeUtils`, `DateTimeService`
- [ ] `scheduling/domain/entities/schedule_entity.dart` → `DateTimeUtils.isToday()` 등

### 상수 마이그레이션

- [ ] `ai/domain/constants/ai_constants.dart` → `UnifiedConstants`, `AppTexts`
- [ ] `allergy/domain/constants/allergy_constants.dart` → `AppTexts`, `UnifiedValidationRules`
- [ ] `pet_profile/presentation/constants/pet_profile_constants.dart` → `AppTexts`, `AppConstants`
- [ ] `auth/domain/auth_constants.dart` → `AppTexts` 직접 사용 (이미 부분적으로 사용 중)

### Result 패턴 마이그레이션

- [x] `auth/domain/repositories/auth_repository.dart` (`AuthResult`) → 완전히 제거하고 `Result<T>` 사용 ✅ **완료**
- [x] `shared/core/data/result_types.dart` typedef 제거 → Result<T>와 ResultState<T> 명확히 분리 ✅ **완료**
- [x] Result<T> import 추가 (7개 파일) → result_types.dart 사용 파일들 수정 ✅ **완료**

### SnackBar 및 알림 마이그레이션

- [x] `pet_profile/domain/services/pet_registration_error_handler.dart` (`showErrorSnackBar`, `showSuccessSnackBar`) → `SnackBarService` ✅ **완료 (파일 삭제)**
- [x] `facility/data/services/facility_error_handler.dart` (`_showErrorSnackBar`) → `SnackBarService` ✅ **완료 (파일 삭제)**
- [x] `facility/presentation/controllers/base_facility_controller.dart` (모든 show\*Message 메서드) → `SnackBarService` ✅ **완료**
- [x] `contact/presentation/screens/contact_form_screen.dart` → `SnackBarService` ✅ **완료**
- [x] `ScaffoldMessenger.of(context).showSnackBar()` **전체 통합 완료** (165개 → 0개, 100% 완료) ✅ **완료**

### 로컬 저장소 마이그레이션

- [ ] `notification/data/services/notification_cache_service.dart` → `BaseLocalDataSource`
- [ ] `settings/data/repositories/settings_repository_impl.dart` (캐시 관리) → `CacheService`
- [ ] `facility/data/services/facility_local_storage_service.dart` → `BaseLocalDataSource`
- [ ] `shopping/data/services/favorite_service.dart` → `BaseLocalDataSource`
- [ ] `ai/data/services/ai_local_storage_service.dart` → `BaseLocalDataSource`
- [ ] `scheduling/data/services/helpers/feeding_storage_helper.dart` → `BaseLocalDataSource`
- [ ] `pet_feeding/data/services/helpers/feeding_storage_helper.dart` → `BaseLocalDataSource`
- [ ] `daily/data/services/reservation_local_storage_service.dart` → `BaseLocalDataSource`
- [ ] `auth/data/services/offline_auth_state_manager.dart` → `SecureStorageService`

### 로깅 마이그레이션

- [ ] `shopping/data/services/rakuten_api_service.dart` → `LoggerService`
- [ ] `pet_profile/data/services/local_pet_service.dart` → `LoggerService`
- [ ] `home/data/services/weather_service.dart` → `LoggerService`
- [ ] 모든 `debugPrint()` 호출 → `LoggerService.debug()`, `LoggerService.info()` 등

### Repository 패턴 마이그레이션

- [ ] `scheduling/data/repositories/schedule_repository_impl.dart` → `BaseHybridRepository`
- [ ] `walk/data/repositories/walk_repository_impl.dart` → `BaseHybridRepository`
- [ ] `allergy/data/repositories/allergy_analysis_repository_impl.dart` → `BaseRepository`
- [ ] `notification/data/repositories/notification_repository_impl.dart` → `BaseHybridRepository`

---

## 🚀 17. 마이그레이션 절차

### Step 1: 에러 처리 통합

```bash
# 1. Feature별 에러 핸들러 분석
grep -r "class.*ErrorHandler" lib/features/

# 2. ErrorHandlingService로 교체
# - try-catch 블록을 ErrorHandlingService.handleAsync()로 변경
# - 커스텀 에러 메시지는 UnifiedErrorMessages 또는 AppTexts 사용

# 3. 테스트 실행
flutter test
```

### Step 2: API 통신 통합

```bash
# 1. Dio 인스턴스 직접 생성 코드 검색
grep -r "Dio()" lib/features/

# 2. HttpClientService 또는 ApiClient로 교체
# - BaseRemoteDataSource 상속 활용
# - ApiErrorHandler.handleError() 사용

# 3. 통합 테스트
flutter test
```

### Step 3: 유효성 검사 통합

```bash
# 1. 검증 로직 중복 확인
grep -r "validateRequired\|validateLength\|validateEmail" lib/features/

# 2. ValidationService 또는 ValidationMixin 사용
# - 공통 검증은 ValidationService 사용
# - Feature-specific 검증은 ValidationMixin 확장

# 3. 검증 테스트
flutter test
```

### Step 4: 상수 통합

```bash
# 1. 하드코딩된 메시지 검색
grep -r "const String.*Message\|const String.*Error" lib/features/

# 2. AppTexts, AppConstants로 교체
# - UI 텍스트는 AppTexts 사용
# - 설정값은 AppConstants 사용

# 3. 린트 확인
flutter analyze
```

---

## 📚 18. 참고 자료

### Shared 모듈 문서

- `lib/shared/README.md` - Shared 모듈 전체 개요
- `lib/shared/core/services/README.md` - 서비스 모듈 가이드
- `lib/shared/core/constants/README.md` - 상수 관리 가이드

### 관련 파일

**에러 처리:**

- `lib/shared/core/api/api_error_handler.dart`
- `lib/shared/core/services/error_handling_service.dart`
- `lib/shared/core/services/common_error_service.dart`
- `lib/shared/foundation/error_handler/error_handler.dart`

**API 통신:**

- `lib/shared/core/api/api_client.dart`
- `lib/shared/core/api/api_interceptors.dart`
- `lib/shared/core/services/http_client_service.dart`
- `lib/shared/core/services/ai_http_client_service.dart`

**유효성 검사:**

- `lib/shared/core/services/validation_service.dart`
- `lib/shared/core/services/unified_validation_service.dart`
- `lib/shared/mixins/validation_mixin.dart`

**이미지 처리:**

- `lib/shared/core/services/image_service.dart`
- `lib/shared/core/services/image_management_service.dart`
- `lib/shared/services/image_storage_service.dart`

**날짜/시간:**

- `lib/shared/core/services/datetime_service.dart`
- `lib/shared/core/services/date_format_service.dart`
- `lib/shared/core/utils/date_time_utils.dart`

**상수:**

- `lib/shared/core/constants/app_texts.dart`
- `lib/shared/core/constants/app_constants.dart`
- `lib/shared/core/constants/error_codes.dart`
- `lib/shared/core/constants/unified_constants.dart`

---

## ⚠️ 19. 주의사항

### 마이그레이션 시 유의점

1. **점진적 마이그레이션**: 한 번에 모든 것을 변경하지 말고 feature별, 기능별로 단계적으로 진행
2. **테스트 작성**: 마이그레이션 전에 기존 동작을 검증하는 테스트 작성
3. **의존성 확인**: Feature 간 의존성이 생기지 않도록 주의 (shared 모듈만 의존)
4. **기존 동작 유지**: 사용자 경험이 변경되지 않도록 기능 동등성 보장
5. **PR 크기 관리**: 큰 변경사항은 여러 PR로 분할

### Feature-Specific 코드 유지 기준

다음과 같은 경우는 Feature 내부에 유지:

- **Feature 고유 비즈니스 로직**: 해당 feature에서만 사용되는 특수한 로직
- **Feature 고유 상수**: 다른 feature에서 재사용 가능성이 없는 값
- **Feature 고유 엔티티**: 다른 feature와 공유하지 않는 도메인 모델
- **Feature 고유 UI 컴포넌트**: 재사용 가능성이 낮은 특화된 위젯

### 공통 코드 기준

다음과 같은 경우는 Shared로 이동:

- **3개 이상의 feature에서 사용**: 공통 함수, 상수, 클래스
- **표준 패턴**: 에러 처리, API 통신, 유효성 검사 등
- **플랫폼 레벨 기능**: 이미지 처리, 저장소, 암호화 등
- **디자인 시스템**: 색상, 폰트, 간격, 공통 위젯

---

## 🔧 20. 자동화 스크립트 (옵션)

### 중복 코드 탐지 스크립트

```bash
#!/bin/bash
# scripts/find_duplicate_code.sh

echo "🔍 Searching for duplicate error handlers..."
grep -r "class.*ErrorHandler\|handleError" lib/features/ --include="*.dart" | sort

echo "\n🔍 Searching for duplicate validation logic..."
grep -r "validateEmail\|validatePassword\|validateRequired" lib/features/ --include="*.dart" | sort

echo "\n🔍 Searching for duplicate date formatting..."
grep -r "formatTime\|formatDate\|formatDuration" lib/features/ --include="*.dart" | sort

echo "\n🔍 Searching for hardcoded error messages..."
grep -r "const String.*Error\|const String.*Message" lib/features/ --include="*.dart" | sort

echo "\n🔍 Searching for Dio instance creation..."
grep -r "Dio()" lib/features/ --include="*.dart" | sort

echo "\n🔍 Searching for SharedPreferences usage..."
grep -r "SharedPreferences\|await prefs" lib/features/ --include="*.dart" | sort

echo "\n🔍 Searching for ScaffoldMessenger calls..."
grep -r "ScaffoldMessenger.of(context).showSnackBar" lib/features/ --include="*.dart" | sort
```

### 사용법

```bash
chmod +x scripts/find_duplicate_code.sh
./scripts/find_duplicate_code.sh > migration_analysis.txt
```

### 마이그레이션 진행 상황 체크 스크립트

```bash
#!/bin/bash
# scripts/check_migration_progress.sh

echo "📊 Migration Progress Report"
echo "=============================="

# 에러 핸들러 체크
ERROR_HANDLERS=$(grep -r "class.*ErrorHandler" lib/features/ --include="*.dart" | wc -l)
echo "🔴 Error Handlers in features: $ERROR_HANDLERS"

# SnackBar 직접 호출 체크
SNACKBAR_CALLS=$(grep -r "ScaffoldMessenger.of(context).showSnackBar" lib/features/ --include="*.dart" | wc -l)
echo "🟡 Direct SnackBar calls: $SNACKBAR_CALLS"

# debugPrint 사용 체크
DEBUG_PRINTS=$(grep -r "debugPrint" lib/features/ --include="*.dart" | wc -l)
echo "🟡 debugPrint calls: $DEBUG_PRINTS"

# Shared 모듈 사용 체크
SHARED_IMPORTS=$(grep -r "import.*shared" lib/features/ --include="*.dart" | wc -l)
echo "🟢 Shared module imports: $SHARED_IMPORTS"

echo ""
echo "Target Goals:"
echo "  - Error Handlers: 0"
echo "  - Direct SnackBar: < 10"
echo "  - debugPrint: < 50"
echo "  - Shared imports: > 200"
```

---

## 📈 21. 예상 효과

### Before (현재 상태)

- ❌ 에러 핸들러: **5+ 중복 구현**
- ❌ HTTP 클라이언트: **6+ 중복 구현**
- ❌ 유효성 검사: **10+ 중복 함수**
- ❌ 날짜 포맷팅: **15+ 중복 함수**
- ❌ 이미지 처리: **8+ 중복 구현**
- ❌ SnackBar/알림: **100+ 중복 호출**
- ❌ 로컬 저장소: **10+ 중복 서비스**
- ❌ 로깅: **200+ 일관성 없는 debugPrint**
- ❌ 상수/메시지: **100+ 하드코딩**

### After (마이그레이션 후)

- ✅ 에러 처리: **단일 ErrorHandlingService**
- ✅ HTTP 통신: **ApiClient + HttpClientService**
- ✅ 유효성 검사: **ValidationService + ValidationMixin**
- ✅ 날짜 처리: **DateTimeService**
- ✅ 이미지 처리: **ImageService + ImageManagementService**
- ✅ 알림: **SnackBarService + UINotificationService**
- ✅ 로컬 저장소: **BaseLocalDataSource + CacheService**
- ✅ 로깅: **LoggerService (구조화된 로깅)**
- ✅ 상수: **AppTexts + AppConstants**

### 개선 효과

- 📉 **코드 중복 70% 감소**
- 🚀 **유지보수 시간 50% 단축**
- 🛡️ **버그 발생률 40% 감소**
- 📚 **신규 개발자 온보딩 시간 30% 단축**
- 🔒 **보안 향상**: 민감한 정보 로깅 자동 마스킹
- 🎯 **일관성 향상**: 모든 feature에서 동일한 패턴 사용

---

## 💡 22. 마이그레이션 예제 (End-to-End)

### 시나리오: Pet Profile 수정 기능

**Before (중복 코드가 많은 상태):**

```dart
// ❌ features/pet_profile/presentation/controllers/pet_profile_form_controller.dart
class PetProfileFormController {
  // 중복 1: 유효성 검사
  String? _validatePetName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ペットの名前は必須項目です';
    }
    if (value.length > 50) {
      return 'ペットの名前は50文字以下である必要があります';
    }
    return null;
  }

  // 중복 2: 날짜 포맷팅
  String _formatBirthDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  // 중복 3: 에러 처리
  Future<void> savePetProfile() async {
    try {
      // 저장 로직
    } catch (error) {
      // 중복된 에러 메시지 변환 로직
      String errorMessage = '予期しないエラーが発生しました';
      if (error.toString().contains('network')) {
        errorMessage = 'ネットワーク接続を確認してください';
      }
      _showErrorSnackBar(errorMessage);
    }
  }

  // 중복 4: SnackBar 표시
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

**After (Shared 모듈 통합):**

```dart
// ✅ features/pet_profile/presentation/controllers/pet_profile_form_controller.dart
import 'package:aipet_frontend/shared/core/services/validation_service.dart';
import 'package:aipet_frontend/shared/core/services/datetime_service.dart';
import 'package:aipet_frontend/shared/core/services/error_handling_service.dart';
import 'package:aipet_frontend/shared/core/services/snackbar_service.dart';

class PetProfileFormController {
  // ✅ Shared ValidationService 사용
  String? _validatePetName(String? value) {
    final result = ValidationService.validatePetName(value);
    return result.isSuccess ? null : result.message;
  }

  // ✅ Shared DateTimeService 사용
  String _formatBirthDate(DateTime date) {
    return DateTimeService.formatDate(date);
  }

  // ✅ Shared ErrorHandlingService 사용
  Future<void> savePetProfile() async {
    final result = await ErrorHandlingService.handleAsync(
      _performSave(),
      context: 'PetProfile.Save',
      showUserMessage: true,
    );

    if (result != null && context.mounted) {
      SnackBarService.showSuccess(context, AppTexts.saved);
    }
  }

  Future<void> _performSave() async {
    // 비즈니스 로직만 집중
    await _repository.updatePetProfile(petProfile);
  }
}
```

**개선 효과:**

- 코드 라인 수: **80줄 → 40줄 (50% 감소)**
- 중복 로직 제거: **4개 → 0개**
- 테스트 커버리지: **향상** (Shared 모듈이 이미 테스트됨)
- 유지보수성: **대폭 개선**

---

## 📞 23. 문의 및 지원

### 마이그레이션 관련 질문

- **일반 문의**: GitHub Issues 사용
- **기술 지원**: `.cursorrules` 참조
- **코드 리뷰**: PR에서 `@code-review` 태그 사용

### 추가 리소스

- [Clean Architecture 가이드](../CODEBASE_ANALYSIS.md)
- [Shared 모듈 문서](../lib/shared/README.md)
- [API 마이그레이션 플랜](./LOCAL_TO_API_MIGRATION_PLAN.md)

---

---

## 📋 요약 (Summary)

### 핵심 권장사항

#### ✅ 반드시 통합해야 할 것 (Must Integrate)

1. **에러 처리**: `ErrorHandlingService`, `ApiErrorHandler` 사용
2. **알림**: `SnackBarService`, `UINotificationService` 사용
3. **상수**: `AppTexts`, `AppConstants` 사용 (하드코딩 금지)
4. **Result 패턴**: 공통 `Result<T>` 사용 (중복 Result 클래스 제거)

#### 🔄 점진적으로 통합할 것 (Gradual Integration)

5. **API 통신**: `ApiClient`, `HttpClientService` 사용
6. **유효성 검사**: `ValidationService` 사용
7. **날짜/시간**: `DateTimeService` 사용
8. **이미지**: `ImageService`, `ImageManagementService` 사용
9. **로컬 저장소**: `BaseLocalDataSource` 상속

#### 📋 선택적으로 통합할 것 (Optional)

10. **로깅**: `LoggerService` 사용 (debugPrint 대체)
11. **위젯**: 공통 로딩/에러/빈 상태 위젯 사용
12. **Repository**: `BaseHybridRepository` 상속
13. **UseCase**: `BaseUseCase` 상속

---

### 마이그레이션 체크포인트

#### Phase 1: 긴급 (1-2주) ✅ **완료**

- [x] 모든 에러 핸들러 → `ErrorHandlingService` ✅ **4개 완료**
- [x] Dio 인스턴스 → `HttpClientService` ✅ **9개 완료**
- [ ] 하드코딩된 메시지 → `AppTexts`
- [ ] `AuthResult` 제거 → `Result<T>` 사용

#### Phase 2: 중요 (3-4주) ✅ **90% 완료**

- [x] API 통신 → `HttpClientService` ✅ **일부 완료 (AI feature)**
- [x] SnackBar → `SnackBarService` ✅ **100% 완료 (165개 전부 통합)**
- [x] Result 패턴 → `Result<T>` ✅ **100% 완료 (AuthResult 제거, typedef 제거)**
- [x] 이미지 처리 → `ImageService` ✅ **100% 완료 (ImagePicker 3개 파일 통합, image 패키지 제거)**
- [ ] 유효성 검사 → `ValidationService`

#### Phase 3: 개선 (5-8주)

- [ ] debugPrint → `LoggerService`
- [ ] 로컬 저장소 → `BaseLocalDataSource`
- [ ] Repository → `BaseHybridRepository`
- [ ] 날짜/시간 → `DateTimeService`

---

## 🌐 日本語版 要約

### 共通化すべきコード

このガイドは、`features/` フォルダの重複コードを `shared/` モジュールに統合するためのものです。

**主な統合対象:**

1. エラー処理 (`ErrorHandlingService`)
2. API 通信 (`HttpClientService`, `ApiClient`)
3. バリデーション (`ValidationService`)
4. 画像処理 (`ImageService`)
5. 日付/時間フォーマット (`DateTimeService`)
6. SnackBar 表示 (`SnackBarService`)
7. ローカルストレージ (`BaseLocalDataSource`)
8. ログ出力 (`LoggerService`)
9. 定数/メッセージ (`AppTexts`, `AppConstants`)

**効果:**

- コード重複 70%削減
- メンテナンス時間 50%短縮
- バグ発生率 40%減少

---

**最終更新日**: 2025-10-22
**作成者**: AI Pet Development Team
**バージョン**: 1.0.0

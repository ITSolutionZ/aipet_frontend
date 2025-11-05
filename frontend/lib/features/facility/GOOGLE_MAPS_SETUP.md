# Google Maps API 설정 가이드

## 개요

`facility` 기능은 Google Maps Places API를 사용하여 실제 동물병원 및 동물 관련 시설 정보를 검색합니다.

## API 키 발급 및 설정

### 1. Google Cloud Console에서 API 키 발급

1. [Google Cloud Console](https://console.cloud.google.com/)에 접속
2. 프로젝트 선택 또는 새 프로젝트 생성
3. **APIs & Services** > **Credentials**로 이동
4. **Create Credentials** > **API Key** 선택
5. API 키 생성 완료

### 2. Places API 활성화

1. **APIs & Services** > **Library**로 이동
2. "Places API" 검색
3. **Places API** 활성화
4. **Maps SDK for Android** 활성화 (Android용)
5. **Maps SDK for iOS** 활성화 (iOS용)

### 3. API 키 제한 설정 (보안)

#### 애플리케이션 제한

- **Android 앱**: 패키지명과 SHA-1 인증서 지문 추가
- **iOS 앱**: Bundle Identifier 추가

#### API 제한

- **Places API** 선택
- **Maps SDK for Android** 선택
- **Maps SDK for iOS** 선택

### 4. 코드에 API 키 설정

#### 방법 1: 코드에 직접 설정 (개발용)

```dart
// lib/features/facility/data/services/google_places_service.dart
static const String _apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
```

#### 방법 2: 환경변수 사용 (권장)

```dart
// lib/features/facility/data/services/google_places_service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

static String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
```

`.env` 파일 생성:

```env
GOOGLE_MAPS_API_KEY=YOUR_ACTUAL_API_KEY_HERE
```

#### 방법 3: Secure Storage 사용 (프로덕션용)

```dart
// lib/features/facility/data/services/google_places_service.dart
import 'package:aipet_frontend/shared/core/services/secure_storage_service.dart';

static Future<String> get _apiKey async {
  return await SecureStorageService.getString('google_maps_api_key') ?? '';
}
```

## Android 설정

### AndroidManifest.xml 설정

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <application>
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
  </application>
</manifest>
```

## iOS 설정

### AppDelegate.swift 설정

```swift
// ios/Runner/AppDelegate.swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 사용 가능한 API

### 1. Nearby Search

- `searchNearbyVeterinary()` - 동물병원 검색
- `searchNearbyGrooming()` - 펫 미용실 검색
- `searchNearbyPetShop()` - 펫샵 검색
- `searchNearbyPetCafe()` - 펫카페 검색
- `searchNearbyPetPark()` - 도그런/펫파크 검색

### 2. Text Search

- `textSearch()` - 키워드로 시설 검색

### 3. Place Details

- `getPlaceDetails()` - 시설 상세 정보 가져오기

### 4. 통합 검색

- `searchAllPetFacilities()` - 모든 동물 관련 시설 검색

## 비용 최적화

### 캐시 전략

- 검색 결과는 자동으로 로컬 저장소에 캐시됨
- 캐시된 데이터를 우선 사용하여 API 호출 최소화

### API 호출 제한

- 로컬 결과가 5개 이상이면 API 호출 생략
- 중복 검색 방지

### 무료 할당량

- Places API: 월 $200 무료 크레딧
- Nearby Search: 요청당 $0.032
- Text Search: 요청당 $0.032
- Place Details: 요청당 $0.017

## 테스트

### 실제 API 테스트

```dart
// 현재 위치에서 동물병원 검색
final position = await GooglePlacesService.getCurrentLocation();
final facilities = await GooglePlacesService.searchNearbyVeterinary(
  latitude: position.latitude,
  longitude: position.longitude,
);
```

### Mock 데이터 사용 (API 키 없이 테스트)

API 키가 설정되지 않은 경우, 로컬 저장소의 캐시 데이터만 사용됩니다.

## 주의사항

1. **API 키 보안**: API 키를 Git에 커밋하지 마세요
2. **.gitignore 설정**: `.env` 파일을 `.gitignore`에 추가
3. **비용 모니터링**: Google Cloud Console에서 API 사용량 모니터링
4. **제한 설정**: 일일 할당량 제한 설정 권장

## 문제 해결

### API 키 오류

```text
Error: REQUEST_DENIED
```

→ Places API가 활성화되어 있는지 확인

### 권한 오류

```text
Error: PERMISSION_DENIED
```

→ API 키에 올바른 애플리케이션 제한이 설정되어 있는지 확인

### 검색 결과 없음

```text
No results found
```

→ 검색 반경을 늘리거나 다른 키워드 사용

## 참고 자료

- [Google Places API Documentation](https://developers.google.com/maps/documentation/places/web-service)
- [Places API Pricing](https://developers.google.com/maps/documentation/places/web-service/usage-and-billing)
- [google_maps_flutter Package](https://pub.dev/packages/google_maps_flutter)

# 앱 아이콘 변경 가이드

## 완료된 작업

1. **pubspec.yaml 설정 추가**
   - `flutter_launcher_icons` 패키지 추가 (v0.13.1)
   - 아이콘 설정 추가:
     ```yaml
     flutter_launcher_icons:
       android: true
       ios: true
       image_path: "assets/icons/logos/aipet_logo.png"
       min_sdk_android: 21
       remove_alpha_ios: true
     ```

2. **앱 이름 변경**
   - Android: `android/app/src/main/AndroidManifest.xml`에서 "AIPet"으로 변경
   - iOS: `ios/Runner/Info.plist`에서 CFBundleDisplayName과 CFBundleName을 "AIPet"으로 변경

## 실행 필요한 명령어

터미널에서 다음 명령어를 순서대로 실행하세요:

```bash
# 1. 패키지 설치
flutter pub get

# 2. 앱 아이콘 생성
dart run flutter_launcher_icons

# 3. 빌드 캐시 정리 (선택사항)
flutter clean
flutter pub get

# 4. iOS 프로젝트 업데이트 (Mac에서만)
cd ios
pod install
cd ..
```

## 결과

- Android: `android/app/src/main/res/mipmap-*` 폴더에 새로운 아이콘이 생성됩니다
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset` 폴더의 아이콘이 업데이트됩니다

## 주의사항

- 아이콘 이미지는 1024x1024 픽셀 이상의 정사각형 이미지를 권장합니다
- iOS의 경우 투명 배경이 제거됩니다 (`remove_alpha_ios: true`)
- 변경 후 앱을 다시 빌드해야 아이콘이 적용됩니다

## 확인 방법

```bash
# Android 실행
flutter run

# iOS 실행 (Mac에서만)
flutter run -d ios
```

앱이 실행되면 홈 화면에서 새로운 AIPet 아이콘과 이름을 확인할 수 있습니다.
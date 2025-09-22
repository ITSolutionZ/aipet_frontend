# 🚀 Mockito 프로덕션 청소 가이드

## 🎯 목표

프로덕션 배포 시 Mockito 코드를 **한번에 깔끔하게 제거**합니다.

## 🧹 청소 방법

### 1단계: Mockito 폴더 삭제

```bash
# 이 명령어 하나로 모든 Mockito 코드 제거
rm -rf lib/shared/mock_data/mockito/
```

### 2단계: Provider 정리 (자동)

Provider에서 MockConfig.shouldUseMock이 false가 되면 자동으로 Real Repository 사용:

```dart
// lib/features/auth/data/auth_providers.dart
@riverpod
AuthRepository authRepository(Ref ref) {
  if (MockConfig.shouldUseMock) {
    return _createMockAuthRepository(); // ← 이 부분이 제거됨
  }
  return AuthRepositoryImpl(...); // ← Real 구현체 사용
}
```

### 3단계: 확인

```bash
# 빌드 테스트
flutter clean
flutter pub get
flutter analyze
flutter build apk
```

## 📋 체크리스트

- [ ] `rm -rf lib/shared/mock_data/mockito/` 실행
- [ ] Flutter analyze 통과 확인
- [ ] 빌드 성공 확인
- [ ] Real API 호출 확인

## 🔄 롤백 (필요시)

Git에서 mockito 폴더 복원:

```bash
git checkout HEAD~1 lib/shared/mock_data/mockito/
```

## 🎉 결과

✅ **UI/Logic 코드 변경 없음**
✅ **한번에 깔끔한 제거**
✅ **자동으로 Real API 사용**
✅ **프로덕션 빌드 크기 감소**
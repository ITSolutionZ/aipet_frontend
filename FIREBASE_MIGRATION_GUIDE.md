# Firebase 마이그레이션 가이드

이 문서는 백엔드 API에서 Firebase Firestore로 전환하는 방법을 설명합니다.

## 📋 목차

1. [개요](#개요)
2. [설정](#설정)
3. [사용 방법](#사용-방법)
4. [Firebase 보안 규칙](#firebase-보안-규칙)
5. [마이그레이션 체크리스트](#마이그레이션-체크리스트)

## 개요

### 변경 사항

- **이전**: 백엔드 API 서버 (Dio/HTTP)를 통한 데이터 통신
- **이후**: Firebase Firestore를 통한 직접 데이터 통신

### 장점

- ✅ 서버 관리 불필요
- ✅ 실시간 동기화 지원
- ✅ 자동 확장성
- ✅ 오프라인 지원 (자동 캐싱)
- ✅ Firebase 인증과 통합

### 단점

- ⚠️ Firebase 비용 (사용량 기반)
- ⚠️ 복잡한 쿼리 제한
- ⚠️ 서버 사이드 로직 제한

## 설정

### 1. 패키지 설치

`pubspec.yaml`에 다음 패키지가 추가되었습니다:

```yaml
dependencies:
  cloud_firestore: ^5.4.4
```

패키지 설치:

```bash
cd frontend
flutter pub get
```

### 2. Firebase 프로젝트 설정

Firebase Console에서 다음을 확인하세요:

1. **Firestore Database 생성**
   - Firebase Console → Firestore Database → 데이터베이스 만들기
   - 프로덕션 모드 또는 테스트 모드 선택

2. **보안 규칙 설정** (아래 섹션 참조)

3. **인덱스 설정** (필요시)
   - `ownerId`와 `createdAt` 복합 인덱스 생성

## 사용 방법

### Repository 변경

`pet_profile_providers.dart`에서 Repository를 변경합니다:

```dart
@riverpod
PetProfileRepository petProfileRepository(Ref ref) {
  // Firebase Firestore 사용 (기본값)
  LoggerService.debug('🚀 [PetProfile] FirestorePetRepository (Firebase) 초기화');
  return FirestorePetRepository();

  // Backend API 사용 (주석 해제하여 사용)
  // LoggerService.debug('🚀 [PetProfile] BackendPetRepository (API) 초기화');
  // return BackendPetRepository();
}
```

### 코드 생성

Provider 코드를 재생성합니다:

```bash
cd frontend
dart run build_runner build --delete-conflicting-outputs
```

### 서비스 사용

기존 코드는 변경할 필요가 없습니다. Repository 인터페이스가 동일하므로 UseCase와 Controller는 그대로 작동합니다.

```dart
// UseCase 사용 예시 (변경 불필요)
final repository = ref.watch(petProfileRepositoryProvider);
final result = await repository.getAllPets();
```

## Firebase 보안 규칙

Firebase Console → Firestore Database → 규칙에서 다음 규칙을 설정하세요:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 펫 컬렉션
    match /pets/{petId} {
      // 읽기: 소유자만 가능
      allow read: if request.auth != null &&
                     resource.data.ownerId == request.auth.uid;

      // 생성: 로그인한 사용자만 가능, ownerId는 현재 사용자로 자동 설정
      allow create: if request.auth != null &&
                       request.resource.data.ownerId == request.auth.uid;

      // 업데이트: 소유자만 가능
      allow update: if request.auth != null &&
                       resource.data.ownerId == request.auth.uid;

      // 삭제: 소유자만 가능
      allow delete: if request.auth != null &&
                       resource.data.ownerId == request.auth.uid;
    }

    // 다른 컬렉션들도 동일한 패턴으로 설정
    match /{document=**} {
      allow read, write: if false; // 기본적으로 모든 접근 거부
    }
  }
}
```

### 보안 규칙 테스트

Firebase Console → Firestore Database → 규칙 → 시뮬레이터에서 테스트할 수 있습니다.

## 마이그레이션 체크리스트

### ✅ 완료된 작업

- [x] `cloud_firestore` 패키지 추가
- [x] `FirestorePetService` 생성
- [x] `FirestorePetRepository` 생성
- [x] Provider 설정 변경 가능하도록 구성

### 🔄 추가 작업 필요

- [ ] Firebase Console에서 Firestore Database 생성
- [ ] Firebase 보안 규칙 설정
- [ ] 기존 데이터 마이그레이션 (필요시)
- [ ] 테스트 환경에서 검증
- [ ] 프로덕션 배포 전 최종 테스트

### 📝 다른 Feature 마이그레이션

다른 Feature도 동일한 패턴으로 마이그레이션할 수 있습니다:

1. `Firestore[Feature]Service` 생성
2. `Firestore[Feature]Repository` 생성
3. Provider에서 Repository 변경

예시:
- `FirestoreWalkService` (산책 기록)
- `FirestoreHealthService` (건강 기록)
- `FirestoreScheduleService` (일정 관리)

## 트러블슈팅

### 에러: "Missing or insufficient permissions"

- Firebase 보안 규칙 확인
- 사용자가 로그인되어 있는지 확인
- `ownerId`가 올바르게 설정되었는지 확인

### 에러: "The query requires an index"

- Firebase Console → Firestore Database → 인덱스에서 인덱스 생성
- 또는 에러 메시지의 링크를 클릭하여 자동 생성

### 데이터가 보이지 않음

- Firebase Console에서 데이터 확인
- `ownerId` 필터 확인
- 로그인 사용자 ID 확인

## 참고 자료

- [Firebase Firestore 문서](https://firebase.google.com/docs/firestore)
- [Flutter Firestore 패키지](https://pub.dev/packages/cloud_firestore)
- [Firebase 보안 규칙](https://firebase.google.com/docs/firestore/security/get-started)

# Pet Profile 모듈

## 개요

Pet Profile 모듈은 AIPet 애플리케이션 내에서 반려동물 정보, 프로필 및 관련 기능을
관리하는 포괄적인 기능입니다. 이 모듈은 Clean Architecture 원칙을 따르며
feature-first 방식으로 구성되어 있습니다.

## 아키텍처

### 디렉토리 구조

```text
pet_profile/
├── data/                         # 데이터 레이어
│   ├── models/                   # API/DB용 데이터 모델
│   │   ├── pet_profile_api_model.dart
│   │   └── pet_profile_model.dart
│   ├── repositories/             # Repository 구현체
│   │   ├── hybrid_pet_profile_repository.dart
│   │   └── pet_profile_repository_impl.dart
│   └── services/                 # 외부 API 서비스
│       ├── pet_api_service.dart
│       └── pet_image_upload_service.dart
├── domain/                       # 도메인 레이어
│   ├── entities/                 # 비즈니스 엔티티
│   │   └── pet_profile_entity.dart
│   ├── repositories/             # Repository 인터페이스
│   │   └── pet_profile_repository.dart
│   └── usecases/                 # 비즈니스 로직
│       ├── create_pet_usecase.dart
│       ├── delete_pet_usecase.dart
│       ├── get_all_pets_usecase.dart
│       ├── get_pet_profile_usecase.dart
│       └── update_pet_usecase.dart
└── presentation/                 # 프레젠테이션 레이어
    ├── controllers/              # Riverpod 컨트롤러
    │   ├── link_registration_controller.dart
    │   ├── pet_edit_controller.dart
    │   ├── pet_profile_core_controller.dart
    │   └── pet_profile_form_controller.dart
    ├── screens/                  # 화면 위젯
    │   ├── link_registration_screen.dart
    │   └── pet_profile_screen.dart
    └── widgets/                  # 기능별 위젯
        ├── profile_editing/
        ├── profile_header/
        ├── profile_tabs/
        └── tabs/
```

## 주요 기능

### 핵심 기능

- **반려동물 프로필 관리**: 반려동물 프로필에 대한 완전한 CRUD 작업
- **이미지 관리**: 반려동물 사진을 위한 카메라 및 갤러리 통합
- **링크 등록**: QR 코드 및 링크 기반 반려동물 등록
- **프로필 편집**: 포괄적인 반려동물 정보 편집
- **데이터 동기화**: 하이브리드 로컬/원격 데이터 관리

### 주요 컴포넌트

#### 1. Pet Profile Entity

반려동물 프로필을 나타내는 중심 비즈니스 엔티티:

```dart
class PetProfileEntity {
  final String id;
  final String name;
  final String type;
  final String breed;
  final String gender;
  final double weight;
  final DateTime birthDate;
  final String? imagePath;
  final Map<String, dynamic>? additionalInfo;
  // ... 추가 속성들
}
```

#### 2. CRUD 컨트롤러

`PetProfileCoreController`는 모든 기본 CRUD 작업을 처리합니다:

- **생성**: `create(PetProfileEntity entity)`
- **조회**: `getById(String id)` 및 `getAll()`
- **수정**: `update(PetProfileEntity entity)`
- **삭제**: `delete(String id)`

#### 3. 이미지 관리 시스템

통합된 카메라 및 갤러리 기능:

```dart
// 카메라 촬영
await ImageService.pickFromCamera(context);

// 갤러리 선택
await ImageService.pickFromGallery(context);

// 포괄적인 이미지 타입 지원
ImageType.file    // 카메라/갤러리 이미지
ImageType.asset   // 기본 반려동물 이미지
ImageType.network // API 이미지
```

## 상태 관리

### Riverpod 통합

모듈은 다음 프로바이더를 사용하여 Riverpod으로 상태를 관리합니다:

```dart
// 핵심 CRUD 작업
final petProfileCoreControllerProvider = StateNotifierProvider<
  PetProfileCoreController, AsyncValue<List<PetProfileEntity>>>();

// 프로필 편집
final petEditControllerProvider =
  StateNotifierProvider<PetEditController, PetEditState>();

// 폼 관리
final petProfileFormControllerProvider =
  StateNotifierProvider<PetProfileFormController, PetProfileFormState>();

// 기본 정보 탭
final petBasicInfoTabProvider = StateNotifierProvider.family<
  PetBasicInfoTabController, PetBasicInfoTabState, String>();
```

### 상태 흐름

1. **데이터 가져오기**: Repository → UseCase → Controller → UI
2. **사용자 액션**: UI → Controller → UseCase → Repository → API/DB
3. **상태 업데이트**: Riverpod 감시자를 통한 자동 UI 재구축

## API 통합

### Pet API Service

`PetApiService`는 포괄적인 API 엔드포인트를 제공합니다:

```dart
// 기본 CRUD 작업
Future<ResultState<List<PetProfileApiModel>>> getAllPets(
  {int page, int limit}
);
Future<ResultState<PetProfileApiModel>> getPetById(String petId);
Future<ResultState<PetProfileApiModel>> createPet(
  PetProfileCreateRequest request
);
Future<ResultState<PetProfileApiModel>> updatePet(
  String petId,
  PetProfileUpdateRequest request
);
Future<ResultState<void>> deletePet(String petId);

// 고급 기능
Future<ResultState<PetImageUploadResponse>> uploadPetImage(
  String petId, File imageFile
);
Future<ResultState<List<PetProfileApiModel>>> searchPets(
  {String? name, String? type}
);
Future<ResultState<void>> bulkUpdatePets(
  List<PetProfileUpdateRequest> updates
);
```

### 하이브리드 Repository 패턴

모듈은 로컬과 원격 데이터 소스 간을 원활하게 전환하는 하이브리드 repository를
구현합니다:

```dart
class HybridPetProfileRepository implements PetProfileRepository {
  // 오프라인 시 로컬 저장소로 자동 폴백
  // 온라인 시 원격 API와 동기화
  // 더 나은 UX를 위한 낙관적 업데이트
}
```

## UI 컴포넌트

### 화면 컴포넌트

#### Pet Profile Screen

주요 프로필 조회 및 편집 인터페이스:

- **프로필 헤더**: 반려동물 이미지, 이름 및 기본 정보
- **탭 인터페이스**: 정리된 정보 섹션
- **편집 모드**: 검증과 함께 제자리 편집
- **액션 버튼**: 저장, 취소, 삭제 작업

#### Link Registration Screen

QR 코드 및 링크 기반 반려동물 등록:

- **링크 입력**: 검증 및 처리
- **QR 스캐너**: 카메라 기반 QR 코드 읽기
- **등록 플로우**: 단계별 반려동물 추가

### 위젯 컴포넌트

#### 프로필 편집 위젯

- **Pet Profile Image Picker**: 카메라/갤러리/기본 이미지 선택
- **Profile Edit Controller**: 폼 상태 관리
- **Image Selection Dialog**: 기본 반려동물 이미지 브라우저

#### 프로필 헤더 위젯

- **Pet Selection Widget**: 다중 반려동물 전환 인터페이스
- **Pet Selection Modal**: 검색 기능이 있는 반려동물 브라우저

#### 탭 위젯

- **Pet Basic Info Tab**: 인라인 편집 기능이 있는 핵심 반려동물 정보
- **About Tab Widget**: 상세한 반려동물 설명 및 특성

## 테스팅

### 테스트 커버리지

- **단위 테스트**: 컨트롤러, 유스케이스, repository
- **위젯 테스트**: UI 컴포넌트 및 상호작용
- **통합 테스트**: 엔드투엔드 사용자 플로우

### Mock 데이터

개발 및 테스트를 위한 포괄적인 Mock 데이터:

```dart
// 개발용 Mock 반려동물 프로필
final mockPetProfiles = [
  PetProfileEntity(
    id: 'pet_1',
    name: 'しば',
    type: 'Dog',
    breed: 'Shiba Inu',
    // ... 추가 속성들
  ),
];
```

## 다국어화

모듈은 일관된 메시징으로 일본어 현지화를 지원합니다:

- **성공 메시지**: "写真が選択されました"
- **오류 메시지**: "ペット情報の取得に失敗しました"
- **UI 라벨**: "写真を変更", "保存", "キャンセル"

## 오류 처리

### 포괄적인 오류 관리

```dart
// 작업을 위한 Result 패턴
Result<PetProfileEntity> result = await petRepository.getPetById(id);

if (result.isSuccess) {
  // 성공 처리
  final pet = result.dataOrNull!;
} else {
  // 오류 처리
  final error = result.message;
}
```

### 오류 유형

- **네트워크 오류**: API 연결 문제
- **검증 오류**: 폼 입력 검증
- **권한 오류**: 카메라/갤러리 접근
- **저장소 오류**: 로컬 데이터 지속성

## 성능 최적화

### 이미지 최적화

- **압축**: 자동 이미지 압축 (80% 품질)
- **크기 제한**: 최대 1000x1000px 해상도
- **캐싱**: 효율적인 이미지 캐싱 시스템

### 데이터 관리

- **페이지네이션**: page/limit 매개변수가 있는 API 응답
- **지연 로딩**: 온디맨드 데이터 가져오기
- **상태 지속성**: 오프라인 접근을 위한 로컬 저장소

## 사용 예제

### 기본 Pet Profile 표시

```dart
class PetProfileDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petProfileCoreControllerProvider);

    return pets.when(
      data: (petList) => ListView.builder(
        itemCount: petList.length,
        itemBuilder: (context, index) => PetProfileCard(pet: petList[index]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### 새 반려동물 생성

```dart
Future<void> createNewPet() async {
  final newPet = PetProfileEntity(
    id: generateId(),
    name: 'ポチ',
    type: 'Dog',
    breed: 'Golden Retriever',
    gender: 'Male',
    weight: 25.5,
    birthDate: DateTime(2022, 6, 15),
  );

  final result = await ref.read(petProfileCoreControllerProvider.notifier)
    .create(newPet);

  if (result.isSuccess) {
    // 반려동물 프로필로 이동
  } else {
    // 오류 메시지 표시
  }
}
```

### 이미지 선택

```dart
Future<void> updatePetImage() async {
  final imagePath = await ImageService.showImagePickerOptions(
    context,
    showDefaultImages: true,
    allowRemoval: true,
  );

  if (imagePath != null) {
    ref.read(petEditControllerProvider.notifier).selectImage(imagePath);
  }
}
```

## 의존성

### 필요한 패키지

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  image_picker: ^1.0.7
  dio: ^5.4.3+1
  shared_preferences: ^2.2.2
  permission_handler: ^11.3.1
```

### 내부 의존성

- **Shared 모듈**: 공통 유틸리티 및 서비스
- **Core Services**: 이미지 관리, API 클라이언트
- **UI Components**: 재사용 가능한 위젯 및 테마

## 향후 개선사항

### 계획된 기능

- **AI 통합**: 스마트 반려동물 품종 인식
- **소셜 기능**: 반려동물 프로필 공유
- **건강 추적**: 의료 기록 통합
- **캘린더 통합**: 반려동물 관리 일정

### 기술적 개선

- **오프라인 동기화**: 향상된 오프라인 데이터 동기화
- **성능**: 추가 캐싱 및 최적화
- **테스팅**: 확장된 테스트 커버리지
- **접근성**: 향상된 접근성 지원

## 기여하기

### 코드 스타일

- 프로젝트의 Clean Architecture 패턴을 따르세요
- 상태 관리에 Riverpod 사용
- 포괄적인 오류 처리 구현
- 비즈니스 로직에 대한 단위 테스트 작성
- 공개 API 문서화

### Pull Request 프로세스

1. `main`에서 기능 브랜치 생성
2. 테스트와 함께 변경 사항 구현
3. 린팅 및 포맷팅 실행
4. 문서 업데이트
5. 설명과 함께 pull request 제출

## 변경 로그

### 버전 1.0.0

- Pet profile 모듈의 초기 구현
- 완전한 CRUD 작업
- 카메라 및 갤러리 통합
- 링크 등록 기능
- 포괄적인 상태 관리
- 일본어 현지화
- 오류 처리 및 검증

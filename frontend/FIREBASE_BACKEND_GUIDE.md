# 🔥 Firebase 백엔드 전환 가이드

현재 AIPet 앱은 **하이브리드 백엔드 구조**를 사용하고 있습니다:
- **인증 (Auth)**: Firebase Authentication ✅
- **데이터 저장**: 백엔드 API + 로컬 SQLite

이 가이드는 **전체 백엔드를 Firebase로 전환**하는 방법을 설명합니다.

---

## 📊 현재 아키텍처

```
┌─────────────┐
│ Flutter App │
└──────┬──────┘
       │
   ┌───┴────────────────────┐
   │                        │
┌──▼────────────┐  ┌────────▼─────┐
│ Firebase Auth │  │ Backend API  │
│   (인증)       │  │ (펫 데이터)   │
└───────────────┘  └──────────────┘
                          │
                   ┌──────▼───────┐
                   │  PostgreSQL  │
                   └──────────────┘
```

## 🎯 목표 아키텍처 (Firebase Only)

```
┌─────────────┐
│ Flutter App │
└──────┬──────┘
       │
   ┌───┴──────────────┐
   │                  │
┌──▼────────────┐  ┌──▼──────────┐
│ Firebase Auth │  │  Firestore  │
│   (인증)       │  │ (펫 데이터)  │
└───────────────┘  └─────────────┘
```

---

## 🚀 전환 단계

### 1단계: Firebase 프로젝트 설정 확인

#### 1.1 Firebase Console에서 Firestore 활성화

```bash
# Firebase Console 접속
https://console.firebase.google.com/project/your-project-id

# Firestore Database 활성화
1. 왼쪽 메뉴에서 "Firestore Database" 선택
2. "데이터베이스 만들기" 클릭
3. "프로덕션 모드로 시작" 선택 (나중에 규칙 수정 가능)
4. 위치: asia-northeast3 (서울) 또는 asia-northeast1 (도쿄)
```

#### 1.2 Firestore 보안 규칙 설정

```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 인증된 사용자만 자신의 데이터에 접근 가능
    match /pets/{petId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == resource.data.ownerId;
      allow create: if request.auth != null;
    }

    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

### 2단계: 의존성 추가

#### 2.1 pubspec.yaml 수정

```yaml
dependencies:
  # Firebase Core (이미 있음)
  firebase_core: ^3.15.2
  firebase_auth: ^5.1.4

  # 🆕 Firestore 추가
  cloud_firestore: ^5.5.0

  # 🆕 Firebase Storage (이미지 업로드용)
  firebase_storage: ^12.3.4
```

#### 2.2 패키지 설치

```bash
flutter pub get
```

### 3단계: Firestore 데이터 모델 생성

#### 3.1 Pet 데이터 구조

```dart
// lib/features/pet_profile/data/models/firestore_pet_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePetModel {
  final String id;
  final String name;
  final String type;
  final String? breed;
  final DateTime birthDate;
  final String gender;
  final double weight;
  final String? imagePath;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Firestore로부터 변환
  factory FirestorePetModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return FirestorePetModel(
      id: snapshot.id,
      name: data['name'] as String,
      type: data['type'] as String,
      breed: data['breed'] as String?,
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      gender: data['gender'] as String,
      weight: (data['weight'] as num).toDouble(),
      imagePath: data['imagePath'] as String?,
      ownerId: data['ownerId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Firestore로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'breed': breed,
      'birthDate': Timestamp.fromDate(birthDate),
      'gender': gender,
      'weight': weight,
      'imagePath': imagePath,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
```

### 4단계: Firestore Repository 구현

#### 4.1 Firestore Pet Repository

```dart
// lib/features/pet_profile/data/repositories/firestore_pet_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestorePetRepository implements PetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Result.failure('ログインが必要です');
      }

      // Firestore에 펫 데이터 추가
      final docRef = await _firestore.collection('pets').add({
        'name': pet.name,
        'type': pet.type,
        'breed': pet.breed,
        'birthDate': Timestamp.fromDate(pet.birthDate),
        'gender': pet.gender,
        'weight': pet.weight,
        'imagePath': pet.imagePath,
        'ownerId': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 생성된 ID로 펫 엔티티 업데이트
      final createdPet = pet.copyWith(id: docRef.id);

      return Result.success('ペットを登録しました', createdPet);
    } catch (e) {
      return Result.failure('ペット登録に失敗しました: $e');
    }
  }

  @override
  Future<Result<List<PetProfileEntity>>> getPets() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Result.failure('ログインが必要です');
      }

      // 현재 사용자의 펫 목록 가져오기
      final querySnapshot = await _firestore
          .collection('pets')
          .where('ownerId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final pets = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return PetProfileEntity(
          id: doc.id,
          name: data['name'] as String,
          type: data['type'] as String,
          breed: data['breed'] as String?,
          birthDate: (data['birthDate'] as Timestamp).toDate(),
          gender: data['gender'] as String,
          weight: (data['weight'] as num).toDouble(),
          imagePath: data['imagePath'] as String?,
          ownerId: data['ownerId'] as String,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        );
      }).toList();

      return Result.success('ペット一覧を取得しました', pets);
    } catch (e) {
      return Result.failure('ペット一覧の取得に失敗しました: $e');
    }
  }

  @override
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet) async {
    try {
      await _firestore.collection('pets').doc(pet.id).update({
        'name': pet.name,
        'type': pet.type,
        'breed': pet.breed,
        'birthDate': Timestamp.fromDate(pet.birthDate),
        'gender': pet.gender,
        'weight': pet.weight,
        'imagePath': pet.imagePath,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Result.success('ペット情報を更新しました', pet);
    } catch (e) {
      return Result.failure('ペット情報の更新に失敗しました: $e');
    }
  }

  @override
  Future<Result<void>> deletePet(String petId) async {
    try {
      await _firestore.collection('pets').doc(petId).delete();
      return Result.success('ペットを削除しました');
    } catch (e) {
      return Result.failure('ペットの削除に失敗しました: $e');
    }
  }
}
```

### 5단계: Provider 설정 변경

#### 5.1 Pet Repository Provider 수정

```dart
// lib/features/pet_profile/data/pet_providers.dart

// Before: 백엔드 API 사용
final petRepositoryProvider = Provider<PetRepository>((ref) {
  return BackendPetRepository(); // ❌ 백엔드 API
});

// After: Firestore 사용
final petRepositoryProvider = Provider<PetRepository>((ref) {
  return FirestorePetRepository(); // ✅ Firestore
});
```

### 6단계: 이미지 업로드 (Firebase Storage)

#### 6.1 Firebase Storage 서비스

```dart
// lib/shared/services/firebase_storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 펫 프로필 이미지 업로드
  Future<Result<String>> uploadPetImage(
    File imageFile,
    String petId,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Result.failure('ログインが必要です');
      }

      // 이미지 경로: pets/{userId}/{petId}/profile.jpg
      final ref = _storage
          .ref()
          .child('pets')
          .child(currentUser.uid)
          .child(petId)
          .child('profile.jpg');

      // 이미지 업로드
      await ref.putFile(imageFile);

      // 다운로드 URL 가져오기
      final downloadUrl = await ref.getDownloadURL();

      return Result.success('画像をアップロードしました', downloadUrl);
    } catch (e) {
      return Result.failure('画像のアップロードに失敗しました: $e');
    }
  }

  /// 이미지 삭제
  Future<Result<void>> deletePetImage(String petId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Result.failure('ログインが必要です');
      }

      final ref = _storage
          .ref()
          .child('pets')
          .child(currentUser.uid)
          .child(petId)
          .child('profile.jpg');

      await ref.delete();

      return Result.success('画像を削除しました');
    } catch (e) {
      return Result.failure('画像の削除に失敗しました: $e');
    }
  }
}
```

### 7단계: 데이터 마이그레이션

#### 7.1 로컬 데이터를 Firestore로 마이그레이션

```dart
// lib/shared/services/data_migration_service.dart
class DataMigrationService {
  final FirestorePetRepository _firestoreRepo = FirestorePetRepository();
  final LocalPetService _localService = LocalPetService();

  /// 로컬 펫 데이터를 Firestore로 마이그레이션
  Future<Result<void>> migratePetsToFirestore() async {
    try {
      print('🔄 [Migration] 로컬 데이터 마이그레이션 시작');

      // 1. 로컬 펫 데이터 가져오기
      final localPets = await _localService.getAllPets();

      if (localPets.isEmpty) {
        print('📭 [Migration] 마이그레이션할 데이터 없음');
        return Result.success('마이그레이션할 데이터가 없습니다');
      }

      print('📦 [Migration] ${localPets.length}개의 펫 마이그레이션 중...');

      // 2. 각 펫을 Firestore로 업로드
      int successCount = 0;
      int failCount = 0;

      for (final localPet in localPets) {
        final petEntity = _convertToPetEntity(localPet);
        final result = await _firestoreRepo.createPet(petEntity);

        if (result.isSuccess) {
          successCount++;
          print('✅ [Migration] ${petEntity.name} 업로드 성공');
        } else {
          failCount++;
          print('❌ [Migration] ${petEntity.name} 업로드 실패: ${result.error}');
        }
      }

      print('🎉 [Migration] 완료: 성공 $successCount, 실패 $failCount');

      // 3. 마이그레이션 성공 시 로컬 데이터 삭제 (선택사항)
      if (successCount == localPets.length) {
        await _localService.clearAllPets();
        print('🧹 [Migration] 로컬 데이터 정리 완료');
      }

      return Result.success('マイグレーションが完了しました');
    } catch (e) {
      print('❌ [Migration] 에러: $e');
      return Result.failure('マイグレーションに失敗しました: $e');
    }
  }
}
```

### 8단계: 앱 시작 시 자동 마이그레이션

#### 8.1 Bootstrap에서 마이그레이션 실행

```dart
// lib/app/bootstrap.dart
static Future<void> initialize() async {
  // ... 기존 초기화 코드 ...

  // Firebase 초기화 후 데이터 마이그레이션
  if (isFirebaseInitialized) {
    // 로그인 상태 확인
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // 마이그레이션 실행 (백그라운드)
      unawaited(
        DataMigrationService().migratePetsToFirestore().then((result) {
          if (result.isSuccess) {
            print('✅ 데이터 마이그레이션 완료');
          } else {
            print('⚠️ 데이터 마이그레이션 실패: ${result.error}');
          }
        }),
      );
    }
  }
}
```

---

## 🔧 전환 체크리스트

### Firebase Console 설정
- [ ] Firestore Database 활성화
- [ ] Firebase Storage 활성화
- [ ] Firestore 보안 규칙 설정
- [ ] Storage 보안 규칙 설정

### 코드 변경
- [ ] `cloud_firestore` 패키지 추가
- [ ] `firebase_storage` 패키지 추가
- [ ] `FirestorePetRepository` 구현
- [ ] `FirebaseStorageService` 구현
- [ ] Provider 설정 변경
- [ ] 데이터 마이그레이션 코드 작성

### 테스트
- [ ] 로컬에서 Firestore 연동 테스트
- [ ] 펫 생성/조회/수정/삭제 테스트
- [ ] 이미지 업로드/다운로드 테스트
- [ ] 데이터 마이그레이션 테스트
- [ ] TestFlight 배포 후 실제 테스트

---

## 📊 Firestore vs 백엔드 API 비교

| 항목 | Firestore | 백엔드 API |
|------|-----------|------------|
| **비용** | 무료 티어 (50K reads/day) | 서버 유지비 |
| **확장성** | 자동 스케일링 | 수동 스케일링 |
| **복잡한 쿼리** | 제한적 | 자유로움 (SQL) |
| **실시간 동기화** | ✅ 기본 지원 | ❌ 추가 구현 필요 |
| **오프라인 지원** | ✅ 기본 지원 | ❌ 추가 구현 필요 |
| **보안** | Security Rules | 백엔드 로직 |
| **개발 속도** | 빠름 | 느림 |

---

## 🚨 주의사항

### 1. Firestore 제약사항
- 복잡한 쿼리 제한 (OR, IN 조건 등)
- 트랜잭션 제한 (최대 500개 문서)
- 인덱스 필요 (복합 쿼리 시)

### 2. 비용 관리
```
Firestore 무료 티어:
- 문서 읽기: 50,000/일
- 문서 쓰기: 20,000/일
- 문서 삭제: 20,000/일
- 저장공간: 1 GB

초과 시 과금 발생!
```

### 3. 보안 규칙 필수
```javascript
// ❌ 나쁜 예: 모든 사용자가 접근 가능
allow read, write: if true;

// ✅ 좋은 예: 소유자만 접근 가능
allow read, write: if request.auth.uid == resource.data.ownerId;
```

---

## 📚 참고 자료

- [Cloud Firestore 공식 문서](https://firebase.google.com/docs/firestore)
- [Firebase Storage 공식 문서](https://firebase.google.com/docs/storage)
- [FlutterFire 공식 문서](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

## 🎯 결론

**Firebase로 전환 시 장점:**
- ✅ 서버 관리 불필요
- ✅ 실시간 동기화 자동 지원
- ✅ 오프라인 모드 자동 지원
- ✅ 개발 속도 향상

**백엔드 API 유지 시 장점:**
- ✅ 복잡한 비즈니스 로직 처리
- ✅ SQL 쿼리 자유도
- ✅ 비용 예측 가능

**추천:**
- 📱 **MVP/Small Scale**: Firebase만 사용
- 🏢 **Enterprise/Complex**: 하이브리드 (Firebase Auth + 백엔드 API)

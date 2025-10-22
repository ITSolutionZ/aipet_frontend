# 📚 AIPet Frontend Documentation

## 개요

이 디렉토리는 AI Pet Frontend 프로젝트의 모든 기술 문서를 포함합니다.

---

## 📋 문서 목록

### 아키텍처 및 분석

- **[CODEBASE_ANALYSIS.md](./CODEBASE_ANALYSIS.md)** - 코드베이스 전체 분석 (한국어)
- **[CODEBASE_ANALYSIS_JA.md](./CODEBASE_ANALYSIS_JA.md)** - コードベース分析 (日本語)
- **[CODE_IMPROVEMENT_GUIDE.md](../document/CODE_IMPROVEMENT_GUIDE.md)** - 코드 개선 가이드 (한국어)
- **[CODE_IMPROVEMENT_GUIDE_JA.md](../document/CODE_IMPROVEMENT_GUIDE_JA.md)** - コード改善ガイド (日本語)

### 마이그레이션 가이드

- **[SHARED_CODE_MIGRATION_GUIDE.md](./SHARED_CODE_MIGRATION_GUIDE.md)** ⭐ NEW

  - `features/` → `shared/` 코드 통합 가이드
  - 중복 코드 제거 및 공통 모듈 활용
  - 실제 측정 통계 포함

- **[LOCAL_TO_API_MIGRATION_PLAN.md](./LOCAL_TO_API_MIGRATION_PLAN.md)**

  - 로컬 데이터 → API 전환 계획
  - Mock 데이터 → 실제 백엔드 연동

- **[walk_migration.md](./walk_migration.md)**
  - Walk 기능 마이그레이션 상세 가이드

### 프로젝트 자료

- **[AIPET.pptx](./AIPET.pptx)** - 프로젝트 발표 자료

---

## 🚀 빠른 시작

### 1. 새로운 Feature 개발 시

```bash
# 1. 아키텍처 가이드 확인
cat docs/CODEBASE_ANALYSIS.md

# 2. Shared 모듈 확인 (중복 코드 방지)
cat docs/SHARED_CODE_MIGRATION_GUIDE.md

# 3. .cursorrules 확인
cat .cursorrules
```

### 2. 기존 코드 리팩토링 시

```bash
# 1. 중복 코드 탐지
./scripts/find_duplicate_code.sh > migration_analysis.txt

# 2. 마이그레이션 진행 상황 체크
./scripts/check_migration_progress.sh

# 3. Shared 모듈 마이그레이션 가이드 참조
cat docs/SHARED_CODE_MIGRATION_GUIDE.md
```

---

## 📊 현재 마이그레이션 상태 (2025-10-22)

### Critical Issues (즉시 해결 필요)

- 🔴 에러 핸들러: **4개** → 목표: 0개
- 🔴 Dio 인스턴스: **9개** → 목표: 0개

### Improvements (점진적 개선)

- 🟡 SnackBar 직접 호출: **165곳** → 목표: <10곳
- 🟡 debugPrint: **1,553곳** → 목표: <50곳
- 🟡 SharedPreferences: **124곳** → 목표: <5곳

### Achievements

- 🟢 Shared 모듈 사용: **703곳** (목표: >200곳) ✅

---

## 🎯 핵심 원칙

### DRY (Don't Repeat Yourself)

- ❌ **하지 말아야 할 것**:

  - Feature마다 에러 핸들러 재정의
  - SnackBar 스타일 각자 구현
  - 유효성 검사 로직 중복
  - 날짜 포맷팅 함수 중복

- ✅ **해야 할 것**:
  - Shared 모듈의 `ErrorHandlingService` 사용
  - `SnackBarService` 일관성 있게 사용
  - `ValidationService` 재사용
  - `DateTimeService` 활용

### Clean Architecture

- **Presentation** ← `shared/ui`, `shared/widgets`
- **Domain** ← `shared/core/domain`
- **Data** ← `shared/core/data`, `shared/core/api`
- **Infrastructure** ← `shared/services`

---

## 📚 주요 Shared 모듈

### 에러 처리

```dart
import 'package:aipet_frontend/shared/core/services/error_handling_service.dart';

// 비동기 에러 자동 처리
await ErrorHandlingService.handleAsync(
  operation(),
  context: 'FeatureName.Operation',
  showUserMessage: true,
);
```

### 알림 (SnackBar)

```dart
import 'package:aipet_frontend/shared/core/services/snackbar_service.dart';

SnackBarService.showSuccess(context, '保存しました');
SnackBarService.showError(context, 'エラーが発生しました');
```

### 유효성 검사

```dart
import 'package:aipet_frontend/shared/core/services/validation_service.dart';

final result = ValidationService.validateEmail(email);
if (!result.isSuccess) {
  // 에러 처리
}
```

### API 통신

```dart
import 'package:aipet_frontend/shared/core/api/api_client.dart';
import 'package:aipet_frontend/shared/core/services/http_client_service.dart';

final response = await httpClient.get<Model>(
  endpoint,
  fromJson: (json) => Model.fromJson(json),
);
```

### 로깅

```dart
import 'package:aipet_frontend/shared/core/services/logger_service.dart';

LoggerService.info('Operation started', data: {'id': id});
LoggerService.error('Operation failed', error: error, stackTrace: stackTrace);
```

---

## 🔧 마이그레이션 도구

### 중복 코드 탐지

```bash
./scripts/find_duplicate_code.sh > analysis.txt
```

### 진행 상황 체크

```bash
./scripts/check_migration_progress.sh
```

---

## 📞 문의

- **일반 문의**: GitHub Issues
- **기술 지원**: `.cursorrules` 참조
- **코드 리뷰**: PR에서 `@code-review` 태그

---

**최종 업데이트**: 2025-10-22
**관리자**: AI Pet Development Team

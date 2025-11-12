# 📚 AIPet Documentation

## 개요

이 디렉토리는 AI Pet 프로젝트의 모든 기술 문서를 포함합니다.

---

## 📋 문서 구성

### 📁 api/ - Backend API 연동

- **[API_INTEGRATION_ANALYSIS.md](./api/API_INTEGRATION_ANALYSIS.md)** - API 통합 분석
- **[API_INTEGRATION_STATUS.md](./api/API_INTEGRATION_STATUS.md)** - API 통합 상태
- **[API_SERVICES_CREATED.md](./api/API_SERVICES_CREATED.md)** - 생성된 API 서비스
- **[BACKEND_INTEGRATION.md](./api/BACKEND_INTEGRATION.md)** - Backend 통합 가이드

### 📁 architecture/ - 아키텍처 및 설계

- **[ARCHITECTURE_SEPARATION.md](./architecture/ARCHITECTURE_SEPARATION.md)** - 아키텍처 분리 가이드

### 📁 analysis/ - 코드베이스 분석

- **[CODEBASE_ANALYSIS.md](./analysis/CODEBASE_ANALYSIS.md)** - 코드베이스 전체 분석 (한국어)
- **[CODEBASE_ANALYSIS_JA.md](./analysis/CODEBASE_ANALYSIS_JA.md)** - コードベース分析 (日本語)
- **[CODE_IMPROVEMENT_GUIDE.md](../document/CODE_IMPROVEMENT_GUIDE.md)** - 코드 개선 가이드 (한국어)
- **[CODE_IMPROVEMENT_GUIDE_JA.md](../document/CODE_IMPROVEMENT_GUIDE_JA.md)** - コード改善ガイド (日本語)

### 📁 guides/ - 개발 가이드

- **[REFACTORING_PLAN.md](./guides/REFACTORING_PLAN.md)** - 리팩토링 계획
- **[RESPONSIVE_GUIDE.md](./guides/RESPONSIVE_GUIDE.md)** - 반응형 디자인 가이드
- **[RESPONSIVE_IMPLEMENTATION.md](./guides/RESPONSIVE_IMPLEMENTATION.md)** - 반응형 구현 가이드

### 📁 마이그레이션 가이드

- **[SHARED_CODE_MIGRATION_GUIDE.md](./SHARED_CODE_MIGRATION_GUIDE.md)** ⭐
  - `features/` → `shared/` 코드 통합 가이드
  - 중복 코드 제거 및 공통 모듈 활용
  - 실제 측정 통계 포함

- **[LOCAL_TO_API_MIGRATION_PLAN.md](./LOCAL_TO_API_MIGRATION_PLAN.md)**
  - 로컬 데이터 → API 전환 계획
  - Mock 데이터 → 실제 백엔드 연동

- **[walk_migration.md](./walk_migration.md)**
  - Walk 기능 마이그레이션 상세 가이드

### 📁 프로젝트 자료

- **[AIPET.pptx](./AIPET.pptx)** - 프로젝트 발표 자료
- **[MIGRATION_PHASE1_REPORT.md](./MIGRATION_PHASE1_REPORT.md)** - 마이그레이션 페이즈 1 보고서

---

## 🏠 루트 디렉토리 문서

- **[README.md](../README.md)** - 프로젝트 메인 README
- **[CLAUDE.md](../CLAUDE.md)** - Claude AI 개발 가이드
- **[README_APP_ICON.md](../README_APP_ICON.md)** - 앱 아이콘 가이드

## 🔧 Backend 문서

Backend 관련 상세 문서는 `backend/` 디렉토리에 있습니다:

- **[backend/README.md](../backend/README.md)** - Backend 셋업 가이드
- **[backend/API_DOCS.md](../backend/API_DOCS.md)** - API 엔드포인트 문서
- **[backend/SWAGGER_GUIDE.md](../backend/SWAGGER_GUIDE.md)** - Swagger 사용 가이드
- **[backend/QUICK_START.md](../backend/QUICK_START.md)** - 빠른 시작 가이드

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

## 📦 SharedPreferences 마이그레이션 완료 (2025-10-23)

**최종 결과: 124 → 22 (82% 개선)**

### 주요 달성 사항
- ✅ Presentation Layer 완전 정리 (Clean Architecture 준수)
- ✅ Data Layer 인스턴스 재사용 패턴 적용
- ✅ 101곳 제거 성공
- ✅ 각 서비스당 1번만 getInstance() 호출

### 현재 상태
- 22개 LocalStorage 서비스에서만 SharedPreferences 사용
- 모든 인스턴스 재사용으로 성능 최적화 완료
- Clean Architecture 원칙 완전 준수

자세한 내용은 [SHARED_CODE_MIGRATION_GUIDE.md](./SHARED_CODE_MIGRATION_GUIDE.md) 참조

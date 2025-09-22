# 🏗️ Phase 4: 폴더 구조 재편성 계획

## 🎯 목표

1. **명확한 계층 구조**: 기능별, 용도별 명확한 분리
2. **의존성 최적화**: 순환 의존성 제거 및 단방향 의존성
3. **재사용성 향상**: 공통 컴포넌트의 계층화
4. **유지보수성**: 직관적이고 예측 가능한 구조

## 📁 현재 구조 분석

```
lib/shared/
├── ai_support.dart
├── branding/              # 브랜딩 (로고, 색상)
├── constants/             # 상수들
├── controllers/           # 공통 컨트롤러
├── design/                # 디자인 토큰
├── domain/                # 도메인 객체
├── foundation.dart
├── mock_data/             # Mock 시스템 (정리됨)
├── providers/             # 공통 프로바이더
├── services/              # 서비스 계층
├── shared.dart            # 메인 export
├── testing.dart           # 테스트 관련
├── ui.dart                # UI export
├── ui/                    # 새로운 통합 컴포넌트
│   └── components/        # AppButton, AppCard
├── utils/                 # 유틸리티
└── widgets/               # 기존 위젯들 (deprecated)
    ├── accessibility/
    ├── animation/
    ├── buttons/           # → ui/components/로 이동됨
    ├── cards/             # → ui/components/로 이동됨
    ├── common/
    ├── drawer/
    ├── feedback/
    ├── forms/
    ├── inputs/
    ├── layout/
    ├── modals/
    ├── navigation/
    ├── performance/
    ├── responsive/
    ├── tiles/
    └── widgets.dart
```

## 🚀 새로운 구조 (제안)

```
lib/shared/
├── core/                           # 핵심 기반 시설
│   ├── constants/                  # 앱 전역 상수
│   ├── domain/                     # 도메인 객체 & 엔티티
│   ├── services/                   # 핵심 서비스 (HTTP, Storage 등)
│   └── utils/                      # 공통 유틸리티
├── design/                         # 디자인 시스템
│   ├── tokens/                     # 디자인 토큰 (색상, 폰트, 간격)
│   ├── theme/                      # 테마 설정
│   └── branding/                   # 브랜딩 요소
├── ui/                             # UI 컴포넌트 시스템
│   ├── components/                 # 통합 컴포넌트 (AppButton, AppCard)
│   ├── patterns/                   # UI 패턴 (Screen, Form 패턴)
│   ├── layouts/                    # 레이아웃 컴포넌트
│   └── feedback/                   # 피드백 컴포넌트 (로딩, 에러)
├── foundation/                     # 기반 계층
│   ├── providers/                  # 글로벌 프로바이더
│   ├── controllers/                # 기본 컨트롤러
│   └── mixins/                     # 공통 mixin들
├── testing/                        # 테스트 지원
│   ├── mock_data/                  # Mock 시스템
│   └── helpers/                    # 테스트 헬퍼
└── shared.dart                     # 메인 export
```

## 🔄 마이그레이션 단계

### 1단계: 새로운 core/ 폴더 생성
```bash
mkdir -p lib/shared/core/{constants,domain,services,utils}
mv lib/shared/constants/* lib/shared/core/constants/
mv lib/shared/domain/* lib/shared/core/domain/
mv lib/shared/services/* lib/shared/core/services/
mv lib/shared/utils/* lib/shared/core/utils/
```

### 2단계: design/ 폴더 재구성
```bash
mkdir -p lib/shared/design/{tokens,theme}
mv lib/shared/design/color.dart lib/shared/design/tokens/
mv lib/shared/design/font.dart lib/shared/design/tokens/
mv lib/shared/design/spacing.dart lib/shared/design/tokens/
mv lib/shared/design/theme.dart lib/shared/design/theme/
mv lib/shared/branding/ lib/shared/design/
```

### 3단계: ui/ 폴더 확장
```bash
mkdir -p lib/shared/ui/{patterns,layouts,feedback}
# 기존 위젯들 중 재사용 가능한 것들을 ui/로 이동
```

### 4단계: foundation/ 폴더 생성
```bash
mkdir -p lib/shared/foundation/{providers,controllers,mixins}
mv lib/shared/providers/* lib/shared/foundation/providers/
mv lib/shared/controllers/* lib/shared/foundation/controllers/
```

### 5단계: testing/ 폴더 재구성
```bash
mkdir -p lib/shared/testing/helpers
mv lib/shared/mock_data/ lib/shared/testing/
```

### 6단계: 기존 widgets/ 폴더 정리
```bash
# deprecated된 위젯들 제거 또는 ui/로 이동
# 중복 제거된 button, card 폴더들 삭제
```

## 📋 의존성 관계

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│    core/    │◄───│ foundation/  │◄───│     ui/     │
│  (기반)      │    │  (기능 기반)   │    │ (UI 컴포넌트) │
└─────────────┘    └──────────────┘    └─────────────┘
       ▲                   ▲                   ▲
       │                   │                   │
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│  design/    │    │   testing/   │    │  features/  │
│ (디자인)     │    │  (테스트)     │    │ (앱 기능들)  │
└─────────────┘    └──────────────┘    └─────────────┘
```

## ✅ 기대 효과

### 1. **개발 생산성 향상**
- 직관적인 폴더 구조로 파일 찾기 용이
- 명확한 의존성 방향으로 순환 참조 방지
- 컴포넌트 재사용성 극대화

### 2. **유지보수성 개선**
- 기능별 명확한 분리
- 계층별 책임 분담
- 테스트 코드 조직화

### 3. **확장성 확보**
- 새로운 컴포넌트 추가 시 명확한 위치
- 디자인 시스템 확장 용이
- 팀 개발 시 충돌 최소화

### 4. **번들 크기 최적화**
- tree-shaking 최적화
- 불필요한 의존성 제거
- 레이지 로딩 지원

## 🚨 주의사항

1. **점진적 마이그레이션**: 한 번에 모든 것을 변경하지 말고 단계적으로 진행
2. **Import 경로 업데이트**: 자동화 도구 사용하여 일괄 변경
3. **테스트 코드 동기화**: 구조 변경 시 테스트 코드도 함께 업데이트
4. **문서화**: 변경 사항 및 새로운 구조에 대한 문서 작성

---

**🎯 Phase 4는 가장 신중하게 접근해야 할 단계입니다. 기존 기능을 유지하면서 점진적으로 개선해나가겠습니다.**
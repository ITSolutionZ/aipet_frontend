# 🔧 AIPet Frontend 리팩토링 계획

**작성일**: 2025-10-23  
**분석 대상**: `/lib` 디렉토리 전체 (1,391 Dart 파일)  
**현재 코드 라인 수**: 약 165,156줄  
**목표**: Clean Architecture 완전 준수 + 테스트 커버리지 50%

---

## 📊 현황 분석 요약

### 코드베이스 통계

| 항목 | 현재 | 목표 | 개선율 |
|------|------|------|--------|
| 총 Dart 파일 | 1,391 | 1,200 | -13.7% |
| 500줄 이상 파일 | 30 (2.2%) | 5 (0.4%) | -83% |
| 1,000줄 이상 파일 | 6 (0.4%) | 0 | -100% |
| 테스트 커버리지 | 0.07% | 50% | +71,000% |
| 중복 Card 컴포넌트 | 37개 | 4개 | -89% |
| 하드코딩 값 | 1,113개 | 50개 이하 | -95% |

### 아키텍처 준수도

- **완전 준수** (Domain/Data/Presentation 분리): 60% (12/20 features)
- **부분 준수**: 20% (4/20 features)
- **미준수**: 20% (4/20 features)

---

## 🎯 리팩토링 우선순위

### 🔴 Phase 1: Critical (1-2주)

#### 1. 메가 클래스 분해

**대상 파일 (1,000줄 이상)**

1. facility_booking_screen.dart - 1,407줄 → 8-10개 파일 (각 200줄)
2. live_walk_widget.dart - 1,284줄 → 6-8개 파일
3. pet_basic_info_tab.dart - 1,186줄 → 6개 파일
4. hospital_detail_screen.dart - 1,255줄 → 7개 파일
5. qr_code_bottom_sheet.dart - 1,235줄 → 5개 파일
6. pet_search_screen.dart - 1,115줄 → 5개 파일

**추정 작업 시간**: 15-20일 (3-4주)

#### 2. Card 컴포넌트 통합

**현재 문제점**:
- 37개의 독립적인 Card 위젯
- 동일한 BoxDecoration 패턴 반복 (800+ 줄의 중복)

**통합 후**:
- 4개의 공통 Card 컴포넌트
- 약 2,800줄 → 650줄 (-77% 감소)

**작업 시간**: 3-4일

#### 3. ConsumerStatefulWidget → Riverpod 마이그레이션

**대상**: 20개 파일  
**작업 시간**: 파일당 2-3시간 × 20 = 5-7일

---

### ⚠️ Phase 2: High Priority (2-3주)

#### 4. 테스트 커버리지 향상

**현재**: 테스트 파일 1개 (0.07%)  
**목표**: 200+ 테스트 파일 (50% 커버리지)

**우선순위**:
1. pet_profile: Unit 15+, Widget 10+ (목표 60%)
2. facility: Unit 12+, Widget 8+ (목표 55%)
3. walk: Unit 10+, Widget 6+ (목표 50%)
4. scheduling: Unit 10+, Widget 6+ (목표 50%)
5. shared/widgets: Widget 20+ (목표 70%)

**작업 시간**: 20-25일

#### 5. 하드코딩 값 추출

**현재**:
- 매직 넘버: 1,113개
- 하드코딩 색상: 205개 파일
- 하드코딩 텍스트: 50+ 인스턴스

**작업 내용**:
- 각 feature별 Constants 파일 생성
- shared/design 토큰 확장 (AppDimensions, AppDurations, AppElevations)
- 1,113개 값 마이그레이션

**작업 시간**: 20일

#### 6. Facility 관련 화면 분해

- hospital_detail_screen.dart (1,255줄) → 7개 파일
- hospital_list_screen.dart (845줄) → 5개 파일
- hospital_booking_screen.dart (664줄) → 4개 파일

**작업 시간**: 6-8일

---

### ℹ️ Phase 3: Medium Priority (3-4주)

#### 7. Domain Layer 강화

**미구현 Features**:
- contact: Domain layer 신규 생성 (3일)
- shopping: Domain layer 신규 생성 (4일)
- board: Domain layer 완성 (4일)

**작업 시간**: 11일

#### 8. UI Constants 중앙화

- 하드코딩 텍스트 추출
- AppTexts, AppColors 확장
- i18n 대응 준비

**작업 시간**: 10일

---

## 📅 실행 일정

### Week 1-2: Phase 1 Critical (Part 1)
- Day 1-4: facility_booking_screen.dart 분해
- Day 5-8: pet_basic_info_tab.dart 분해
- Day 9-12: live_walk_widget.dart 분해
- Day 13-14: Card 컴포넌트 통합 시작

### Week 3-4: Phase 1 Critical (Part 2)
- Day 15-16: Card 컴포넌트 통합 완료
- Day 17-18: hospital_detail_screen.dart 분해
- Day 19-20: qr_code_bottom_sheet.dart 분해
- Day 21-22: pet_search_screen.dart 분해
- Day 23-28: ConsumerStatefulWidget 마이그레이션 (20파일)

### Week 5-6: Phase 2 High Priority (Part 1)
- Day 29-35: pet_profile 테스트 작성
- Day 36-42: facility 테스트 작성

### Week 7-8: Phase 2 High Priority (Part 2)
- Day 43-49: walk, scheduling 테스트 작성
- Day 50-52: shared/widgets 테스트 작성
- Day 53-56: 하드코딩 값 추출 시작

### Week 9-10: Phase 2 High Priority (Part 3)
- Day 57-70: 하드코딩 값 마이그레이션 (1,113개)

### Week 11-13: Phase 3 Medium Priority
- Day 71-73: contact Domain Layer 작성
- Day 74-77: shopping Domain Layer 작성
- Day 78-81: board Domain Layer 작성
- Day 82-91: UI Constants 중앙화

---

## 🎯 성공 지표

### 코드 품질
- 500줄 이상 파일: 30개 → 5개 이하
- 1,000줄 이상 파일: 6개 → 0개
- 평균 파일 크기: 200-300줄
- 총 파일 수: 1,391 → 1,200 (-13.7%)

### 테스트
- Unit Test: 0 → 100+
- Widget Test: 0 → 50+
- Integration Test: 0 → 10+
- 테스트 커버리지: 0.07% → 50%

### 아키텍처
- Clean Architecture 준수: 60% → 100% (20/20 features)
- Domain Layer 완비: 12 features → 20 features
- Repository 패턴 적용: 모든 features

### 유지보수성
- Card 컴포넌트: 37개 → 4개
- ConsumerStatefulWidget: 20개 → 0개
- 하드코딩 값: 1,113개 → 50개 이하
- 매직 넘버 감소율: 95%

---

## 🚨 리스크 및 대응책

### Risk 1: 기존 기능 손상
**대응**:
- 리팩토링 전 스크린샷 촬영
- 단계적 변경 (파일 단위)
- 각 변경 후 동작 확인
- Git 세밀하게 커밋

### Risk 2: 테스트 작성 지연
**대응**:
- 리팩토링하면서 테스트 동시 작성
- 파일 분해 시 테스트도 함께 생성
- 코드 리뷰 철저히 진행

### Risk 3: 머지 충돌
**대응**:
- Feature 브랜치 작게 유지
- 하루 1회 이상 main 머지
- 리팩토링 우선순위 공유

---

## 📝 체크리스트

### 리팩토링 전
- [ ] 현재 코드베이스 백업
- [ ] 모든 기능 동작 확인 (수동 테스트)
- [ ] 주요 화면 스크린샷 촬영
- [ ] 의존성 파악
- [ ] 리팩토링 대상 파일 리스트 작성

### 리팩토링 중
- [ ] 파일마다 Git 커밋
- [ ] 커밋 메시지에 변경 내용 상세 기록
- [ ] 각 변경 후 flutter analyze 실행
- [ ] 각 변경 후 앱 실행 확인
- [ ] 테스트 커버리지 지속 체크

### 리팩토링 후
- [ ] 전체 테스트 실행 (flutter test)
- [ ] 커버리지 리포트 생성
- [ ] 주요 기능 수동 테스트
- [ ] 성능 측정 (before/after)
- [ ] 문서 업데이트 (CLAUDE.md)

---

## 🔗 관련 문서

- [CLAUDE.md](./CLAUDE.md) - 프로젝트 개발 가이드
- [analysis_options.yaml](./analysis_options.yaml) - Lint 규칙
- [README.md](./README.md) - 프로젝트 개요

---

## 📊 진행 상황 관리

리팩토링 진행 상황은 다음으로 관리:

- **GitHub Issues**: 각 작업을 Issue로 생성
- **GitHub Project**: 칸반 보드로 진행 상황 시각화
- **Git Branches**: `refactor/feature-name` 브랜치 명명 규칙

---

**최종 업데이트**: 2025-10-23  
**다음 리뷰**: Phase 1 완료 후

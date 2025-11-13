# AIPet Database Optimization Guide

## 개요

이 가이드는 AIPet 백엔드 데이터베이스의 성능 최적화를 위한 SQL 스크립트 실행 방법을 설명합니다.

## 최적화 목표

1. **성능 향상**: Statistics API 및 기타 API의 쿼리 성능 향상
2. **데이터 무결성**: 외래키 제약조건으로 데이터 일관성 보장
3. **인덱스 최적화**: 자주 사용되는 쿼리 패턴에 맞는 복합 인덱스 추가

## 최적화 내용

### Phase 1: user_id 컬럼 추가
- **대상 테이블**: walks, feedings, medical_records, weight_history, activities
- **목적**: pets 테이블과의 불필요한 조인 제거
- **효과**: Statistics API 쿼리 성능 대폭 향상

### Phase 2: 복합 인덱스 추가
- **대상**: 자주 함께 사용되는 컬럼 조합
- **효과**: WHERE, ORDER BY, GROUP BY 절 성능 향상

### Phase 3: 외래키 제약조건
- **목적**: 데이터 무결성 보장
- **효과**: CASCADE 삭제로 고아 레코드 방지

## 실행 전 준비사항

### 1. 데이터베이스 백업

```bash
# 전체 데이터베이스 백업
mysqldump -u root aipet_db > backup_$(date +%Y%m%d_%H%M%S).sql

# 특정 테이블만 백업
mysqldump -u root aipet_db walks feedings vaccinations medical_records weight_history activities > backup_tables_$(date +%Y%m%d_%H%M%S).sql
```

### 2. 백엔드 서버 중지

```bash
# 데이터 변경 중에는 백엔드 서버를 중지해야 합니다
# (개발 환경에서는 선택사항, 프로덕션에서는 필수)
```

### 3. 데이터베이스 연결 확인

```bash
mysql -u root aipet_db -e "SELECT 'Connected successfully!' as Status;"
```

## 실행 방법

### 옵션 1: 단계별 실행 (권장)

각 Phase를 순서대로 실행하며, 각 단계 후 결과를 확인합니다.

```bash
# Phase 1: user_id 추가 (가장 중요)
mysql -u root aipet_db < database-optimization-phase1.sql

# 결과 확인 후 다음 단계 진행

# Phase 2: 복합 인덱스 추가
mysql -u root aipet_db < database-optimization-phase2.sql

# Phase 3: 외래키 제약조건 추가
mysql -u root aipet_db < database-optimization-phase3.sql
```

### 옵션 2: 전체 실행

```bash
# 모든 Phase를 한 번에 실행 (Phase 1 → 2 → 3 순서)
mysql -u root aipet_db < database-optimization.sql
```

## 실행 후 확인사항

### 1. user_id 컬럼 확인

```sql
-- walks 테이블 user_id 확인
SELECT COUNT(*) as total, SUM(CASE WHEN user_id IS NOT NULL THEN 1 ELSE 0 END) as with_user_id
FROM walks;

-- feedings 테이블 user_id 확인
SELECT COUNT(*) as total, SUM(CASE WHEN user_id IS NOT NULL THEN 1 ELSE 0 END) as with_user_id
FROM feedings;
```

### 2. 인덱스 확인

```sql
-- walks 테이블 인덱스 목록
SHOW INDEX FROM walks;

-- 모든 복합 인덱스 확인
SELECT TABLE_NAME, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) as COLUMNS
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'aipet_db' AND INDEX_NAME LIKE 'idx_%'
GROUP BY TABLE_NAME, INDEX_NAME
ORDER BY TABLE_NAME;
```

### 3. 외래키 확인

```sql
SELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'aipet_db' AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME;
```

### 4. API 테스트

```bash
# 백엔드 서버 재시작
npm run dev

# Statistics API 테스트
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:3000/api/v1/statistics/dashboard
```

## 성능 개선 예상

### Before (최적화 전)
```sql
-- walks 통계 조회 (pets 조인 필요)
SELECT COUNT(*), SUM(distance)
FROM walks w
JOIN pets p ON w.pet_id = p.id
WHERE p.owner_id = 'user123' AND w.start_time >= '2025-11-01';
-- 예상 실행 시간: ~50ms (조인 비용 포함)
```

### After (최적화 후)
```sql
-- walks 통계 조회 (조인 불필요)
SELECT COUNT(*), SUM(distance)
FROM walks
WHERE user_id = 'user123' AND start_time >= '2025-11-01';
-- 예상 실행 시간: ~5ms (복합 인덱스 사용)
```

**성능 향상: 약 10배**

## 롤백 방법

최적화 적용 후 문제가 발생한 경우:

```bash
# 백업에서 복원
mysql -u root aipet_db < backup_YYYYMMDD_HHMMSS.sql
```

개별 변경사항 롤백:

```sql
-- Phase 3 롤백: 외래키 제약조건 제거
ALTER TABLE walks DROP FOREIGN KEY fk_walks_user_id;
ALTER TABLE feedings DROP FOREIGN KEY fk_feedings_user_id;

-- Phase 2 롤백: 인덱스 제거
DROP INDEX idx_user_start_time ON walks;
DROP INDEX idx_user_feeding_time ON feedings;

-- Phase 1 롤백: user_id 컬럼 제거 (주의: 데이터 손실)
ALTER TABLE walks DROP COLUMN user_id;
ALTER TABLE feedings DROP COLUMN user_id;
```

## 주의사항

1. **프로덕션 환경**: 반드시 백업 후 실행
2. **다운타임**: Phase 1 실행 중 (~1-2분) 서비스 중단 권장
3. **데이터 검증**: 각 Phase 완료 후 데이터 정합성 확인
4. **모니터링**: 최적화 후 쿼리 성능 모니터링

## 문제 해결

### 에러: "Duplicate key name"
- 원인: 인덱스가 이미 존재
- 해결: 해당 인덱스 생성 쿼리를 건너뛰고 계속 진행

### 에러: "Cannot add foreign key constraint"
- 원인: 참조 무결성 위반 (고아 레코드 존재)
- 해결: 고아 레코드 정리 후 재실행

```sql
-- 고아 레코드 확인
SELECT w.* FROM walks w
LEFT JOIN users u ON w.user_id = u.id
WHERE u.id IS NULL;

-- 고아 레코드 삭제 (주의!)
DELETE w FROM walks w
LEFT JOIN users u ON w.user_id = u.id
WHERE u.id IS NULL;
```

## 추가 최적화 (선택사항)

### 1. 일일 통계 테이블 생성

```sql
-- Statistics API 성능을 더욱 향상시키기 위한 요약 테이블
CREATE TABLE daily_statistics (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(128) NOT NULL,
  pet_id VARCHAR(128),
  stat_date DATE NOT NULL,
  walk_count INT DEFAULT 0,
  walk_distance DECIMAL(10,2) DEFAULT 0,
  walk_duration INT DEFAULT 0,
  feeding_count INT DEFAULT 0,
  UNIQUE KEY idx_user_pet_date (user_id, pet_id, stat_date)
);
```

### 2. 정기적인 ANALYZE 실행

```bash
# 매주 실행 (cron job)
mysql -u root aipet_db -e "ANALYZE TABLE walks, feedings, vaccinations, medical_records, weight_history, activities;"
```

## 지원

문제 발생 시:
1. 백업에서 복원
2. 에러 로그 확인
3. GitHub Issue 생성

-- ============================================================================
-- AIPet Database Optimization - Phase 3: 외래키 제약조건 추가
-- ============================================================================
-- 목적: 데이터 무결성 보장을 위한 외래키 제약조건 추가
-- 작성일: 2025-11-12
-- 전제조건: Phase 1 완료 (user_id 컬럼 추가)
-- ============================================================================

USE aipet_db;

-- ============================================================================
-- Phase 3: 외래키 제약조건 추가
-- ============================================================================

-- 1. walks 테이블
-- user_id 외래키 추가
ALTER TABLE walks
ADD CONSTRAINT fk_walks_user_id
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 2. feedings 테이블
-- user_id 외래키 추가
ALTER TABLE feedings
ADD CONSTRAINT fk_feedings_user_id
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 3. medical_records 테이블
-- user_id 외래키 추가 (이미 있을 수 있음 - 에러 무시)
ALTER TABLE medical_records
ADD CONSTRAINT fk_medical_records_user_id
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 4. weight_history 테이블
-- user_id 외래키 추가
ALTER TABLE weight_history
ADD CONSTRAINT fk_weight_history_user_id
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- 5. activities 테이블
-- user_id 외래키 추가 (이미 있을 수 있음)
ALTER TABLE activities
ADD CONSTRAINT fk_activities_user_id
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- ============================================================================
-- 외래키 제약조건 확인
-- ============================================================================

SELECT
  TABLE_NAME,
  CONSTRAINT_NAME,
  COLUMN_NAME,
  REFERENCED_TABLE_NAME,
  REFERENCED_COLUMN_NAME,
  DELETE_RULE,
  UPDATE_RULE
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'aipet_db'
  AND REFERENCED_TABLE_NAME IS NOT NULL
  AND TABLE_NAME IN ('walks', 'feedings', 'vaccinations', 'medical_records',
                     'weight_history', 'activities', 'pets')
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- ============================================================================
-- 완료 메시지
-- ============================================================================
SELECT 'Phase 3 completed: Foreign key constraints added successfully!' as Status;

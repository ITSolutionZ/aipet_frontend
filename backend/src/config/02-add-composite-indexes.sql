-- ============================================================================
-- AIPet Database Optimization - Phase 2: 복합 인덱스 추가
-- ============================================================================
-- 목적: 쿼리 성능 향상을 위한 복합 인덱스 추가
-- 작성일: 2025-11-12
-- 전제조건: Phase 1 완료 (user_id 컬럼 추가)
-- ============================================================================

USE aipet_db;

-- ============================================================================
-- Phase 2: 복합 인덱스 추가
-- ============================================================================

-- 1. walks 테이블
-- Statistics API에서 자주 사용하는 쿼리 패턴에 맞는 복합 인덱스

-- user_id + start_time (기간별 통계 조회)
CREATE INDEX idx_user_start_time ON walks(user_id, start_time);

-- pet_id + start_time (펫별 산책 이력)
CREATE INDEX idx_pet_start_time ON walks(pet_id, start_time);

-- 2. feedings 테이블
-- user_id + feeding_time (기간별 급식 통계)
CREATE INDEX idx_user_feeding_time ON feedings(user_id, feeding_time);

-- pet_id + feeding_time (펫별 급식 이력)
CREATE INDEX idx_pet_feeding_time ON feedings(pet_id, feeding_time);

-- pet_id + meal_type (펫별 식사 타입 분석)
CREATE INDEX idx_pet_meal_type ON feedings(pet_id, meal_type);

-- 3. vaccinations 테이블
-- user_id + next_due_date (만료 예정 예방접종 조회)
CREATE INDEX idx_user_next_due ON vaccinations(user_id, next_due_date);

-- pet_id + vaccination_date (펫별 예방접종 이력)
CREATE INDEX idx_pet_vaccination_date ON vaccinations(pet_id, vaccination_date);

-- next_due_date + pet_id (만료일 기준 정렬)
CREATE INDEX idx_due_date_pet ON vaccinations(next_due_date, pet_id);

-- 4. medical_records 테이블
-- user_id + visit_date (최근 진료 기록 조회)
CREATE INDEX idx_user_visit_date ON medical_records(user_id, visit_date);

-- pet_id + visit_date (펫별 진료 이력)
CREATE INDEX idx_pet_visit_date ON medical_records(pet_id, visit_date);

-- 5. weight_history 테이블
-- pet_id + measured_at (펫별 체중 추이)
CREATE INDEX idx_pet_measured_at ON weight_history(pet_id, measured_at);

-- user_id + measured_at (사용자별 체중 기록)
CREATE INDEX idx_user_measured_at ON weight_history(user_id, measured_at);

-- 6. activities 테이블
-- user_id + activity_date (기간별 활동 통계)
CREATE INDEX idx_user_activity_date ON activities(user_id, activity_date);

-- pet_id + activity_date (펫별 활동 이력)
CREATE INDEX idx_pet_activity_date ON activities(pet_id, activity_date);

-- activity_type + activity_date (타입별 활동 분석)
CREATE INDEX idx_type_date ON activities(activity_type, activity_date);

-- 7. notifications 테이블
-- user_id + created_at + is_read (읽지 않은 알림 조회)
CREATE INDEX idx_user_created_read ON notifications(user_id, created_at, is_read);

-- user_id + is_read (읽지 않은 알림 수 조회)
CREATE INDEX idx_user_read ON notifications(user_id, is_read);

-- 8. pets 테이블
-- owner_id + is_active (활성 펫 조회)
CREATE INDEX idx_owner_active ON pets(owner_id, is_active);

-- type + is_active (타입별 활성 펫 통계)
CREATE INDEX idx_type_active ON pets(type, is_active);

-- 9. users 테이블 (이메일 조회 최적화)
-- email 인덱스 추가 (이미 있을 수 있음)
CREATE INDEX idx_email ON users(email);

-- ============================================================================
-- 인덱스 효율성 확인
-- ============================================================================

-- 테이블별 인덱스 목록 확인
SELECT
  TABLE_NAME,
  INDEX_NAME,
  GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) as COLUMNS,
  INDEX_TYPE,
  NON_UNIQUE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'aipet_db'
  AND TABLE_NAME IN ('walks', 'feedings', 'vaccinations', 'medical_records',
                     'weight_history', 'activities', 'notifications', 'pets', 'users')
GROUP BY TABLE_NAME, INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY TABLE_NAME, INDEX_NAME;

-- ============================================================================
-- 완료 메시지
-- ============================================================================
SELECT 'Phase 2 completed: Composite indexes added successfully!' as Status;

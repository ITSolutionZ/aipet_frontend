-- ============================================================================
-- AIPet Database Optimization Script
-- ============================================================================
-- 목적: 성능 향상을 위한 인덱스 추가 및 스키마 최적화
-- 작성일: 2025-11-12
-- ============================================================================

USE aipet_db;

-- ============================================================================
-- 1. user_id 컬럼 추가 (성능 최적화)
-- ============================================================================
-- 백엔드 컨트롤러에서 user_id로 직접 필터링하는 경우가 많아
-- pets 테이블과의 조인을 줄이기 위해 user_id를 추가합니다.

-- walks 테이블에 user_id 추가
ALTER TABLE walks
ADD COLUMN user_id VARCHAR(128) AFTER id,
ADD INDEX idx_user_id (user_id);

-- 기존 데이터에 user_id 채우기
UPDATE walks w
JOIN pets p ON w.pet_id = p.id
SET w.user_id = p.owner_id;

-- user_id를 NOT NULL로 변경
ALTER TABLE walks
MODIFY COLUMN user_id VARCHAR(128) NOT NULL;

-- feedings 테이블에 user_id 추가
ALTER TABLE feedings
ADD COLUMN user_id VARCHAR(128) AFTER id,
ADD INDEX idx_user_id (user_id);

UPDATE feedings f
JOIN pets p ON f.pet_id = p.id
SET f.user_id = p.owner_id;

ALTER TABLE feedings
MODIFY COLUMN user_id VARCHAR(128) NOT NULL;

-- vaccinations 테이블에 user_id 추가
ALTER TABLE vaccinations
ADD COLUMN user_id VARCHAR(128) AFTER id,
ADD INDEX idx_user_id (user_id);

UPDATE vaccinations v
JOIN pets p ON v.pet_id = p.id
SET v.user_id = p.owner_id;

ALTER TABLE vaccinations
MODIFY COLUMN user_id VARCHAR(128) NOT NULL;

-- medical_records 테이블에 user_id 추가
ALTER TABLE medical_records
ADD COLUMN user_id VARCHAR(128) AFTER id,
ADD INDEX idx_user_id (user_id);

UPDATE medical_records mr
JOIN pets p ON mr.pet_id = p.id
SET mr.user_id = p.owner_id;

ALTER TABLE medical_records
MODIFY COLUMN user_id VARCHAR(128) NOT NULL;

-- weight_history 테이블에 user_id 추가
ALTER TABLE weight_history
ADD COLUMN user_id VARCHAR(128) AFTER id,
ADD INDEX idx_user_id (user_id);

UPDATE weight_history wh
JOIN pets p ON wh.pet_id = p.id
SET wh.user_id = p.owner_id;

ALTER TABLE weight_history
MODIFY COLUMN user_id VARCHAR(128) NOT NULL;

-- activities 테이블에 user_id 추가 (이미 있을 수 있음 - 에러 무시)
ALTER TABLE activities
ADD COLUMN user_id VARCHAR(128) AFTER id,
ADD INDEX idx_user_id (user_id);

UPDATE activities a
JOIN pets p ON a.pet_id = p.id
SET a.user_id = p.owner_id
WHERE a.user_id IS NULL;

-- ============================================================================
-- 2. 복합 인덱스 추가 (쿼리 성능 최적화)
-- ============================================================================

-- walks: user_id + start_time (Statistics API에서 자주 사용)
CREATE INDEX idx_user_start_time ON walks(user_id, start_time);

-- walks: pet_id + start_time (펫별 산책 조회)
CREATE INDEX idx_pet_start_time ON walks(pet_id, start_time);

-- feedings: user_id + feeding_time (Statistics API)
CREATE INDEX idx_user_feeding_time ON feedings(user_id, feeding_time);

-- feedings: pet_id + feeding_time (펫별 급식 조회)
CREATE INDEX idx_pet_feeding_time ON feedings(pet_id, feeding_time);

-- vaccinations: user_id + next_due_date (만료 예정 조회)
CREATE INDEX idx_user_next_due ON vaccinations(user_id, next_due_date);

-- vaccinations: pet_id + vaccination_date (펫별 예방접종 이력)
CREATE INDEX idx_pet_vaccination_date ON vaccinations(pet_id, vaccination_date);

-- medical_records: user_id + visit_date (최근 진료 기록)
CREATE INDEX idx_user_visit_date ON medical_records(user_id, visit_date);

-- notifications: user_id + created_at + is_read (읽지 않은 알림 조회)
CREATE INDEX idx_user_created_read ON notifications(user_id, created_at, is_read);

-- ============================================================================
-- 3. JSON 컬럼에 Virtual Column 및 인덱스 추가 (MySQL 5.7+)
-- ============================================================================

-- walks 테이블의 distance_meters가 NULL인 경우를 위한 처리
-- route_data JSON에서 총 거리 계산을 위한 virtual column 추가 (선택사항)

-- ============================================================================
-- 4. 테이블 파티셔닝 (대용량 데이터 최적화 - 선택사항)
-- ============================================================================
-- 산책 데이터가 많아질 경우 월별 파티셔닝 고려
-- 현재는 적용하지 않음 (추후 데이터 증가 시 고려)

-- ============================================================================
-- 5. 통계 테이블 최적화
-- ============================================================================

-- Statistics API를 위한 Summary 테이블 생성 (선택사항)
-- 실시간 집계 대신 정기적으로 업데이트되는 요약 테이블

CREATE TABLE IF NOT EXISTS daily_statistics (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(128) NOT NULL,
  pet_id VARCHAR(128),
  stat_date DATE NOT NULL,
  walk_count INT DEFAULT 0,
  walk_distance DECIMAL(10,2) DEFAULT 0,
  walk_duration INT DEFAULT 0,
  feeding_count INT DEFAULT 0,
  feeding_amount DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY idx_user_pet_date (user_id, pet_id, stat_date),
  KEY idx_stat_date (stat_date),
  KEY idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='일일 활동 통계 요약 테이블 (성능 최적화용)';

-- ============================================================================
-- 6. 기존 인덱스 최적화
-- ============================================================================

-- users 테이블: email로 자주 조회하는 경우 인덱스 추가
ALTER TABLE users
ADD INDEX idx_email (email);

-- pets 테이블: owner_id + is_active (활성 펫 조회)
CREATE INDEX idx_owner_active ON pets(owner_id, is_active);

-- ============================================================================
-- 7. 외래키 제약조건 추가 (데이터 무결성)
-- ============================================================================

-- walks 테이블에 user_id 외래키 추가
ALTER TABLE walks
ADD CONSTRAINT fk_walks_user_id
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- feedings 테이블에 user_id 외래키 추가
ALTER TABLE feedings
ADD CONSTRAINT fk_feedings_user_id
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- vaccinations 테이블에 user_id 외래키 추가
ALTER TABLE vaccinations
ADD CONSTRAINT fk_vaccinations_user_id
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- medical_records 테이블에 user_id 외래키 추가
ALTER TABLE medical_records
ADD CONSTRAINT fk_medical_records_user_id
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- weight_history 테이블에 user_id 외래키 추가
ALTER TABLE weight_history
ADD CONSTRAINT fk_weight_history_user_id
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- ============================================================================
-- 8. 테이블 분석 및 최적화
-- ============================================================================

ANALYZE TABLE pets, walks, feedings, vaccinations, medical_records,
             weight_history, activities, notifications, users;

OPTIMIZE TABLE pets, walks, feedings, vaccinations, medical_records,
               weight_history, activities, notifications, users;

-- ============================================================================
-- 완료 메시지
-- ============================================================================
SELECT 'Database optimization completed successfully!' as Status;

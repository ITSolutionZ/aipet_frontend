-- ============================================================================
-- AIPet Database Optimization - Phase 1: user_id 추가
-- ============================================================================
-- 목적: Statistics API 및 기타 API의 성능 향상을 위해 user_id 추가
-- 작성일: 2025-11-12
-- ============================================================================

USE aipet_db;

-- ============================================================================
-- Phase 1: user_id 컬럼 추가 및 데이터 마이그레이션
-- ============================================================================

-- 1. walks 테이블
ALTER TABLE walks
ADD COLUMN user_id VARCHAR(128) AFTER id;

-- 기존 데이터에 user_id 채우기
UPDATE walks w
JOIN pets p ON w.pet_id = p.id
SET w.user_id = p.owner_id;

-- user_id를 NOT NULL로 변경 (모든 데이터 마이그레이션 후)
ALTER TABLE walks
MODIFY COLUMN user_id VARCHAR(128) NOT NULL;

-- 인덱스 추가
CREATE INDEX idx_user_id_walks ON walks(user_id);

-- 2. feedings 테이블
ALTER TABLE feedings
ADD COLUMN user_id VARCHAR(128) AFTER id;

UPDATE feedings f
JOIN pets p ON f.pet_id = p.id
SET f.user_id = p.owner_id;

ALTER TABLE feedings
MODIFY COLUMN user_id VARCHAR(128) NOT NULL;

CREATE INDEX idx_user_id_feedings ON feedings(user_id);

-- 3. medical_records 테이블에 user_id가 없는 경우 추가
-- (이미 있을 수 있으므로 에러 발생 시 무시)

-- user_id 컬럼 존재 여부 확인 후 추가
SET @table_name = 'medical_records';
SET @column_name = 'user_id';
SET @column_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'aipet_db'
    AND TABLE_NAME = @table_name
    AND COLUMN_NAME = @column_name
);

-- user_id가 없으면 추가
SET @sql = IF(
  @column_exists = 0,
  'ALTER TABLE medical_records ADD COLUMN user_id VARCHAR(128) AFTER id',
  'SELECT "user_id already exists in medical_records" as Info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 기존 데이터 마이그레이션 (user_id가 NULL인 경우만)
UPDATE medical_records mr
JOIN pets p ON mr.pet_id = p.id
SET mr.user_id = p.owner_id
WHERE mr.user_id IS NULL OR mr.user_id = '';

-- 인덱스 추가 (이미 있을 수 있으므로 에러 무시)
CREATE INDEX idx_user_id_medical_records ON medical_records(user_id);

-- 4. weight_history 테이블
SET @table_name = 'weight_history';
SET @column_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'aipet_db'
    AND TABLE_NAME = @table_name
    AND COLUMN_NAME = 'user_id'
);

SET @sql = IF(
  @column_exists = 0,
  'ALTER TABLE weight_history ADD COLUMN user_id VARCHAR(128) AFTER id',
  'SELECT "user_id already exists in weight_history" as Info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE weight_history wh
JOIN pets p ON wh.pet_id = p.id
SET wh.user_id = p.owner_id
WHERE wh.user_id IS NULL OR wh.user_id = '';

CREATE INDEX idx_user_id_weight_history ON weight_history(user_id);

-- 5. activities 테이블
SET @table_name = 'activities';
SET @column_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = 'aipet_db'
    AND TABLE_NAME = @table_name
    AND COLUMN_NAME = 'user_id'
);

SET @sql = IF(
  @column_exists = 0,
  'ALTER TABLE activities ADD COLUMN user_id VARCHAR(128) AFTER id',
  'SELECT "user_id already exists in activities" as Info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE activities a
JOIN pets p ON a.pet_id = p.id
SET a.user_id = p.owner_id
WHERE a.user_id IS NULL OR a.user_id = '';

CREATE INDEX idx_user_id_activities ON activities(user_id);

-- ============================================================================
-- 완료 확인
-- ============================================================================
SELECT 'Phase 1 completed: user_id columns added successfully!' as Status;

-- 추가된 user_id 확인
SELECT
  'walks' as table_name,
  COUNT(*) as total_rows,
  SUM(CASE WHEN user_id IS NOT NULL THEN 1 ELSE 0 END) as with_user_id
FROM walks
UNION ALL
SELECT
  'feedings',
  COUNT(*),
  SUM(CASE WHEN user_id IS NOT NULL THEN 1 ELSE 0 END)
FROM feedings
UNION ALL
SELECT
  'medical_records',
  COUNT(*),
  SUM(CASE WHEN user_id IS NOT NULL THEN 1 ELSE 0 END)
FROM medical_records
UNION ALL
SELECT
  'weight_history',
  COUNT(*),
  SUM(CASE WHEN user_id IS NOT NULL THEN 1 ELSE 0 END)
FROM weight_history
UNION ALL
SELECT
  'activities',
  COUNT(*),
  SUM(CASE WHEN user_id IS NOT NULL THEN 1 ELSE 0 END)
FROM activities;

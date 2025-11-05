import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

// MySQL 연결 풀 설정
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'aipet_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
  timezone: '+09:00', // 한국 시간대
});

// 데이터베이스 연결 테스트
export const testConnection = async () => {
  try {
    const connection = await pool.getConnection();
    console.log('✅ MySQL 데이터베이스 연결 성공');
    connection.release();
    return true;
  } catch (error) {
    console.error('❌ MySQL 데이터베이스 연결 실패:', error.message);
    return false;
  }
};

// 데이터베이스 초기화 (테이블 생성)
export const initializeDatabase = async () => {
  try {
    const connection = await pool.getConnection();

    // Users 테이블
    await connection.query(`
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(128) PRIMARY KEY COMMENT 'Firebase UID',
        email VARCHAR(255) NOT NULL UNIQUE,
        display_name VARCHAR(100),
        photo_url TEXT,
        provider VARCHAR(50) COMMENT 'google, apple, line',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        last_login_at TIMESTAMP NULL,
        is_active BOOLEAN DEFAULT true,
        INDEX idx_email (email),
        INDEX idx_created_at (created_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    // Pets 테이블
    await connection.query(`
      CREATE TABLE IF NOT EXISTS pets (
        id VARCHAR(128) PRIMARY KEY,
        owner_id VARCHAR(128) NOT NULL,
        name VARCHAR(100) NOT NULL,
        type VARCHAR(50) NOT NULL COMMENT 'dog, cat, bird, etc',
        breed VARCHAR(100),
        birth_date DATE,
        gender ENUM('male', 'female', 'unknown') DEFAULT 'unknown',
        weight DECIMAL(5,2) COMMENT 'kg 단위',
        photo_url TEXT,
        microchip_number VARCHAR(50),
        is_neutered BOOLEAN DEFAULT false,
        color VARCHAR(50),
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        is_active BOOLEAN DEFAULT true,
        FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_owner_id (owner_id),
        INDEX idx_type (type),
        INDEX idx_created_at (created_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    // Vaccinations 테이블 (예방접종)
    await connection.query(`
      CREATE TABLE IF NOT EXISTS vaccinations (
        id VARCHAR(128) PRIMARY KEY,
        pet_id VARCHAR(128) NOT NULL,
        vaccine_name VARCHAR(100) NOT NULL,
        vaccine_type VARCHAR(50),
        vaccination_date DATE NOT NULL,
        next_due_date DATE,
        veterinarian_name VARCHAR(100),
        clinic_name VARCHAR(200),
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
        INDEX idx_pet_id (pet_id),
        INDEX idx_vaccination_date (vaccination_date),
        INDEX idx_next_due_date (next_due_date)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    // Medical Records 테이블 (의료 기록)
    await connection.query(`
      CREATE TABLE IF NOT EXISTS medical_records (
        id VARCHAR(128) PRIMARY KEY,
        pet_id VARCHAR(128) NOT NULL,
        visit_date DATE NOT NULL,
        visit_type VARCHAR(50) COMMENT 'checkup, emergency, surgery, etc',
        diagnosis TEXT,
        treatment TEXT,
        prescription TEXT,
        veterinarian_name VARCHAR(100),
        clinic_name VARCHAR(200),
        cost DECIMAL(10,2),
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
        INDEX idx_pet_id (pet_id),
        INDEX idx_visit_date (visit_date),
        INDEX idx_visit_type (visit_type)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    // Weight History 테이블 (체중 기록)
    await connection.query(`
      CREATE TABLE IF NOT EXISTS weight_history (
        id VARCHAR(128) PRIMARY KEY,
        pet_id VARCHAR(128) NOT NULL,
        weight DECIMAL(5,2) NOT NULL COMMENT 'kg 단위',
        measured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        notes TEXT,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
        INDEX idx_pet_id (pet_id),
        INDEX idx_measured_at (measured_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    // Walks 테이블 (산책 기록)
    await connection.query(`
      CREATE TABLE IF NOT EXISTS walks (
        id VARCHAR(128) PRIMARY KEY,
        pet_id VARCHAR(128) NOT NULL,
        start_time TIMESTAMP NOT NULL,
        end_time TIMESTAMP,
        duration_minutes INT,
        distance_meters INT,
        route_data JSON COMMENT 'GPS 좌표 배열',
        temperature DECIMAL(4,1),
        weather VARCHAR(50),
        poop_count INT DEFAULT 0,
        pee_count INT DEFAULT 0,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
        INDEX idx_pet_id (pet_id),
        INDEX idx_start_time (start_time)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    // Feedings 테이블 (급식 기록)
    await connection.query(`
      CREATE TABLE IF NOT EXISTS feedings (
        id VARCHAR(128) PRIMARY KEY,
        pet_id VARCHAR(128) NOT NULL,
        feeding_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        food_type VARCHAR(100),
        food_brand VARCHAR(100),
        amount_grams DECIMAL(6,2),
        meal_type ENUM('breakfast', 'lunch', 'dinner', 'snack') DEFAULT 'snack',
        notes TEXT,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
        INDEX idx_pet_id (pet_id),
        INDEX idx_feeding_time (feeding_time),
        INDEX idx_meal_type (meal_type)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    // Notifications 테이블 (알림)
    await connection.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id VARCHAR(128) PRIMARY KEY,
        user_id VARCHAR(128) NOT NULL,
        pet_id VARCHAR(128),
        title VARCHAR(200) NOT NULL,
        body TEXT,
        notification_type VARCHAR(50) COMMENT 'vaccination, feeding, walk, medical',
        scheduled_at TIMESTAMP,
        sent_at TIMESTAMP NULL,
        is_read BOOLEAN DEFAULT false,
        is_sent BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
        INDEX idx_user_id (user_id),
        INDEX idx_pet_id (pet_id),
        INDEX idx_scheduled_at (scheduled_at),
        INDEX idx_notification_type (notification_type)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    // Activities 테이블 (기타 활동)
    await connection.query(`
      CREATE TABLE IF NOT EXISTS activities (
        id VARCHAR(128) PRIMARY KEY,
        pet_id VARCHAR(128) NOT NULL,
        activity_type VARCHAR(50) NOT NULL COMMENT 'playing, sleeping, bathing, etc',
        start_time TIMESTAMP NOT NULL,
        end_time TIMESTAMP,
        duration_minutes INT,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
        INDEX idx_pet_id (pet_id),
        INDEX idx_activity_type (activity_type),
        INDEX idx_start_time (start_time)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    console.log('✅ 데이터베이스 테이블 초기화 완료');
    connection.release();
    return true;
  } catch (error) {
    console.error('❌ 데이터베이스 초기화 실패:', error.message);
    throw error;
  }
};

export default pool;

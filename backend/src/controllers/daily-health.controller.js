import pool from '../config/database.js';

/**
 * @desc    일일 건강 기록 목록 조회
 * @route   GET /api/v1/daily-health/records
 * @access  Private
 */
export const getDailyHealthRecords = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { petId, startDate, endDate, limit = 30 } = req.query;

    let query = `
      SELECT * FROM daily_health_records
      WHERE user_id = ?
    `;
    const params = [userId];

    // Pet 필터
    if (petId) {
      query += ' AND pet_id = ?';
      params.push(petId);
    }

    // 날짜 범위 필터
    if (startDate) {
      query += ' AND record_date >= ?';
      params.push(startDate);
    }
    if (endDate) {
      query += ' AND record_date <= ?';
      params.push(endDate);
    }

    query += ' ORDER BY record_date DESC LIMIT ?';
    params.push(parseInt(limit));

    const [records] = await pool.query(query, params);

    console.log(`✅ [DailyHealth] 일일 건강 기록 조회: ${records.length}개`);
    res.json({
      success: true,
      message: '일일 건강 기록을 가져왔습니다.',
      data: records,
    });
  } catch (error) {
    console.error('❌ [DailyHealth] 기록 조회 실패:', error);
    res.status(500).json({
      success: false,
      message: '일일 건강 기록 조회에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    특정 날짜의 건강 기록 조회
 * @route   GET /api/v1/daily-health/records/:recordId
 * @access  Private
 */
export const getDailyHealthRecordById = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { recordId } = req.params;

    const [records] = await pool.query(
      'SELECT * FROM daily_health_records WHERE id = ? AND user_id = ?',
      [recordId, userId]
    );

    if (records.length === 0) {
      return res.status(404).json({
        success: false,
        message: '건강 기록을 찾을 수 없습니다.',
      });
    }

    console.log(`✅ [DailyHealth] 건강 기록 조회: ${recordId}`);
    res.json({
      success: true,
      message: '건강 기록을 가져왔습니다.',
      data: records[0],
    });
  } catch (error) {
    console.error('❌ [DailyHealth] 기록 조회 실패:', error);
    res.status(500).json({
      success: false,
      message: '건강 기록 조회에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    일일 건강 기록 생성
 * @route   POST /api/v1/daily-health/records
 * @access  Private
 */
export const createDailyHealthRecord = async (req, res) => {
  try {
    const userId = req.user.uid;
    const {
      petId,
      recordDate,
      mealCount,
      poopCount,
      exerciseDuration,
      sleepDuration,
      mood,
      condition,
      symptoms,
      notes,
    } = req.body;

    // 테이블이 없으면 생성
    await pool.query(`
      CREATE TABLE IF NOT EXISTS daily_health_records (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        pet_id INT NOT NULL,
        record_date DATE NOT NULL,
        meal_count INT DEFAULT 0,
        poop_count INT DEFAULT 0,
        exercise_duration INT DEFAULT 0 COMMENT '운동 시간 (분)',
        sleep_duration INT DEFAULT 0 COMMENT '수면 시간 (분)',
        mood VARCHAR(50) COMMENT '기분: good, normal, bad',
        condition VARCHAR(50) COMMENT '컨디션: excellent, good, normal, poor',
        symptoms JSON COMMENT '증상 목록',
        notes TEXT COMMENT '메모',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY unique_record (pet_id, record_date),
        INDEX idx_user_id (user_id),
        INDEX idx_pet_id (pet_id),
        INDEX idx_record_date (record_date),
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // 기록 생성 (같은 날짜에 이미 있으면 업데이트)
    const [result] = await pool.query(
      `
      INSERT INTO daily_health_records
        (user_id, pet_id, record_date, meal_count, poop_count, exercise_duration,
         sleep_duration, mood, \`condition\`, symptoms, notes)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        meal_count = VALUES(meal_count),
        poop_count = VALUES(poop_count),
        exercise_duration = VALUES(exercise_duration),
        sleep_duration = VALUES(sleep_duration),
        mood = VALUES(mood),
        \`condition\` = VALUES(\`condition\`),
        symptoms = VALUES(symptoms),
        notes = VALUES(notes),
        updated_at = CURRENT_TIMESTAMP
      `,
      [
        userId,
        petId,
        recordDate,
        mealCount || 0,
        poopCount || 0,
        exerciseDuration || 0,
        sleepDuration || 0,
        mood || null,
        condition || null,
        JSON.stringify(symptoms || []),
        notes || null,
      ]
    );

    // 생성/업데이트된 기록 조회
    const [records] = await pool.query(
      'SELECT * FROM daily_health_records WHERE pet_id = ? AND record_date = ?',
      [petId, recordDate]
    );

    console.log(`✅ [DailyHealth] 건강 기록 생성/업데이트: ${petId} - ${recordDate}`);
    res.status(201).json({
      success: true,
      message: '일일 건강 기록을 저장했습니다.',
      data: records[0],
    });
  } catch (error) {
    console.error('❌ [DailyHealth] 기록 생성 실패:', error);
    res.status(500).json({
      success: false,
      message: '일일 건강 기록 저장에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    일일 건강 기록 수정
 * @route   PUT /api/v1/daily-health/records/:recordId
 * @access  Private
 */
export const updateDailyHealthRecord = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { recordId } = req.params;
    const {
      mealCount,
      poopCount,
      exerciseDuration,
      sleepDuration,
      mood,
      condition,
      symptoms,
      notes,
    } = req.body;

    // 소유권 확인
    const [existing] = await pool.query(
      'SELECT * FROM daily_health_records WHERE id = ? AND user_id = ?',
      [recordId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: '건강 기록을 찾을 수 없거나 수정 권한이 없습니다.',
      });
    }

    // 수정
    await pool.query(
      `
      UPDATE daily_health_records
      SET meal_count = ?, poop_count = ?, exercise_duration = ?,
          sleep_duration = ?, mood = ?, \`condition\` = ?, symptoms = ?, notes = ?
      WHERE id = ? AND user_id = ?
      `,
      [
        mealCount !== undefined ? mealCount : existing[0].meal_count,
        poopCount !== undefined ? poopCount : existing[0].poop_count,
        exerciseDuration !== undefined ? exerciseDuration : existing[0].exercise_duration,
        sleepDuration !== undefined ? sleepDuration : existing[0].sleep_duration,
        mood !== undefined ? mood : existing[0].mood,
        condition !== undefined ? condition : existing[0].condition,
        symptoms !== undefined ? JSON.stringify(symptoms) : existing[0].symptoms,
        notes !== undefined ? notes : existing[0].notes,
        recordId,
        userId,
      ]
    );

    // 수정된 기록 조회
    const [records] = await pool.query(
      'SELECT * FROM daily_health_records WHERE id = ?',
      [recordId]
    );

    console.log(`✅ [DailyHealth] 건강 기록 수정: ${recordId}`);
    res.json({
      success: true,
      message: '일일 건강 기록을 수정했습니다.',
      data: records[0],
    });
  } catch (error) {
    console.error('❌ [DailyHealth] 기록 수정 실패:', error);
    res.status(500).json({
      success: false,
      message: '일일 건강 기록 수정에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    일일 건강 기록 삭제
 * @route   DELETE /api/v1/daily-health/records/:recordId
 * @access  Private
 */
export const deleteDailyHealthRecord = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { recordId } = req.params;

    // 소유권 확인
    const [existing] = await pool.query(
      'SELECT * FROM daily_health_records WHERE id = ? AND user_id = ?',
      [recordId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: '건강 기록을 찾을 수 없거나 삭제 권한이 없습니다.',
      });
    }

    // 삭제
    await pool.query('DELETE FROM daily_health_records WHERE id = ?', [recordId]);

    console.log(`✅ [DailyHealth] 건강 기록 삭제: ${recordId}`);
    res.json({
      success: true,
      message: '일일 건강 기록을 삭제했습니다.',
    });
  } catch (error) {
    console.error('❌ [DailyHealth] 기록 삭제 실패:', error);
    res.status(500).json({
      success: false,
      message: '일일 건강 기록 삭제에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    일일 건강 통계 조회
 * @route   GET /api/v1/daily-health/stats
 * @access  Private
 */
export const getDailyHealthStats = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { petId, startDate, endDate } = req.query;

    if (!petId) {
      return res.status(400).json({
        success: false,
        message: 'petId가 필요합니다.',
      });
    }

    let dateFilter = '';
    const params = [petId, userId];

    if (startDate && endDate) {
      dateFilter = 'AND record_date BETWEEN ? AND ?';
      params.push(startDate, endDate);
    } else if (startDate) {
      dateFilter = 'AND record_date >= ?';
      params.push(startDate);
    } else if (endDate) {
      dateFilter = 'AND record_date <= ?';
      params.push(endDate);
    }

    // 통계 계산
    const [stats] = await pool.query(
      `
      SELECT
        COUNT(*) as total_records,
        AVG(meal_count) as avg_meals,
        AVG(poop_count) as avg_poops,
        AVG(exercise_duration) as avg_exercise,
        AVG(sleep_duration) as avg_sleep,
        SUM(exercise_duration) as total_exercise,
        SUM(sleep_duration) as total_sleep
      FROM daily_health_records
      WHERE pet_id = ? AND user_id = ? ${dateFilter}
      `,
      params
    );

    // 기분 분포
    const [moodDistribution] = await pool.query(
      `
      SELECT mood, COUNT(*) as count
      FROM daily_health_records
      WHERE pet_id = ? AND user_id = ? AND mood IS NOT NULL ${dateFilter}
      GROUP BY mood
      `,
      params
    );

    // 컨디션 분포
    const [conditionDistribution] = await pool.query(
      `
      SELECT \`condition\`, COUNT(*) as count
      FROM daily_health_records
      WHERE pet_id = ? AND user_id = ? AND \`condition\` IS NOT NULL ${dateFilter}
      GROUP BY \`condition\`
      `,
      params
    );

    console.log(`✅ [DailyHealth] 통계 조회: ${petId}`);
    res.json({
      success: true,
      message: '건강 통계를 가져왔습니다.',
      data: {
        summary: stats[0],
        moodDistribution,
        conditionDistribution,
      },
    });
  } catch (error) {
    console.error('❌ [DailyHealth] 통계 조회 실패:', error);
    res.status(500).json({
      success: false,
      message: '건강 통계 조회에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    특정 날짜의 건강 기록 조회 (날짜로)
 * @route   GET /api/v1/daily-health/records/by-date
 * @access  Private
 */
export const getDailyHealthRecordByDate = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { petId, recordDate } = req.query;

    if (!petId || !recordDate) {
      return res.status(400).json({
        success: false,
        message: 'petId와 recordDate가 필요합니다.',
      });
    }

    const [records] = await pool.query(
      'SELECT * FROM daily_health_records WHERE pet_id = ? AND user_id = ? AND record_date = ?',
      [petId, userId, recordDate]
    );

    if (records.length === 0) {
      return res.status(404).json({
        success: false,
        message: '해당 날짜의 건강 기록이 없습니다.',
      });
    }

    console.log(`✅ [DailyHealth] 날짜별 기록 조회: ${petId} - ${recordDate}`);
    res.json({
      success: true,
      message: '건강 기록을 가져왔습니다.',
      data: records[0],
    });
  } catch (error) {
    console.error('❌ [DailyHealth] 날짜별 기록 조회 실패:', error);
    res.status(500).json({
      success: false,
      message: '건강 기록 조회에 실패했습니다.',
      error: error.message,
    });
  }
};

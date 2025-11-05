import pool from '../config/database.js';
import { v4 as uuidv4 } from 'uuid';

// ===========================
// 산책 (Walks)
// ===========================

/**
 * 특정 펫의 산책 기록 조회
 */
export const getWalks = async (req, res) => {
  try {
    const { petId } = req.params;
    const ownerId = req.user.uid;
    const { startDate, endDate, limit = 50 } = req.query;

    // 펫 소유권 확인
    const [pet] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [petId, ownerId]
    );

    if (pet.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없습니다.',
      });
    }

    let query = 'SELECT * FROM walks WHERE pet_id = ?';
    const params = [petId];

    if (startDate) {
      query += ' AND start_time >= ?';
      params.push(startDate);
    }
    if (endDate) {
      query += ' AND start_time <= ?';
      params.push(endDate);
    }

    query += ' ORDER BY start_time DESC LIMIT ?';
    params.push(parseInt(limit));

    const [rows] = await pool.query(query, params);

    // route_data JSON 파싱
    const walks = rows.map((walk) => ({
      ...walk,
      route_data: walk.route_data ? JSON.parse(walk.route_data) : null,
    }));

    res.json({
      success: true,
      data: walks,
      count: walks.length,
    });
  } catch (error) {
    console.error('❌ [Activity] 산책 기록 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '산책 기록 조회 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 산책 기록 생성
 */
export const createWalk = async (req, res) => {
  try {
    const { petId } = req.params;
    const ownerId = req.user.uid;
    const {
      startTime,
      endTime,
      durationMinutes,
      distanceMeters,
      routeData,
      temperature,
      weather,
      poopCount,
      peeCount,
      notes,
    } = req.body;

    // 펫 소유권 확인
    const [pet] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [petId, ownerId]
    );

    if (pet.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없습니다.',
      });
    }

    const walkId = `walk_${Date.now()}_${uuidv4().split('-')[0]}`;

    await pool.query(
      `INSERT INTO walks (
        id, pet_id, start_time, end_time, duration_minutes, distance_meters,
        route_data, temperature, weather, poop_count, pee_count, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        walkId,
        petId,
        startTime,
        endTime || null,
        durationMinutes || null,
        distanceMeters || null,
        routeData ? JSON.stringify(routeData) : null,
        temperature || null,
        weather || null,
        poopCount || 0,
        peeCount || 0,
        notes || null,
      ]
    );

    const [rows] = await pool.query('SELECT * FROM walks WHERE id = ?', [walkId]);

    // route_data JSON 파싱
    const walk = {
      ...rows[0],
      route_data: rows[0].route_data ? JSON.parse(rows[0].route_data) : null,
    };

    console.log(`✅ [Activity] 산책 기록 생성: ${durationMinutes}분 (${walkId})`);

    res.status(201).json({
      success: true,
      message: '산책 기록이 생성되었습니다.',
      data: walk,
    });
  } catch (error) {
    console.error('❌ [Activity] 산책 기록 생성 에러:', error);
    res.status(500).json({
      success: false,
      error: '산책 기록 생성 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 산책 기록 업데이트
 */
export const updateWalk = async (req, res) => {
  try {
    const { petId, walkId } = req.params;
    const ownerId = req.user.uid;
    const {
      startTime,
      endTime,
      durationMinutes,
      distanceMeters,
      routeData,
      temperature,
      weather,
      poopCount,
      peeCount,
      notes,
    } = req.body;

    // 펫 소유권 확인
    const [pet] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [petId, ownerId]
    );

    if (pet.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없습니다.',
      });
    }

    // 산책 기록 존재 확인
    const [existing] = await pool.query(
      'SELECT * FROM walks WHERE id = ? AND pet_id = ?',
      [walkId, petId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        error: '산책 기록을 찾을 수 없습니다.',
      });
    }

    await pool.query(
      `UPDATE walks
       SET start_time = ?, end_time = ?, duration_minutes = ?, distance_meters = ?,
           route_data = ?, temperature = ?, weather = ?, poop_count = ?, pee_count = ?, notes = ?
       WHERE id = ? AND pet_id = ?`,
      [
        startTime || existing[0].start_time,
        endTime || existing[0].end_time,
        durationMinutes || existing[0].duration_minutes,
        distanceMeters || existing[0].distance_meters,
        routeData ? JSON.stringify(routeData) : existing[0].route_data,
        temperature || existing[0].temperature,
        weather || existing[0].weather,
        poopCount !== undefined ? poopCount : existing[0].poop_count,
        peeCount !== undefined ? peeCount : existing[0].pee_count,
        notes || existing[0].notes,
        walkId,
        petId,
      ]
    );

    const [rows] = await pool.query('SELECT * FROM walks WHERE id = ?', [walkId]);

    // route_data JSON 파싱
    const walk = {
      ...rows[0],
      route_data: rows[0].route_data ? JSON.parse(rows[0].route_data) : null,
    };

    console.log(`✅ [Activity] 산책 기록 업데이트: ${walk.duration_minutes}분`);

    res.json({
      success: true,
      message: '산책 기록이 업데이트되었습니다.',
      data: walk,
    });
  } catch (error) {
    console.error('❌ [Activity] 산책 기록 업데이트 에러:', error);
    res.status(500).json({
      success: false,
      error: '산책 기록 업데이트 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 산책 기록 삭제
 */
export const deleteWalk = async (req, res) => {
  try {
    const { petId, walkId } = req.params;
    const ownerId = req.user.uid;

    // 펫 소유권 확인
    const [pet] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [petId, ownerId]
    );

    if (pet.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없습니다.',
      });
    }

    await pool.query('DELETE FROM walks WHERE id = ? AND pet_id = ?', [walkId, petId]);

    console.log(`✅ [Activity] 산책 기록 삭제: ${walkId}`);

    res.json({
      success: true,
      message: '산책 기록이 삭제되었습니다.',
    });
  } catch (error) {
    console.error('❌ [Activity] 산책 기록 삭제 에러:', error);
    res.status(500).json({
      success: false,
      error: '산책 기록 삭제 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 산책 통계 조회
 */
export const getWalkStats = async (req, res) => {
  try {
    const { petId } = req.params;
    const ownerId = req.user.uid;
    const { period = '7' } = req.query; // 기본 7일

    // 펫 소유권 확인
    const [pet] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [petId, ownerId]
    );

    if (pet.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없습니다.',
      });
    }

    // 기간별 통계
    const [stats] = await pool.query(
      `SELECT
        COUNT(*) as total_walks,
        SUM(duration_minutes) as total_minutes,
        SUM(distance_meters) as total_meters,
        AVG(duration_minutes) as avg_minutes,
        AVG(distance_meters) as avg_meters
       FROM walks
       WHERE pet_id = ? AND start_time >= DATE_SUB(NOW(), INTERVAL ? DAY)`,
      [petId, parseInt(period)]
    );

    res.json({
      success: true,
      data: {
        period: `${period}일`,
        totalWalks: stats[0].total_walks || 0,
        totalMinutes: stats[0].total_minutes || 0,
        totalMeters: stats[0].total_meters || 0,
        avgMinutes: Math.round(stats[0].avg_minutes || 0),
        avgMeters: Math.round(stats[0].avg_meters || 0),
      },
    });
  } catch (error) {
    console.error('❌ [Activity] 산책 통계 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '산책 통계 조회 중 오류 발생',
      message: error.message,
    });
  }
};

// ===========================
// 급식 (Feedings)
// ===========================

/**
 * 특정 펫의 급식 기록 조회
 */
export const getFeedings = async (req, res) => {
  try {
    const { petId } = req.params;
    const ownerId = req.user.uid;
    const { startDate, endDate, limit = 50 } = req.query;

    // 펫 소유권 확인
    const [pet] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [petId, ownerId]
    );

    if (pet.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없습니다.',
      });
    }

    let query = 'SELECT * FROM feedings WHERE pet_id = ?';
    const params = [petId];

    if (startDate) {
      query += ' AND feeding_time >= ?';
      params.push(startDate);
    }
    if (endDate) {
      query += ' AND feeding_time <= ?';
      params.push(endDate);
    }

    query += ' ORDER BY feeding_time DESC LIMIT ?';
    params.push(parseInt(limit));

    const [rows] = await pool.query(query, params);

    res.json({
      success: true,
      data: rows,
      count: rows.length,
    });
  } catch (error) {
    console.error('❌ [Activity] 급식 기록 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '급식 기록 조회 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 급식 기록 생성
 */
export const createFeeding = async (req, res) => {
  try {
    const { petId } = req.params;
    const ownerId = req.user.uid;
    const { feedingTime, foodType, foodBrand, amountGrams, mealType, notes } = req.body;

    // 펫 소유권 확인
    const [pet] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [petId, ownerId]
    );

    if (pet.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없습니다.',
      });
    }

    const feedingId = `feed_${Date.now()}_${uuidv4().split('-')[0]}`;

    await pool.query(
      `INSERT INTO feedings (
        id, pet_id, feeding_time, food_type, food_brand, amount_grams, meal_type, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        feedingId,
        petId,
        feedingTime || new Date(),
        foodType || null,
        foodBrand || null,
        amountGrams || null,
        mealType || 'snack',
        notes || null,
      ]
    );

    const [rows] = await pool.query('SELECT * FROM feedings WHERE id = ?', [feedingId]);

    console.log(`✅ [Activity] 급식 기록 생성: ${mealType} (${feedingId})`);

    res.status(201).json({
      success: true,
      message: '급식 기록이 생성되었습니다.',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ [Activity] 급식 기록 생성 에러:', error);
    res.status(500).json({
      success: false,
      error: '급식 기록 생성 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 급식 기록 업데이트
 */
export const updateFeeding = async (req, res) => {
  try {
    const { petId, feedingId } = req.params;
    const ownerId = req.user.uid;
    const { feedingTime, foodType, foodBrand, amountGrams, mealType, notes } = req.body;

    // 펫 소유권 확인
    const [pet] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [petId, ownerId]
    );

    if (pet.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없습니다.',
      });
    }

    // 급식 기록 존재 확인
    const [existing] = await pool.query(
      'SELECT * FROM feedings WHERE id = ? AND pet_id = ?',
      [feedingId, petId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        error: '급식 기록을 찾을 수 없습니다.',
      });
    }

    await pool.query(
      `UPDATE feedings
       SET feeding_time = ?, food_type = ?, food_brand = ?, amount_grams = ?, meal_type = ?, notes = ?
       WHERE id = ? AND pet_id = ?`,
      [
        feedingTime || existing[0].feeding_time,
        foodType || existing[0].food_type,
        foodBrand || existing[0].food_brand,
        amountGrams || existing[0].amount_grams,
        mealType || existing[0].meal_type,
        notes || existing[0].notes,
        feedingId,
        petId,
      ]
    );

    const [rows] = await pool.query('SELECT * FROM feedings WHERE id = ?', [feedingId]);

    console.log(`✅ [Activity] 급식 기록 업데이트: ${rows[0].meal_type}`);

    res.json({
      success: true,
      message: '급식 기록이 업데이트되었습니다.',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ [Activity] 급식 기록 업데이트 에러:', error);
    res.status(500).json({
      success: false,
      error: '급식 기록 업데이트 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 급식 기록 삭제
 */
export const deleteFeeding = async (req, res) => {
  try {
    const { petId, feedingId } = req.params;
    const ownerId = req.user.uid;

    // 펫 소유권 확인
    const [pet] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [petId, ownerId]
    );

    if (pet.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없습니다.',
      });
    }

    await pool.query('DELETE FROM feedings WHERE id = ? AND pet_id = ?', [feedingId, petId]);

    console.log(`✅ [Activity] 급식 기록 삭제: ${feedingId}`);

    res.json({
      success: true,
      message: '급식 기록이 삭제되었습니다.',
    });
  } catch (error) {
    console.error('❌ [Activity] 급식 기록 삭제 에러:', error);
    res.status(500).json({
      success: false,
      error: '급식 기록 삭제 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 급식 통계 조회
 */
export const getFeedingStats = async (req, res) => {
  try {
    const { petId } = req.params;
    const ownerId = req.user.uid;
    const { period = '7' } = req.query; // 기본 7일

    // 펫 소유권 확인
    const [pet] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [petId, ownerId]
    );

    if (pet.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없습니다.',
      });
    }

    // 기간별 통계
    const [stats] = await pool.query(
      `SELECT
        COUNT(*) as total_feedings,
        SUM(amount_grams) as total_grams,
        AVG(amount_grams) as avg_grams,
        meal_type,
        COUNT(*) as count_by_type
       FROM feedings
       WHERE pet_id = ? AND feeding_time >= DATE_SUB(NOW(), INTERVAL ? DAY)
       GROUP BY meal_type`,
      [petId, parseInt(period)]
    );

    res.json({
      success: true,
      data: {
        period: `${period}일`,
        byMealType: stats,
        totalFeedings: stats.reduce((sum, s) => sum + s.count_by_type, 0),
        totalGrams: stats.reduce((sum, s) => sum + (s.total_grams || 0), 0),
      },
    });
  } catch (error) {
    console.error('❌ [Activity] 급식 통계 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '급식 통계 조회 중 오류 발생',
      message: error.message,
    });
  }
};

// ===========================
// 기타 활동 (Activities)
// ===========================

/**
 * 특정 펫의 기타 활동 기록 조회
 */
export const getActivities = async (req, res) => {
  try {
    const { petId } = req.params;
    const ownerId = req.user.uid;
    const { activityType, startDate, endDate, limit = 50 } = req.query;

    // 펫 소유권 확인
    const [pet] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [petId, ownerId]
    );

    if (pet.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없습니다.',
      });
    }

    let query = 'SELECT * FROM activities WHERE pet_id = ?';
    const params = [petId];

    if (activityType) {
      query += ' AND activity_type = ?';
      params.push(activityType);
    }
    if (startDate) {
      query += ' AND start_time >= ?';
      params.push(startDate);
    }
    if (endDate) {
      query += ' AND start_time <= ?';
      params.push(endDate);
    }

    query += ' ORDER BY start_time DESC LIMIT ?';
    params.push(parseInt(limit));

    const [rows] = await pool.query(query, params);

    res.json({
      success: true,
      data: rows,
      count: rows.length,
    });
  } catch (error) {
    console.error('❌ [Activity] 활동 기록 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '활동 기록 조회 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 기타 활동 기록 생성
 */
export const createActivity = async (req, res) => {
  try {
    const { petId } = req.params;
    const ownerId = req.user.uid;
    const { activityType, startTime, endTime, durationMinutes, notes } = req.body;

    // 펫 소유권 확인
    const [pet] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [petId, ownerId]
    );

    if (pet.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없습니다.',
      });
    }

    const activityId = `act_${Date.now()}_${uuidv4().split('-')[0]}`;

    await pool.query(
      `INSERT INTO activities (
        id, pet_id, activity_type, start_time, end_time, duration_minutes, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        activityId,
        petId,
        activityType,
        startTime,
        endTime || null,
        durationMinutes || null,
        notes || null,
      ]
    );

    const [rows] = await pool.query('SELECT * FROM activities WHERE id = ?', [activityId]);

    console.log(`✅ [Activity] 활동 기록 생성: ${activityType} (${activityId})`);

    res.status(201).json({
      success: true,
      message: '활동 기록이 생성되었습니다.',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ [Activity] 활동 기록 생성 에러:', error);
    res.status(500).json({
      success: false,
      error: '활동 기록 생성 중 오류 발생',
      message: error.message,
    });
  }
};

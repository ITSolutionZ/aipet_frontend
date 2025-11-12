import pool from '../config/database.js';

/**
 * @desc    스케줄 목록 조회
 * @route   GET /api/v1/schedules
 * @access  Private
 */
export const getSchedules = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { petId, type, status, startDate, endDate, limit = 100 } = req.query;

    let query = `
      SELECT * FROM schedules
      WHERE user_id = ?
    `;
    const params = [userId];

    // Pet 필터
    if (petId) {
      query += ' AND pet_id = ?';
      params.push(petId);
    }

    // Type 필터
    if (type) {
      query += ' AND type = ?';
      params.push(type);
    }

    // Status 필터
    if (status) {
      query += ' AND status = ?';
      params.push(status);
    }

    // 날짜 범위 필터
    if (startDate) {
      query += ' AND start_datetime >= ?';
      params.push(startDate);
    }
    if (endDate) {
      query += ' AND start_datetime <= ?';
      params.push(endDate);
    }

    query += ' ORDER BY start_datetime ASC LIMIT ?';
    params.push(parseInt(limit));

    const [schedules] = await pool.query(query, params);

    // JSON 필드 파싱
    const parsedSchedules = schedules.map((schedule) => ({
      ...schedule,
      services: schedule.services ? JSON.parse(schedule.services) : null,
      reminder_times: schedule.reminder_times
        ? JSON.parse(schedule.reminder_times)
        : null,
      custom_data: schedule.custom_data
        ? JSON.parse(schedule.custom_data)
        : null,
    }));

    console.log(`✅ [Schedule] 스케줄 목록 조회: ${parsedSchedules.length}개`);
    res.json({
      success: true,
      message: 'スケジュールリストを取得しました',
      data: parsedSchedules,
    });
  } catch (error) {
    console.error('❌ [Schedule] 스케줄 목록 조회 실패:', error);
    res.status(500).json({
      success: false,
      error: 'スケジュールリストの取得に失敗しました',
      message: error.message,
    });
  }
};

/**
 * @desc    스케줄 상세 조회
 * @route   GET /api/v1/schedules/:scheduleId
 * @access  Private
 */
export const getScheduleById = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { scheduleId } = req.params;

    const [schedules] = await pool.query(
      'SELECT * FROM schedules WHERE id = ? AND user_id = ?',
      [scheduleId, userId]
    );

    if (schedules.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'スケジュールが見つかりません',
      });
    }

    const schedule = {
      ...schedules[0],
      services: schedules[0].services
        ? JSON.parse(schedules[0].services)
        : null,
      reminder_times: schedules[0].reminder_times
        ? JSON.parse(schedules[0].reminder_times)
        : null,
      custom_data: schedules[0].custom_data
        ? JSON.parse(schedules[0].custom_data)
        : null,
    };

    console.log(`✅ [Schedule] 스케줄 조회: ${scheduleId}`);
    res.json({
      success: true,
      message: 'スケジュールを取得しました',
      data: schedule,
    });
  } catch (error) {
    console.error('❌ [Schedule] 스케줄 조회 실패:', error);
    res.status(500).json({
      success: false,
      error: 'スケジュールの取得に失敗しました',
      message: error.message,
    });
  }
};

/**
 * @desc    스케줄 생성
 * @route   POST /api/v1/schedules
 * @access  Private
 */
export const createSchedule = async (req, res) => {
  try {
    const userId = req.user.uid;
    const {
      petId,
      title,
      description,
      startDateTime,
      endDateTime,
      duration,
      type,
      status,
      priority,
      location,
      latitude,
      longitude,
      facilityId,
      facilityName,
      staffName,
      staffPhone,
      price,
      services,
      hasReminder,
      reminderTime,
      reminderTimes,
      isRecurring,
      recurrenceRule,
      notes,
      specialRequests,
      customData,
    } = req.body;

    // schedules 테이블이 없으면 생성
    await pool.query(`
      CREATE TABLE IF NOT EXISTS schedules (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        pet_id INT NOT NULL,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        start_datetime DATETIME NOT NULL,
        end_datetime DATETIME,
        duration INT COMMENT '기간 (분)',
        type VARCHAR(50) NOT NULL COMMENT 'walk, feeding, medication, grooming, medical, hotel, daycare, training, checkup, vaccination, weight, custom',
        status VARCHAR(50) DEFAULT 'pending' COMMENT 'pending, confirmed, inProgress, completed, cancelled, missed',
        priority VARCHAR(50) DEFAULT 'normal' COMMENT 'low, normal, high, urgent',
        location VARCHAR(255),
        latitude DECIMAL(10, 8),
        longitude DECIMAL(11, 8),
        facility_id VARCHAR(255),
        facility_name VARCHAR(255),
        staff_name VARCHAR(100),
        staff_phone VARCHAR(50),
        price DECIMAL(10, 2),
        services JSON COMMENT '서비스 목록',
        has_reminder BOOLEAN DEFAULT FALSE,
        reminder_time INT COMMENT '알림 시간 (분)',
        reminder_times JSON COMMENT '여러 알림 시간 (분 배열)',
        is_recurring BOOLEAN DEFAULT FALSE,
        recurrence_rule TEXT COMMENT 'RRULE 형식',
        notes TEXT,
        special_requests TEXT,
        custom_data JSON,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_user_id (user_id),
        INDEX idx_pet_id (pet_id),
        INDEX idx_start_datetime (start_datetime),
        INDEX idx_type (type),
        INDEX idx_status (status),
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // 스케줄 생성
    const [result] = await pool.query(
      `
      INSERT INTO schedules
        (user_id, pet_id, title, description, start_datetime, end_datetime, duration,
         type, status, priority, location, latitude, longitude, facility_id, facility_name,
         staff_name, staff_phone, price, services, has_reminder, reminder_time,
         reminder_times, is_recurring, recurrence_rule, notes, special_requests, custom_data)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `,
      [
        userId,
        petId,
        title,
        description || null,
        startDateTime,
        endDateTime || null,
        duration || null,
        type,
        status || 'pending',
        priority || 'normal',
        location || null,
        latitude || null,
        longitude || null,
        facilityId || null,
        facilityName || null,
        staffName || null,
        staffPhone || null,
        price || null,
        services ? JSON.stringify(services) : null,
        hasReminder || false,
        reminderTime || null,
        reminderTimes ? JSON.stringify(reminderTimes) : null,
        isRecurring || false,
        recurrenceRule || null,
        notes || null,
        specialRequests || null,
        customData ? JSON.stringify(customData) : null,
      ]
    );

    // 생성된 스케줄 조회
    const [schedules] = await pool.query(
      'SELECT * FROM schedules WHERE id = ?',
      [result.insertId]
    );

    const schedule = {
      ...schedules[0],
      services: schedules[0].services
        ? JSON.parse(schedules[0].services)
        : null,
      reminder_times: schedules[0].reminder_times
        ? JSON.parse(schedules[0].reminder_times)
        : null,
      custom_data: schedules[0].custom_data
        ? JSON.parse(schedules[0].custom_data)
        : null,
    };

    console.log(`✅ [Schedule] 스케줄 생성 성공: ${result.insertId}`);
    res.status(201).json({
      success: true,
      message: 'スケジュールを作成しました',
      data: schedule,
    });
  } catch (error) {
    console.error('❌ [Schedule] 스케줄 생성 실패:', error);
    res.status(500).json({
      success: false,
      error: 'スケジュールの作成に失敗しました',
      message: error.message,
    });
  }
};

/**
 * @desc    스케줄 업데이트
 * @route   PUT /api/v1/schedules/:scheduleId
 * @access  Private
 */
export const updateSchedule = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { scheduleId } = req.params;
    const {
      title,
      description,
      startDateTime,
      endDateTime,
      duration,
      type,
      status,
      priority,
      location,
      latitude,
      longitude,
      facilityId,
      facilityName,
      staffName,
      staffPhone,
      price,
      services,
      hasReminder,
      reminderTime,
      reminderTimes,
      isRecurring,
      recurrenceRule,
      notes,
      specialRequests,
      customData,
    } = req.body;

    // 소유권 확인
    const [existing] = await pool.query(
      'SELECT * FROM schedules WHERE id = ? AND user_id = ?',
      [scheduleId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'スケジュールが見つからないか、権限がありません',
      });
    }

    // 업데이트
    await pool.query(
      `
      UPDATE schedules
      SET title = ?, description = ?, start_datetime = ?, end_datetime = ?, duration = ?,
          type = ?, status = ?, priority = ?, location = ?, latitude = ?, longitude = ?,
          facility_id = ?, facility_name = ?, staff_name = ?, staff_phone = ?, price = ?,
          services = ?, has_reminder = ?, reminder_time = ?, reminder_times = ?,
          is_recurring = ?, recurrence_rule = ?, notes = ?, special_requests = ?,
          custom_data = ?, updated_at = NOW()
      WHERE id = ? AND user_id = ?
      `,
      [
        title !== undefined ? title : existing[0].title,
        description !== undefined ? description : existing[0].description,
        startDateTime !== undefined ? startDateTime : existing[0].start_datetime,
        endDateTime !== undefined ? endDateTime : existing[0].end_datetime,
        duration !== undefined ? duration : existing[0].duration,
        type !== undefined ? type : existing[0].type,
        status !== undefined ? status : existing[0].status,
        priority !== undefined ? priority : existing[0].priority,
        location !== undefined ? location : existing[0].location,
        latitude !== undefined ? latitude : existing[0].latitude,
        longitude !== undefined ? longitude : existing[0].longitude,
        facilityId !== undefined ? facilityId : existing[0].facility_id,
        facilityName !== undefined ? facilityName : existing[0].facility_name,
        staffName !== undefined ? staffName : existing[0].staff_name,
        staffPhone !== undefined ? staffPhone : existing[0].staff_phone,
        price !== undefined ? price : existing[0].price,
        services !== undefined
          ? JSON.stringify(services)
          : existing[0].services,
        hasReminder !== undefined ? hasReminder : existing[0].has_reminder,
        reminderTime !== undefined ? reminderTime : existing[0].reminder_time,
        reminderTimes !== undefined
          ? JSON.stringify(reminderTimes)
          : existing[0].reminder_times,
        isRecurring !== undefined ? isRecurring : existing[0].is_recurring,
        recurrenceRule !== undefined
          ? recurrenceRule
          : existing[0].recurrence_rule,
        notes !== undefined ? notes : existing[0].notes,
        specialRequests !== undefined
          ? specialRequests
          : existing[0].special_requests,
        customData !== undefined
          ? JSON.stringify(customData)
          : existing[0].custom_data,
        scheduleId,
        userId,
      ]
    );

    // 업데이트된 스케줄 조회
    const [schedules] = await pool.query(
      'SELECT * FROM schedules WHERE id = ?',
      [scheduleId]
    );

    const schedule = {
      ...schedules[0],
      services: schedules[0].services
        ? JSON.parse(schedules[0].services)
        : null,
      reminder_times: schedules[0].reminder_times
        ? JSON.parse(schedules[0].reminder_times)
        : null,
      custom_data: schedules[0].custom_data
        ? JSON.parse(schedules[0].custom_data)
        : null,
    };

    console.log(`✅ [Schedule] 스케줄 업데이트 성공: ${scheduleId}`);
    res.json({
      success: true,
      message: 'スケジュールを更新しました',
      data: schedule,
    });
  } catch (error) {
    console.error('❌ [Schedule] 스케줄 업데이트 실패:', error);
    res.status(500).json({
      success: false,
      error: 'スケジュールの更新に失敗しました',
      message: error.message,
    });
  }
};

/**
 * @desc    스케줄 삭제
 * @route   DELETE /api/v1/schedules/:scheduleId
 * @access  Private
 */
export const deleteSchedule = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { scheduleId } = req.params;

    // 소유권 확인
    const [existing] = await pool.query(
      'SELECT * FROM schedules WHERE id = ? AND user_id = ?',
      [scheduleId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'スケジュールが見つからないか、権限がありません',
      });
    }

    // 삭제
    await pool.query(
      'DELETE FROM schedules WHERE id = ? AND user_id = ?',
      [scheduleId, userId]
    );

    console.log(`✅ [Schedule] 스케줄 삭제 성공: ${scheduleId}`);
    res.json({
      success: true,
      message: 'スケジュールを削除しました',
    });
  } catch (error) {
    console.error('❌ [Schedule] 스케줄 삭제 실패:', error);
    res.status(500).json({
      success: false,
      error: 'スケジュールの削除に失敗しました',
      message: error.message,
    });
  }
};

/**
 * @desc    스케줄 상태 변경
 * @route   PUT /api/v1/schedules/:scheduleId/status
 * @access  Private
 */
export const updateScheduleStatus = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { scheduleId } = req.params;
    const { status } = req.body;

    const validStatuses = [
      'pending',
      'confirmed',
      'inProgress',
      'completed',
      'cancelled',
      'missed',
    ];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        error: '無効なステータスです',
      });
    }

    // 소유권 확인
    const [existing] = await pool.query(
      'SELECT * FROM schedules WHERE id = ? AND user_id = ?',
      [scheduleId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'スケジュールが見つからないか、権限がありません',
      });
    }

    // 상태 변경
    await pool.query(
      'UPDATE schedules SET status = ?, updated_at = NOW() WHERE id = ?',
      [status, scheduleId]
    );

    // 변경된 스케줄 조회
    const [schedules] = await pool.query(
      'SELECT * FROM schedules WHERE id = ?',
      [scheduleId]
    );

    const schedule = {
      ...schedules[0],
      services: schedules[0].services
        ? JSON.parse(schedules[0].services)
        : null,
      reminder_times: schedules[0].reminder_times
        ? JSON.parse(schedules[0].reminder_times)
        : null,
      custom_data: schedules[0].custom_data
        ? JSON.parse(schedules[0].custom_data)
        : null,
    };

    console.log(`✅ [Schedule] 스케줄 상태 변경: ${scheduleId} -> ${status}`);
    res.json({
      success: true,
      message: 'スケジュールステータスを変更しました',
      data: schedule,
    });
  } catch (error) {
    console.error('❌ [Schedule] 스케줄 상태 변경 실패:', error);
    res.status(500).json({
      success: false,
      error: 'スケジュールステータスの変更に失敗しました',
      message: error.message,
    });
  }
};

import pool from '../config/database.js';

/**
 * @desc    예약 목록 조회
 * @route   GET /api/v1/bookings
 * @access  Private
 */
export const getBookings = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { petId, status, startDate, endDate, limit = 50 } = req.query;

    let query = `
      SELECT * FROM bookings
      WHERE user_id = ?
    `;
    const params = [userId];

    // Pet 필터
    if (petId) {
      query += ' AND pet_id = ?';
      params.push(petId);
    }

    // 상태 필터
    if (status) {
      query += ' AND status = ?';
      params.push(status);
    }

    // 날짜 범위 필터
    if (startDate) {
      query += ' AND booking_date >= ?';
      params.push(startDate);
    }
    if (endDate) {
      query += ' AND booking_date <= ?';
      params.push(endDate);
    }

    query += ' ORDER BY booking_date DESC, booking_time DESC LIMIT ?';
    params.push(parseInt(limit));

    const [bookings] = await pool.query(query, params);

    console.log(`✅ [Booking] 예약 목록 조회: ${bookings.length}개`);
    res.json({
      success: true,
      message: '예약 목록을 가져왔습니다.',
      data: bookings,
    });
  } catch (error) {
    console.error('❌ [Booking] 예약 목록 조회 실패:', error);
    res.status(500).json({
      success: false,
      message: '예약 목록 조회에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    예약 상세 조회
 * @route   GET /api/v1/bookings/:bookingId
 * @access  Private
 */
export const getBookingById = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { bookingId } = req.params;

    const [bookings] = await pool.query(
      'SELECT * FROM bookings WHERE id = ? AND user_id = ?',
      [bookingId, userId]
    );

    if (bookings.length === 0) {
      return res.status(404).json({
        success: false,
        message: '예약을 찾을 수 없습니다.',
      });
    }

    console.log(`✅ [Booking] 예약 조회: ${bookingId}`);
    res.json({
      success: true,
      message: '예약을 가져왔습니다.',
      data: bookings[0],
    });
  } catch (error) {
    console.error('❌ [Booking] 예약 조회 실패:', error);
    res.status(500).json({
      success: false,
      message: '예약 조회에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    예약 생성
 * @route   POST /api/v1/bookings
 * @access  Private
 */
export const createBooking = async (req, res) => {
  try {
    const userId = req.user.uid;
    const {
      petId,
      facilityId,
      facilityName,
      facilityType,
      facilityAddress,
      facilityPhone,
      bookingDate,
      bookingTime,
      serviceType,
      notes,
    } = req.body;

    // bookings 테이블이 없으면 생성
    await pool.query(`
      CREATE TABLE IF NOT EXISTS bookings (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        pet_id INT NOT NULL,
        facility_id VARCHAR(255) COMMENT '외부 시설 ID (Google Places 등)',
        facility_name VARCHAR(255) NOT NULL,
        facility_type VARCHAR(50) NOT NULL,
        facility_address TEXT,
        facility_phone VARCHAR(50),
        booking_date DATE NOT NULL,
        booking_time TIME NOT NULL,
        service_type VARCHAR(100) COMMENT '서비스 유형 (진료, 미용, 호텔 등)',
        status VARCHAR(50) DEFAULT 'pending' COMMENT 'pending, confirmed, cancelled, completed',
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_user_id (user_id),
        INDEX idx_pet_id (pet_id),
        INDEX idx_booking_date (booking_date),
        INDEX idx_status (status),
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // 예약 생성
    const [result] = await pool.query(
      `
      INSERT INTO bookings
        (user_id, pet_id, facility_id, facility_name, facility_type, facility_address,
         facility_phone, booking_date, booking_time, service_type, notes)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `,
      [
        userId,
        petId,
        facilityId || null,
        facilityName,
        facilityType,
        facilityAddress || null,
        facilityPhone || null,
        bookingDate,
        bookingTime,
        serviceType || null,
        notes || null,
      ]
    );

    // 생성된 예약 조회
    const [bookings] = await pool.query(
      'SELECT * FROM bookings WHERE id = ?',
      [result.insertId]
    );

    console.log(`✅ [Booking] 예약 생성: ${result.insertId}`);
    res.status(201).json({
      success: true,
      message: '예약을 생성했습니다.',
      data: bookings[0],
    });
  } catch (error) {
    console.error('❌ [Booking] 예약 생성 실패:', error);
    res.status(500).json({
      success: false,
      message: '예약 생성에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    예약 수정
 * @route   PUT /api/v1/bookings/:bookingId
 * @access  Private
 */
export const updateBooking = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { bookingId } = req.params;
    const {
      bookingDate,
      bookingTime,
      serviceType,
      notes,
    } = req.body;

    // 소유권 확인
    const [existing] = await pool.query(
      'SELECT * FROM bookings WHERE id = ? AND user_id = ?',
      [bookingId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: '예약을 찾을 수 없거나 수정 권한이 없습니다.',
      });
    }

    // 취소된 예약은 수정 불가
    if (existing[0].status === 'cancelled') {
      return res.status(400).json({
        success: false,
        message: '취소된 예약은 수정할 수 없습니다.',
      });
    }

    // 수정
    await pool.query(
      `
      UPDATE bookings
      SET booking_date = ?, booking_time = ?, service_type = ?, notes = ?
      WHERE id = ? AND user_id = ?
      `,
      [
        bookingDate !== undefined ? bookingDate : existing[0].booking_date,
        bookingTime !== undefined ? bookingTime : existing[0].booking_time,
        serviceType !== undefined ? serviceType : existing[0].service_type,
        notes !== undefined ? notes : existing[0].notes,
        bookingId,
        userId,
      ]
    );

    // 수정된 예약 조회
    const [bookings] = await pool.query(
      'SELECT * FROM bookings WHERE id = ?',
      [bookingId]
    );

    console.log(`✅ [Booking] 예약 수정: ${bookingId}`);
    res.json({
      success: true,
      message: '예약을 수정했습니다.',
      data: bookings[0],
    });
  } catch (error) {
    console.error('❌ [Booking] 예약 수정 실패:', error);
    res.status(500).json({
      success: false,
      message: '예약 수정에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    예약 취소
 * @route   DELETE /api/v1/bookings/:bookingId
 * @access  Private
 */
export const cancelBooking = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { bookingId } = req.params;

    // 소유권 확인
    const [existing] = await pool.query(
      'SELECT * FROM bookings WHERE id = ? AND user_id = ?',
      [bookingId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: '예약을 찾을 수 없거나 취소 권한이 없습니다.',
      });
    }

    // 이미 취소되었거나 완료된 예약은 취소 불가
    if (existing[0].status === 'cancelled') {
      return res.status(400).json({
        success: false,
        message: '이미 취소된 예약입니다.',
      });
    }
    if (existing[0].status === 'completed') {
      return res.status(400).json({
        success: false,
        message: '완료된 예약은 취소할 수 없습니다.',
      });
    }

    // 상태를 cancelled로 변경
    await pool.query(
      'UPDATE bookings SET status = ? WHERE id = ?',
      ['cancelled', bookingId]
    );

    console.log(`✅ [Booking] 예약 취소: ${bookingId}`);
    res.json({
      success: true,
      message: '예약을 취소했습니다.',
    });
  } catch (error) {
    console.error('❌ [Booking] 예약 취소 실패:', error);
    res.status(500).json({
      success: false,
      message: '예약 취소에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    예약 상태 변경
 * @route   PUT /api/v1/bookings/:bookingId/status
 * @access  Private
 */
export const updateBookingStatus = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { bookingId } = req.params;
    const { status } = req.body;

    // 유효한 상태인지 확인
    const validStatuses = ['pending', 'confirmed', 'cancelled', 'completed'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: '유효하지 않은 상태입니다.',
      });
    }

    // 소유권 확인
    const [existing] = await pool.query(
      'SELECT * FROM bookings WHERE id = ? AND user_id = ?',
      [bookingId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: '예약을 찾을 수 없거나 수정 권한이 없습니다.',
      });
    }

    // 상태 변경
    await pool.query(
      'UPDATE bookings SET status = ? WHERE id = ?',
      [status, bookingId]
    );

    // 변경된 예약 조회
    const [bookings] = await pool.query(
      'SELECT * FROM bookings WHERE id = ?',
      [bookingId]
    );

    console.log(`✅ [Booking] 예약 상태 변경: ${bookingId} -> ${status}`);
    res.json({
      success: true,
      message: '예약 상태를 변경했습니다.',
      data: bookings[0],
    });
  } catch (error) {
    console.error('❌ [Booking] 예약 상태 변경 실패:', error);
    res.status(500).json({
      success: false,
      message: '예약 상태 변경에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    다가오는 예약 조회
 * @route   GET /api/v1/bookings/upcoming
 * @access  Private
 */
export const getUpcomingBookings = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { limit = 10 } = req.query;

    const today = new Date().toISOString().split('T')[0];

    const [bookings] = await pool.query(
      `
      SELECT * FROM bookings
      WHERE user_id = ? AND booking_date >= ? AND status != 'cancelled'
      ORDER BY booking_date ASC, booking_time ASC
      LIMIT ?
      `,
      [userId, today, parseInt(limit)]
    );

    console.log(`✅ [Booking] 다가오는 예약 조회: ${bookings.length}개`);
    res.json({
      success: true,
      message: '다가오는 예약을 가져왔습니다.',
      data: bookings,
    });
  } catch (error) {
    console.error('❌ [Booking] 다가오는 예약 조회 실패:', error);
    res.status(500).json({
      success: false,
      message: '다가오는 예약 조회에 실패했습니다.',
      error: error.message,
    });
  }
};

/**
 * @desc    예약 이력 조회
 * @route   GET /api/v1/bookings/history
 * @access  Private
 */
export const getBookingHistory = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { limit = 50 } = req.query;

    const today = new Date().toISOString().split('T')[0];

    const [bookings] = await pool.query(
      `
      SELECT * FROM bookings
      WHERE user_id = ? AND (booking_date < ? OR status = 'completed' OR status = 'cancelled')
      ORDER BY booking_date DESC, booking_time DESC
      LIMIT ?
      `,
      [userId, today, parseInt(limit)]
    );

    console.log(`✅ [Booking] 예약 이력 조회: ${bookings.length}개`);
    res.json({
      success: true,
      message: '예약 이력을 가져왔습니다.',
      data: bookings,
    });
  } catch (error) {
    console.error('❌ [Booking] 예약 이력 조회 실패:', error);
    res.status(500).json({
      success: false,
      message: '예약 이력 조회에 실패했습니다.',
      error: error.message,
    });
  }
};

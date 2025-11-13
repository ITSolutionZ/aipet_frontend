import pool from '../config/database.js';
import { v4 as uuidv4 } from 'uuid';

// ===========================
// 예방접종 (Vaccinations)
// ===========================

/**
 * 특정 펫의 예방접종 기록 조회
 */
export const getVaccinations = async (req, res) => {
  try {
    const { petId } = req.params;
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

    // 예방접종 기록 조회
    const [rows] = await pool.query(
      'SELECT * FROM vaccinations WHERE pet_id = ? ORDER BY vaccination_date DESC',
      [petId]
    );

    res.json({
      success: true,
      data: rows,
      count: rows.length,
    });
  } catch (error) {
    console.error('❌ [Health] 예방접종 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '예방접종 조회 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 예방접종 기록 생성
 */
export const createVaccination = async (req, res) => {
  try {
    const { petId } = req.params;
    const ownerId = req.user.uid;
    const {
      vaccineName,
      vaccineType,
      vaccinationDate,
      nextDueDate,
      veterinarianName,
      clinicName,
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

    const vaccinationId = `vacc_${Date.now()}_${uuidv4().split('-')[0]}`;

    await pool.query(
      `INSERT INTO vaccinations (
        id, pet_id, vaccine_name, vaccine_type, vaccination_date,
        next_due_date, veterinarian_name, clinic_name, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        vaccinationId,
        petId,
        vaccineName,
        vaccineType || null,
        vaccinationDate,
        nextDueDate || null,
        veterinarianName || null,
        clinicName || null,
        notes || null,
      ]
    );

    const [rows] = await pool.query(
      'SELECT * FROM vaccinations WHERE id = ?',
      [vaccinationId]
    );

    console.log(`✅ [Health] 예방접종 기록 생성: ${vaccineName} (${vaccinationId})`);

    res.status(201).json({
      success: true,
      message: '예방접종 기록이 생성되었습니다.',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ [Health] 예방접종 생성 에러:', error);
    res.status(500).json({
      success: false,
      error: '예방접종 생성 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 예방접종 기록 업데이트
 */
export const updateVaccination = async (req, res) => {
  try {
    const { petId, vaccinationId } = req.params;
    const ownerId = req.user.uid;
    const {
      vaccineName,
      vaccineType,
      vaccinationDate,
      nextDueDate,
      veterinarianName,
      clinicName,
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

    // 예방접종 기록 존재 확인
    const [existing] = await pool.query(
      'SELECT * FROM vaccinations WHERE id = ? AND pet_id = ?',
      [vaccinationId, petId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        error: '예방접종 기록을 찾을 수 없습니다.',
      });
    }

    await pool.query(
      `UPDATE vaccinations
       SET vaccine_name = ?, vaccine_type = ?, vaccination_date = ?,
           next_due_date = ?, veterinarian_name = ?, clinic_name = ?, notes = ?,
           updated_at = NOW()
       WHERE id = ? AND pet_id = ?`,
      [
        vaccineName || existing[0].vaccine_name,
        vaccineType || existing[0].vaccine_type,
        vaccinationDate || existing[0].vaccination_date,
        nextDueDate || existing[0].next_due_date,
        veterinarianName || existing[0].veterinarian_name,
        clinicName || existing[0].clinic_name,
        notes || existing[0].notes,
        vaccinationId,
        petId,
      ]
    );

    const [rows] = await pool.query(
      'SELECT * FROM vaccinations WHERE id = ?',
      [vaccinationId]
    );

    console.log(`✅ [Health] 예방접종 기록 업데이트: ${rows[0].vaccine_name}`);

    res.json({
      success: true,
      message: '예방접종 기록이 업데이트되었습니다.',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ [Health] 예방접종 업데이트 에러:', error);
    res.status(500).json({
      success: false,
      error: '예방접종 업데이트 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 예방접종 기록 삭제
 */
export const deleteVaccination = async (req, res) => {
  try {
    const { petId, vaccinationId } = req.params;
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

    await pool.query(
      'DELETE FROM vaccinations WHERE id = ? AND pet_id = ?',
      [vaccinationId, petId]
    );

    console.log(`✅ [Health] 예방접종 기록 삭제: ${vaccinationId}`);

    res.json({
      success: true,
      message: '예방접종 기록이 삭제되었습니다.',
    });
  } catch (error) {
    console.error('❌ [Health] 예방접종 삭제 에러:', error);
    res.status(500).json({
      success: false,
      error: '예방접종 삭제 중 오류 발생',
      message: error.message,
    });
  }
};

// ===========================
// 의료 기록 (Medical Records)
// ===========================

/**
 * 특정 펫의 의료 기록 조회
 */
export const getMedicalRecords = async (req, res) => {
  try {
    const { petId } = req.params;
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

    // 의료 기록 조회
    const [rows] = await pool.query(
      'SELECT * FROM medical_records WHERE pet_id = ? ORDER BY visit_date DESC',
      [petId]
    );

    res.json({
      success: true,
      data: rows,
      count: rows.length,
    });
  } catch (error) {
    console.error('❌ [Health] 의료 기록 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '의료 기록 조회 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 의료 기록 생성
 */
export const createMedicalRecord = async (req, res) => {
  try {
    const { petId } = req.params;
    const ownerId = req.user.uid;
    const {
      visitDate,
      visitType,
      diagnosis,
      treatment,
      prescription,
      veterinarianName,
      clinicName,
      cost,
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

    const recordId = `med_${Date.now()}_${uuidv4().split('-')[0]}`;

    await pool.query(
      `INSERT INTO medical_records (
        id, pet_id, visit_date, visit_type, diagnosis, treatment,
        prescription, veterinarian_name, clinic_name, cost, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        recordId,
        petId,
        visitDate,
        visitType || null,
        diagnosis || null,
        treatment || null,
        prescription || null,
        veterinarianName || null,
        clinicName || null,
        cost || null,
        notes || null,
      ]
    );

    const [rows] = await pool.query(
      'SELECT * FROM medical_records WHERE id = ?',
      [recordId]
    );

    console.log(`✅ [Health] 의료 기록 생성: ${visitType} (${recordId})`);

    res.status(201).json({
      success: true,
      message: '의료 기록이 생성되었습니다.',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ [Health] 의료 기록 생성 에러:', error);
    res.status(500).json({
      success: false,
      error: '의료 기록 생성 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 의료 기록 업데이트
 */
export const updateMedicalRecord = async (req, res) => {
  try {
    const { petId, recordId } = req.params;
    const ownerId = req.user.uid;
    const {
      visitDate,
      visitType,
      diagnosis,
      treatment,
      prescription,
      veterinarianName,
      clinicName,
      cost,
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

    // 의료 기록 존재 확인
    const [existing] = await pool.query(
      'SELECT * FROM medical_records WHERE id = ? AND pet_id = ?',
      [recordId, petId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        error: '의료 기록을 찾을 수 없습니다.',
      });
    }

    await pool.query(
      `UPDATE medical_records
       SET visit_date = ?, visit_type = ?, diagnosis = ?, treatment = ?,
           prescription = ?, veterinarian_name = ?, clinic_name = ?, cost = ?, notes = ?,
           updated_at = NOW()
       WHERE id = ? AND pet_id = ?`,
      [
        visitDate || existing[0].visit_date,
        visitType || existing[0].visit_type,
        diagnosis || existing[0].diagnosis,
        treatment || existing[0].treatment,
        prescription || existing[0].prescription,
        veterinarianName || existing[0].veterinarian_name,
        clinicName || existing[0].clinic_name,
        cost || existing[0].cost,
        notes || existing[0].notes,
        recordId,
        petId,
      ]
    );

    const [rows] = await pool.query(
      'SELECT * FROM medical_records WHERE id = ?',
      [recordId]
    );

    console.log(`✅ [Health] 의료 기록 업데이트: ${rows[0].visit_type}`);

    res.json({
      success: true,
      message: '의료 기록이 업데이트되었습니다.',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ [Health] 의료 기록 업데이트 에러:', error);
    res.status(500).json({
      success: false,
      error: '의료 기록 업데이트 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 의료 기록 삭제
 */
export const deleteMedicalRecord = async (req, res) => {
  try {
    const { petId, recordId } = req.params;
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

    await pool.query(
      'DELETE FROM medical_records WHERE id = ? AND pet_id = ?',
      [recordId, petId]
    );

    console.log(`✅ [Health] 의료 기록 삭제: ${recordId}`);

    res.json({
      success: true,
      message: '의료 기록이 삭제되었습니다.',
    });
  } catch (error) {
    console.error('❌ [Health] 의료 기록 삭제 에러:', error);
    res.status(500).json({
      success: false,
      error: '의료 기록 삭제 중 오류 발생',
      message: error.message,
    });
  }
};

// ===========================
// 체중 기록 (Weight History)
// ===========================

/**
 * 특정 펫의 체중 기록 조회
 */
export const getWeightHistory = async (req, res) => {
  try {
    const { petId } = req.params;
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

    // 체중 기록 조회
    const [rows] = await pool.query(
      'SELECT * FROM weight_history WHERE pet_id = ? ORDER BY measured_at DESC',
      [petId]
    );

    res.json({
      success: true,
      data: rows,
      count: rows.length,
    });
  } catch (error) {
    console.error('❌ [Health] 체중 기록 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '체중 기록 조회 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 체중 기록 생성
 */
export const createWeightRecord = async (req, res) => {
  try {
    const { petId } = req.params;
    const ownerId = req.user.uid;
    const { weight, measuredAt, notes } = req.body;

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

    const recordId = `weight_${Date.now()}_${uuidv4().split('-')[0]}`;

    await pool.query(
      'INSERT INTO weight_history (id, pet_id, weight, measured_at, notes) VALUES (?, ?, ?, ?, ?)',
      [recordId, petId, weight, measuredAt || new Date(), notes || null]
    );

    // 펫의 현재 체중도 업데이트
    await pool.query(
      'UPDATE pets SET weight = ?, updated_at = NOW() WHERE id = ?',
      [weight, petId]
    );

    const [rows] = await pool.query(
      'SELECT * FROM weight_history WHERE id = ?',
      [recordId]
    );

    console.log(`✅ [Health] 체중 기록 생성: ${weight}kg (${recordId})`);

    res.status(201).json({
      success: true,
      message: '체중 기록이 생성되었습니다.',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ [Health] 체중 기록 생성 에러:', error);
    res.status(500).json({
      success: false,
      error: '체중 기록 생성 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 체중 기록 업데이트
 */
export const updateWeightRecord = async (req, res) => {
  try {
    const { petId, weightId } = req.params;
    const ownerId = req.user.uid;
    const { weight, measuredAt, notes } = req.body;

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

    // 체중 기록 존재 확인
    const [existing] = await pool.query(
      'SELECT * FROM weight_history WHERE id = ? AND pet_id = ?',
      [weightId, petId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        error: '체중 기록을 찾을 수 없습니다.',
      });
    }

    // 업데이트할 필드만 추출
    const updates = [];
    const values = [];

    if (weight !== undefined) {
      updates.push('weight = ?');
      values.push(weight);
    }
    if (measuredAt !== undefined) {
      updates.push('measured_at = ?');
      values.push(measuredAt);
    }
    if (notes !== undefined) {
      updates.push('notes = ?');
      values.push(notes);
    }

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        error: '업데이트할 내용이 없습니다.',
      });
    }

    updates.push('updated_at = NOW()');
    values.push(weightId);

    await pool.query(
      `UPDATE weight_history SET ${updates.join(', ')} WHERE id = ?`,
      values
    );

    // 가장 최근 체중으로 펫 정보 업데이트
    if (weight !== undefined) {
      const [latest] = await pool.query(
        'SELECT weight FROM weight_history WHERE pet_id = ? ORDER BY measured_at DESC LIMIT 1',
        [petId]
      );

      if (latest.length > 0) {
        await pool.query(
          'UPDATE pets SET weight = ?, updated_at = NOW() WHERE id = ?',
          [latest[0].weight, petId]
        );
      }
    }

    const [rows] = await pool.query(
      'SELECT * FROM weight_history WHERE id = ?',
      [weightId]
    );

    console.log(`✅ [Health] 체중 기록 업데이트: ${weightId}`);

    res.json({
      success: true,
      message: '체중 기록이 업데이트되었습니다.',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ [Health] 체중 기록 업데이트 에러:', error);
    res.status(500).json({
      success: false,
      error: '체중 기록 업데이트 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 체중 기록 삭제
 */
export const deleteWeightRecord = async (req, res) => {
  try {
    const { petId, weightId } = req.params;
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

    // 체중 기록 존재 확인
    const [existing] = await pool.query(
      'SELECT * FROM weight_history WHERE id = ? AND pet_id = ?',
      [weightId, petId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        error: '체중 기록을 찾을 수 없습니다.',
      });
    }

    // 체중 기록 삭제
    await pool.query('DELETE FROM weight_history WHERE id = ?', [weightId]);

    // 가장 최근 체중으로 펫 정보 업데이트
    const [latest] = await pool.query(
      'SELECT weight FROM weight_history WHERE pet_id = ? ORDER BY measured_at DESC LIMIT 1',
      [petId]
    );

    if (latest.length > 0) {
      await pool.query(
        'UPDATE pets SET weight = ?, updated_at = NOW() WHERE id = ?',
        [latest[0].weight, petId]
      );
    } else {
      // 모든 체중 기록이 삭제된 경우 NULL로 설정
      await pool.query(
        'UPDATE pets SET weight = NULL, updated_at = NOW() WHERE id = ?',
        [petId]
      );
    }

    console.log(`✅ [Health] 체중 기록 삭제: ${weightId}`);

    res.json({
      success: true,
      message: '체중 기록이 삭제되었습니다.',
    });
  } catch (error) {
    console.error('❌ [Health] 체중 기록 삭제 에러:', error);
    res.status(500).json({
      success: false,
      error: '체중 기록 삭제 중 오류 발생',
      message: error.message,
    });
  }
};

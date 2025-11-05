import pool from '../config/database.js';
import { v4 as uuidv4 } from 'uuid';

/**
 * 모든 펫 조회 (현재 사용자 소유)
 */
export const getAllPets = async (req, res) => {
  try {
    const ownerId = req.user.uid;

    const [rows] = await pool.query(
      'SELECT * FROM pets WHERE owner_id = ? AND is_active = true ORDER BY created_at DESC',
      [ownerId]
    );

    console.log(`✅ [Pet] 펫 목록 조회: ${rows.length}마리 (${req.user.email})`);

    res.json({
      success: true,
      data: rows,
      count: rows.length,
    });
  } catch (error) {
    console.error('❌ [Pet] 펫 목록 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '펫 목록 조회 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 특정 펫 조회
 */
export const getPetById = async (req, res) => {
  try {
    const { id } = req.params;
    const ownerId = req.user.uid;

    const [rows] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [id, ownerId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없습니다.',
      });
    }

    console.log(`✅ [Pet] 펫 상세 조회: ${rows[0].name} (${id})`);

    res.json({
      success: true,
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ [Pet] 펫 상세 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '펫 상세 조회 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 새 펫 생성
 */
export const createPet = async (req, res) => {
  try {
    const ownerId = req.user.uid;
    const {
      id,
      name,
      type,
      breed,
      birthDate,
      gender,
      weight,
      photoUrl,
      microchipNumber,
      isNeutered,
      color,
      notes,
    } = req.body;

    // 펫 ID 생성 (프론트엔드에서 제공한 ID가 있으면 사용, 없으면 생성)
    const petId = id || `pet_${Date.now()}_${uuidv4().split('-')[0]}`;

    // 펫 데이터 삽입
    await pool.query(
      `INSERT INTO pets (
        id, owner_id, name, type, breed, birth_date, gender, weight,
        photo_url, microchip_number, is_neutered, color, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        petId,
        ownerId,
        name,
        type,
        breed || null,
        birthDate || null,
        gender || 'unknown',
        weight || null,
        photoUrl || null,
        microchipNumber || null,
        isNeutered || false,
        color || null,
        notes || null,
      ]
    );

    // 생성된 펫 조회
    const [rows] = await pool.query('SELECT * FROM pets WHERE id = ?', [petId]);

    console.log(`✅ [Pet] 펫 생성 성공: ${name} (${petId})`);

    res.status(201).json({
      success: true,
      message: '펫이 생성되었습니다.',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ [Pet] 펫 생성 에러:', error);
    res.status(500).json({
      success: false,
      error: '펫 생성 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 펫 정보 업데이트
 */
export const updatePet = async (req, res) => {
  try {
    const { id } = req.params;
    const ownerId = req.user.uid;
    const {
      name,
      type,
      breed,
      birthDate,
      gender,
      weight,
      photoUrl,
      microchipNumber,
      isNeutered,
      color,
      notes,
    } = req.body;

    // 소유자 확인
    const [existing] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [id, ownerId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없거나 수정 권한이 없습니다.',
      });
    }

    // 펫 정보 업데이트
    await pool.query(
      `UPDATE pets
       SET name = ?, type = ?, breed = ?, birth_date = ?, gender = ?, weight = ?,
           photo_url = ?, microchip_number = ?, is_neutered = ?, color = ?, notes = ?,
           updated_at = NOW()
       WHERE id = ? AND owner_id = ?`,
      [
        name || existing[0].name,
        type || existing[0].type,
        breed || existing[0].breed,
        birthDate || existing[0].birth_date,
        gender || existing[0].gender,
        weight || existing[0].weight,
        photoUrl || existing[0].photo_url,
        microchipNumber || existing[0].microchip_number,
        isNeutered !== undefined ? isNeutered : existing[0].is_neutered,
        color || existing[0].color,
        notes || existing[0].notes,
        id,
        ownerId,
      ]
    );

    // 업데이트된 펫 조회
    const [rows] = await pool.query('SELECT * FROM pets WHERE id = ?', [id]);

    console.log(`✅ [Pet] 펫 업데이트 성공: ${rows[0].name} (${id})`);

    res.json({
      success: true,
      message: '펫 정보가 업데이트되었습니다.',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ [Pet] 펫 업데이트 에러:', error);
    res.status(500).json({
      success: false,
      error: '펫 업데이트 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 펫 삭제 (Soft Delete)
 */
export const deletePet = async (req, res) => {
  try {
    const { id } = req.params;
    const ownerId = req.user.uid;

    // 소유자 확인
    const [existing] = await pool.query(
      'SELECT * FROM pets WHERE id = ? AND owner_id = ? AND is_active = true',
      [id, ownerId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        error: '펫을 찾을 수 없거나 삭제 권한이 없습니다.',
      });
    }

    // Soft Delete (is_active를 false로 설정)
    await pool.query(
      'UPDATE pets SET is_active = false, updated_at = NOW() WHERE id = ? AND owner_id = ?',
      [id, ownerId]
    );

    console.log(`✅ [Pet] 펫 삭제 성공: ${existing[0].name} (${id})`);

    res.json({
      success: true,
      message: '펫이 삭제되었습니다.',
    });
  } catch (error) {
    console.error('❌ [Pet] 펫 삭제 에러:', error);
    res.status(500).json({
      success: false,
      error: '펫 삭제 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 펫 통계 정보 조회
 */
export const getPetStats = async (req, res) => {
  try {
    const ownerId = req.user.uid;

    // 전체 펫 수
    const [totalCount] = await pool.query(
      'SELECT COUNT(*) as total FROM pets WHERE owner_id = ? AND is_active = true',
      [ownerId]
    );

    // 펫 타입별 카운트
    const [typeCount] = await pool.query(
      'SELECT type, COUNT(*) as count FROM pets WHERE owner_id = ? AND is_active = true GROUP BY type',
      [ownerId]
    );

    res.json({
      success: true,
      data: {
        totalPets: totalCount[0].total,
        byType: typeCount,
      },
    });
  } catch (error) {
    console.error('❌ [Pet] 펫 통계 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '펫 통계 조회 중 오류 발생',
      message: error.message,
    });
  }
};

import pool from '../config/database.js';

/**
 * 알레르기 컨트롤러
 *
 * 펫의 알레르기 기록을 관리합니다.
 */

/**
 * 펫의 알레르기 기록 조회
 * GET /allergy/pets/:petId/records
 */
export const getAllergyRecords = async (req, res) => {
  const userId = req.user.uid;
  const { petId } = req.params;
  const { severity, limit = 100 } = req.query;

  try {
    // allergy_records 테이블 자동 생성
    await pool.query(`
      CREATE TABLE IF NOT EXISTS allergy_records (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        pet_id INT NOT NULL,
        products JSON,
        reactions JSON,
        severity VARCHAR(20) NOT NULL,
        occurred_at TIMESTAMP NOT NULL,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_user_pet (user_id, pet_id),
        INDEX idx_occurred_at (occurred_at)
      )
    `);

    // 쿼리 조건 구성
    const conditions = ['user_id = ?', 'pet_id = ?'];
    const values = [userId, petId];

    if (severity) {
      conditions.push('severity = ?');
      values.push(severity);
    }

    values.push(parseInt(limit));

    const [rows] = await pool.query(
      `SELECT
        id,
        pet_id,
        products,
        reactions,
        severity,
        occurred_at,
        notes,
        created_at,
        updated_at
      FROM allergy_records
      WHERE ${conditions.join(' AND ')}
      ORDER BY occurred_at DESC
      LIMIT ?`,
      values
    );

    // JSON 필드 파싱
    const records = rows.map((row) => ({
      ...row,
      products: row.products ? JSON.parse(row.products) : [],
      reactions: row.reactions ? JSON.parse(row.reactions) : [],
    }));

    return res.json({
      success: true,
      message: 'アレルギー記録を取得しました',
      data: records,
    });
  } catch (error) {
    console.error('❌ Error getting allergy records:', error);
    return res.status(500).json({
      success: false,
      message: 'アレルギー記録の取得に失敗しました',
      error: error.message,
    });
  }
};

/**
 * 알레르기 기록 상세 조회
 * GET /allergy/records/:recordId
 */
export const getAllergyRecordById = async (req, res) => {
  const userId = req.user.uid;
  const { recordId } = req.params;

  try {
    const [rows] = await pool.query(
      `SELECT
        id,
        pet_id,
        products,
        reactions,
        severity,
        occurred_at,
        notes,
        created_at,
        updated_at
      FROM allergy_records
      WHERE id = ? AND user_id = ?`,
      [recordId, userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'アレルギー記録が見つかりません',
      });
    }

    const record = {
      ...rows[0],
      products: rows[0].products ? JSON.parse(rows[0].products) : [],
      reactions: rows[0].reactions ? JSON.parse(rows[0].reactions) : [],
    };

    return res.json({
      success: true,
      message: 'アレルギー記録を取得しました',
      data: record,
    });
  } catch (error) {
    console.error('❌ Error getting allergy record:', error);
    return res.status(500).json({
      success: false,
      message: 'アレルギー記録の取得に失敗しました',
      error: error.message,
    });
  }
};

/**
 * 알레르기 기록 생성
 * POST /allergy/pets/:petId/records
 */
export const createAllergyRecord = async (req, res) => {
  const userId = req.user.uid;
  const { petId } = req.params;
  const { products, reactions, severity, occurredAt, notes } = req.body;

  try {
    // allergy_records 테이블 자동 생성
    await pool.query(`
      CREATE TABLE IF NOT EXISTS allergy_records (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        pet_id INT NOT NULL,
        products JSON,
        reactions JSON,
        severity VARCHAR(20) NOT NULL,
        occurred_at TIMESTAMP NOT NULL,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_user_pet (user_id, pet_id),
        INDEX idx_occurred_at (occurred_at)
      )
    `);

    // 펫 소유권 확인
    const [petRows] = await pool.query(
      'SELECT id FROM pets WHERE id = ? AND user_id = ?',
      [petId, userId]
    );

    if (petRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'ペットが見つかりません',
      });
    }

    // 알레르기 기록 생성
    const [result] = await pool.query(
      `INSERT INTO allergy_records (
        user_id,
        pet_id,
        products,
        reactions,
        severity,
        occurred_at,
        notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        userId,
        petId,
        JSON.stringify(products || []),
        JSON.stringify(reactions || []),
        severity,
        occurredAt,
        notes || null,
      ]
    );

    // 생성된 기록 조회
    const [newRecord] = await pool.query(
      `SELECT
        id,
        pet_id,
        products,
        reactions,
        severity,
        occurred_at,
        notes,
        created_at,
        updated_at
      FROM allergy_records
      WHERE id = ?`,
      [result.insertId]
    );

    const record = {
      ...newRecord[0],
      products: newRecord[0].products ? JSON.parse(newRecord[0].products) : [],
      reactions: newRecord[0].reactions
        ? JSON.parse(newRecord[0].reactions)
        : [],
    };

    return res.status(201).json({
      success: true,
      message: 'アレルギー記録を作成しました',
      data: record,
    });
  } catch (error) {
    console.error('❌ Error creating allergy record:', error);
    return res.status(500).json({
      success: false,
      message: 'アレルギー記録の作成に失敗しました',
      error: error.message,
    });
  }
};

/**
 * 알레르기 기록 업데이트
 * PUT /allergy/records/:recordId
 */
export const updateAllergyRecord = async (req, res) => {
  const userId = req.user.uid;
  const { recordId } = req.params;
  const { products, reactions, severity, occurredAt, notes } = req.body;

  try {
    // 기존 기록 확인
    const [existing] = await pool.query(
      'SELECT id FROM allergy_records WHERE id = ? AND user_id = ?',
      [recordId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'アレルギー記録が見つかりません',
      });
    }

    // 업데이트 쿼리 구성
    const updates = [];
    const values = [];

    if (products !== undefined) {
      updates.push('products = ?');
      values.push(JSON.stringify(products));
    }
    if (reactions !== undefined) {
      updates.push('reactions = ?');
      values.push(JSON.stringify(reactions));
    }
    if (severity !== undefined) {
      updates.push('severity = ?');
      values.push(severity);
    }
    if (occurredAt !== undefined) {
      updates.push('occurred_at = ?');
      values.push(occurredAt);
    }
    if (notes !== undefined) {
      updates.push('notes = ?');
      values.push(notes);
    }

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        message: '更新する項目がありません',
      });
    }

    updates.push('updated_at = NOW()');
    values.push(recordId, userId);

    await pool.query(
      `UPDATE allergy_records SET ${updates.join(', ')} WHERE id = ? AND user_id = ?`,
      values
    );

    // 업데이트된 기록 조회
    const [updatedRecord] = await pool.query(
      `SELECT
        id,
        pet_id,
        products,
        reactions,
        severity,
        occurred_at,
        notes,
        created_at,
        updated_at
      FROM allergy_records
      WHERE id = ?`,
      [recordId]
    );

    const record = {
      ...updatedRecord[0],
      products: updatedRecord[0].products
        ? JSON.parse(updatedRecord[0].products)
        : [],
      reactions: updatedRecord[0].reactions
        ? JSON.parse(updatedRecord[0].reactions)
        : [],
    };

    return res.json({
      success: true,
      message: 'アレルギー記録を更新しました',
      data: record,
    });
  } catch (error) {
    console.error('❌ Error updating allergy record:', error);
    return res.status(500).json({
      success: false,
      message: 'アレルギー記録の更新に失敗しました',
      error: error.message,
    });
  }
};

/**
 * 알레르기 기록 삭제
 * DELETE /allergy/records/:recordId
 */
export const deleteAllergyRecord = async (req, res) => {
  const userId = req.user.uid;
  const { recordId } = req.params;

  try {
    // 기존 기록 확인
    const [existing] = await pool.query(
      'SELECT id FROM allergy_records WHERE id = ? AND user_id = ?',
      [recordId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'アレルギー記録が見つかりません',
      });
    }

    // 기록 삭제
    await pool.query('DELETE FROM allergy_records WHERE id = ? AND user_id = ?', [
      recordId,
      userId,
    ]);

    return res.json({
      success: true,
      message: 'アレルギー記録を削除しました',
    });
  } catch (error) {
    console.error('❌ Error deleting allergy record:', error);
    return res.status(500).json({
      success: false,
      message: 'アレルギー記録の削除に失敗しました',
      error: error.message,
    });
  }
};

/**
 * 펫의 알레르기 통계 조회
 * GET /allergy/pets/:petId/statistics
 */
export const getAllergyStatistics = async (req, res) => {
  const userId = req.user.uid;
  const { petId } = req.params;

  try {
    // 총 기록 수
    const [totalRows] = await pool.query(
      'SELECT COUNT(*) as total FROM allergy_records WHERE user_id = ? AND pet_id = ?',
      [userId, petId]
    );

    // 심각도별 통계
    const [severityRows] = await pool.query(
      `SELECT
        severity,
        COUNT(*) as count
      FROM allergy_records
      WHERE user_id = ? AND pet_id = ?
      GROUP BY severity`,
      [userId, petId]
    );

    // 최근 알레르기 발생일
    const [recentRows] = await pool.query(
      `SELECT
        MAX(occurred_at) as last_occurrence
      FROM allergy_records
      WHERE user_id = ? AND pet_id = ?`,
      [userId, petId]
    );

    // 가장 빈번한 반응들
    const [recordRows] = await pool.query(
      `SELECT reactions
      FROM allergy_records
      WHERE user_id = ? AND pet_id = ? AND reactions IS NOT NULL`,
      [userId, petId]
    );

    const reactionCounts = {};
    recordRows.forEach((row) => {
      const reactions = JSON.parse(row.reactions || '[]');
      reactions.forEach((reaction) => {
        reactionCounts[reaction] = (reactionCounts[reaction] || 0) + 1;
      });
    });

    const topReactions = Object.entries(reactionCounts)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 5)
      .map(([reaction, count]) => ({ reaction, count }));

    return res.json({
      success: true,
      message: 'アレルギー統計を取得しました',
      data: {
        total: totalRows[0].total,
        bySeverity: severityRows.reduce((acc, row) => {
          acc[row.severity] = row.count;
          return acc;
        }, {}),
        lastOccurrence: recentRows[0].last_occurrence,
        topReactions,
      },
    });
  } catch (error) {
    console.error('❌ Error getting allergy statistics:', error);
    return res.status(500).json({
      success: false,
      message: 'アレルギー統計の取得に失敗しました',
      error: error.message,
    });
  }
};

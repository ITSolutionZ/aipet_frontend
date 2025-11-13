import pool from '../config/database.js';
import { v4 as uuidv4 } from 'uuid';

/**
 * Firebase ID Token 검증 (프론트엔드 호환)
 */
export const verifyToken = async (req, res) => {
  try {
    // authenticateFirebase 미들웨어를 거쳐서 req.user에 이미 정보가 있음
    res.json({
      success: true,
      message: 'Token is valid',
      user: {
        uid: req.user.uid,
        email: req.user.email,
        name: req.user.name,
        picture: req.user.picture,
        provider: req.user.provider,
      },
    });
  } catch (error) {
    console.error('❌ [Auth] 토큰 검증 에러:', error);
    res.status(500).json({
      success: false,
      error: '토큰 검증 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 현재 로그인한 사용자 정보 조회
 */
export const getCurrentUser = async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM users WHERE id = ?',
      [req.user.uid]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: '사용자를 찾을 수 없습니다.',
      });
    }

    const user = rows[0];
    delete user.is_active; // 민감한 정보 제거

    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error('❌ [Auth] 사용자 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '사용자 정보 조회 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 사용자 생성 또는 업데이트 (프론트엔드 호환)
 */
export const syncUser = async (req, res) => {
  try {
    const { uid, email, displayName, photoURL, provider } = req.body;

    // Firebase에서 검증된 uid 사용
    const userId = uid || req.user.uid;

    // 사용자가 이미 존재하는지 확인
    const [existingUser] = await pool.query(
      'SELECT * FROM users WHERE id = ?',
      [userId]
    );

    if (existingUser.length > 0) {
      // 기존 사용자 업데이트
      await pool.query(
        `UPDATE users
         SET email = ?, display_name = ?, photo_url = ?, provider = ?, last_login_at = NOW(), updated_at = NOW()
         WHERE id = ?`,
        [
          email || req.user.email,
          displayName || req.user.name,
          photoURL || req.user.picture,
          provider || req.user.provider,
          userId,
        ]
      );

      console.log(`✅ [Auth] 사용자 업데이트: ${email} (${userId})`);

      res.json({
        success: true,
        message: '사용자 정보가 업데이트되었습니다.',
        data: {
          id: userId,
          email: email || req.user.email,
          display_name: displayName || req.user.name,
          photo_url: photoURL || req.user.picture,
          provider: provider || req.user.provider,
        },
      });
    } else {
      // 새 사용자 생성
      await pool.query(
        `INSERT INTO users (id, email, display_name, photo_url, provider, last_login_at)
         VALUES (?, ?, ?, ?, ?, NOW())`,
        [
          userId,
          email || req.user.email,
          displayName || req.user.name,
          photoURL || req.user.picture,
          provider || req.user.provider,
        ]
      );

      console.log(`✅ [Auth] 새 사용자 생성: ${email} (${userId})`);

      res.status(201).json({
        success: true,
        message: '사용자가 생성되었습니다.',
        data: {
          id: userId,
          email: email || req.user.email,
          display_name: displayName || req.user.name,
          photo_url: photoURL || req.user.picture,
          provider: provider || req.user.provider,
        },
      });
    }
  } catch (error) {
    console.error('❌ [Auth] 사용자 동기화 에러:', error);
    res.status(500).json({
      success: false,
      error: '사용자 동기화 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 로그아웃
 */
export const logout = async (req, res) => {
  try {
    // 클라이언트에서 토큰 삭제를 처리하므로, 서버에서는 로그만 남김
    console.log(`✅ [Auth] 사용자 로그아웃: ${req.user.email} (${req.user.uid})`);

    res.json({
      success: true,
      message: '로그아웃 되었습니다.',
    });
  } catch (error) {
    console.error('❌ [Auth] 로그아웃 에러:', error);
    res.status(500).json({
      success: false,
      error: '로그아웃 중 오류 발생',
      message: error.message,
    });
  }
};

import pool from '../config/database.js';

/**
 * 설정 컨트롤러
 *
 * 사용자 프로필, 앱 설정, 위치 정보를 관리합니다.
 */

// ============================================================================
// User Profile
// ============================================================================

/**
 * 사용자 프로필 조회
 * GET /settings/profile
 */
export const getUserProfile = async (req, res) => {
  const userId = req.user.uid;

  try {
    const [rows] = await pool.query(
      `SELECT
        user_id,
        display_name,
        phone_number,
        profile_image_url,
        bio,
        created_at,
        updated_at
      FROM users
      WHERE user_id = ?`,
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'ユーザープロフィールが見つかりません',
      });
    }

    return res.json({
      success: true,
      message: 'ユーザープロフィールを取得しました',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ Error getting user profile:', error);
    return res.status(500).json({
      success: false,
      message: 'ユーザープロフィールの取得に失敗しました',
      error: error.message,
    });
  }
};

/**
 * 사용자 프로필 업데이트
 * PUT /settings/profile
 */
export const updateUserProfile = async (req, res) => {
  const userId = req.user.uid;
  const { displayName, phoneNumber, profileImageUrl, bio } = req.body;

  try {
    // 사용자 존재 확인
    const [existingUser] = await pool.query(
      'SELECT user_id FROM users WHERE user_id = ?',
      [userId]
    );

    if (existingUser.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'ユーザーが見つかりません',
      });
    }

    // 프로필 업데이트
    const updates = [];
    const values = [];

    if (displayName !== undefined) {
      updates.push('display_name = ?');
      values.push(displayName);
    }
    if (phoneNumber !== undefined) {
      updates.push('phone_number = ?');
      values.push(phoneNumber);
    }
    if (profileImageUrl !== undefined) {
      updates.push('profile_image_url = ?');
      values.push(profileImageUrl);
    }
    if (bio !== undefined) {
      updates.push('bio = ?');
      values.push(bio);
    }

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        message: '更新する項目がありません',
      });
    }

    updates.push('updated_at = NOW()');
    values.push(userId);

    await pool.query(
      `UPDATE users SET ${updates.join(', ')} WHERE user_id = ?`,
      values
    );

    // 업데이트된 프로필 조회
    const [updatedProfile] = await pool.query(
      `SELECT
        user_id,
        display_name,
        phone_number,
        profile_image_url,
        bio,
        created_at,
        updated_at
      FROM users
      WHERE user_id = ?`,
      [userId]
    );

    return res.json({
      success: true,
      message: 'ユーザープロフィールを更新しました',
      data: updatedProfile[0],
    });
  } catch (error) {
    console.error('❌ Error updating user profile:', error);
    return res.status(500).json({
      success: false,
      message: 'ユーザープロフィールの更新に失敗しました',
      error: error.message,
    });
  }
};

// ============================================================================
// App Settings
// ============================================================================

/**
 * 앱 설정 조회
 * GET /settings/app
 */
export const getAppSettings = async (req, res) => {
  const userId = req.user.uid;

  try {
    // settings 테이블 자동 생성
    await pool.query(`
      CREATE TABLE IF NOT EXISTS settings (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL UNIQUE,
        language VARCHAR(10) DEFAULT 'ja',
        theme VARCHAR(20) DEFAULT 'system',
        notifications_enabled BOOLEAN DEFAULT true,
        auto_backup BOOLEAN DEFAULT false,
        biometric_login BOOLEAN DEFAULT false,
        sync_frequency VARCHAR(20) DEFAULT 'hourly',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_user_id (user_id)
      )
    `);

    const [rows] = await pool.query(
      `SELECT
        language,
        theme,
        notifications_enabled,
        auto_backup,
        biometric_login,
        sync_frequency,
        created_at,
        updated_at
      FROM settings
      WHERE user_id = ?`,
      [userId]
    );

    if (rows.length === 0) {
      // 기본 설정 생성
      await pool.query(
        `INSERT INTO settings (user_id) VALUES (?)`,
        [userId]
      );

      const [newRows] = await pool.query(
        `SELECT
          language,
          theme,
          notifications_enabled,
          auto_backup,
          biometric_login,
          sync_frequency,
          created_at,
          updated_at
        FROM settings
        WHERE user_id = ?`,
        [userId]
      );

      return res.json({
        success: true,
        message: 'アプリ設定を作成しました',
        data: newRows[0],
      });
    }

    return res.json({
      success: true,
      message: 'アプリ設定を取得しました',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ Error getting app settings:', error);
    return res.status(500).json({
      success: false,
      message: 'アプリ設定の取得に失敗しました',
      error: error.message,
    });
  }
};

/**
 * 앱 설정 저장
 * PUT /settings/app
 */
export const saveAppSettings = async (req, res) => {
  const userId = req.user.uid;
  const {
    language,
    theme,
    notificationsEnabled,
    autoBackup,
    biometricLogin,
    syncFrequency,
  } = req.body;

  try {
    // settings 테이블 자동 생성
    await pool.query(`
      CREATE TABLE IF NOT EXISTS settings (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL UNIQUE,
        language VARCHAR(10) DEFAULT 'ja',
        theme VARCHAR(20) DEFAULT 'system',
        notifications_enabled BOOLEAN DEFAULT true,
        auto_backup BOOLEAN DEFAULT false,
        biometric_login BOOLEAN DEFAULT false,
        sync_frequency VARCHAR(20) DEFAULT 'hourly',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_user_id (user_id)
      )
    `);

    // 기존 설정 확인
    const [existing] = await pool.query(
      'SELECT id FROM settings WHERE user_id = ?',
      [userId]
    );

    if (existing.length === 0) {
      // 새 설정 생성
      await pool.query(
        `INSERT INTO settings (
          user_id,
          language,
          theme,
          notifications_enabled,
          auto_backup,
          biometric_login,
          sync_frequency
        ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          userId,
          language || 'ja',
          theme || 'system',
          notificationsEnabled !== undefined ? notificationsEnabled : true,
          autoBackup !== undefined ? autoBackup : false,
          biometricLogin !== undefined ? biometricLogin : false,
          syncFrequency || 'hourly',
        ]
      );
    } else {
      // 설정 업데이트
      const updates = [];
      const values = [];

      if (language !== undefined) {
        updates.push('language = ?');
        values.push(language);
      }
      if (theme !== undefined) {
        updates.push('theme = ?');
        values.push(theme);
      }
      if (notificationsEnabled !== undefined) {
        updates.push('notifications_enabled = ?');
        values.push(notificationsEnabled);
      }
      if (autoBackup !== undefined) {
        updates.push('auto_backup = ?');
        values.push(autoBackup);
      }
      if (biometricLogin !== undefined) {
        updates.push('biometric_login = ?');
        values.push(biometricLogin);
      }
      if (syncFrequency !== undefined) {
        updates.push('sync_frequency = ?');
        values.push(syncFrequency);
      }

      if (updates.length > 0) {
        updates.push('updated_at = NOW()');
        values.push(userId);

        await pool.query(
          `UPDATE settings SET ${updates.join(', ')} WHERE user_id = ?`,
          values
        );
      }
    }

    // 업데이트된 설정 조회
    const [updatedSettings] = await pool.query(
      `SELECT
        language,
        theme,
        notifications_enabled,
        auto_backup,
        biometric_login,
        sync_frequency,
        created_at,
        updated_at
      FROM settings
      WHERE user_id = ?`,
      [userId]
    );

    return res.json({
      success: true,
      message: 'アプリ設定を保存しました',
      data: updatedSettings[0],
    });
  } catch (error) {
    console.error('❌ Error saving app settings:', error);
    return res.status(500).json({
      success: false,
      message: 'アプリ設定の保存に失敗しました',
      error: error.message,
    });
  }
};

// ============================================================================
// User Location
// ============================================================================

/**
 * 사용자 위치 정보 조회
 * GET /settings/location
 */
export const getUserLocation = async (req, res) => {
  const userId = req.user.uid;

  try {
    // user_locations 테이블 자동 생성
    await pool.query(`
      CREATE TABLE IF NOT EXISTS user_locations (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL UNIQUE,
        postal_code VARCHAR(20),
        address TEXT,
        detail_address TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_user_id (user_id)
      )
    `);

    const [rows] = await pool.query(
      `SELECT
        postal_code,
        address,
        detail_address,
        created_at,
        updated_at
      FROM user_locations
      WHERE user_id = ?`,
      [userId]
    );

    if (rows.length === 0) {
      return res.json({
        success: true,
        message: '位置情報が設定されていません',
        data: null,
      });
    }

    return res.json({
      success: true,
      message: '位置情報を取得しました',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ Error getting user location:', error);
    return res.status(500).json({
      success: false,
      message: '位置情報の取得に失敗しました',
      error: error.message,
    });
  }
};

/**
 * 사용자 위치 정보 저장
 * PUT /settings/location
 */
export const saveUserLocation = async (req, res) => {
  const userId = req.user.uid;
  const { postalCode, address, detailAddress } = req.body;

  if (!postalCode || !address) {
    return res.status(400).json({
      success: false,
      message: '郵便番号と住所は必須です',
    });
  }

  try {
    // user_locations 테이블 자동 생성
    await pool.query(`
      CREATE TABLE IF NOT EXISTS user_locations (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL UNIQUE,
        postal_code VARCHAR(20),
        address TEXT,
        detail_address TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_user_id (user_id)
      )
    `);

    // 기존 위치 정보 확인
    const [existing] = await pool.query(
      'SELECT id FROM user_locations WHERE user_id = ?',
      [userId]
    );

    if (existing.length === 0) {
      // 새 위치 정보 생성
      await pool.query(
        `INSERT INTO user_locations (
          user_id,
          postal_code,
          address,
          detail_address
        ) VALUES (?, ?, ?, ?)`,
        [userId, postalCode, address, detailAddress || null]
      );
    } else {
      // 위치 정보 업데이트
      await pool.query(
        `UPDATE user_locations
        SET postal_code = ?, address = ?, detail_address = ?, updated_at = NOW()
        WHERE user_id = ?`,
        [postalCode, address, detailAddress || null, userId]
      );
    }

    // 업데이트된 위치 정보 조회
    const [updatedLocation] = await pool.query(
      `SELECT
        postal_code,
        address,
        detail_address,
        created_at,
        updated_at
      FROM user_locations
      WHERE user_id = ?`,
      [userId]
    );

    return res.json({
      success: true,
      message: '位置情報を保存しました',
      data: updatedLocation[0],
    });
  } catch (error) {
    console.error('❌ Error saving user location:', error);
    return res.status(500).json({
      success: false,
      message: '位置情報の保存に失敗しました',
      error: error.message,
    });
  }
};

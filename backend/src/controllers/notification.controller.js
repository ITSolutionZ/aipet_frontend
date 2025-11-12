import pool from '../config/database.js';
import admin from '../config/firebase.js';
import { v4 as uuidv4 } from 'uuid';

/**
 * FCM 푸시 알림 전송
 */
const sendFCMNotification = async (fcmToken, title, body, data = {}) => {
  try {
    const message = {
      token: fcmToken,
      notification: {
        title,
        body,
      },
      data: {
        ...data,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'aipet_notifications',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    console.log(`✅ [FCM] 알림 전송 성공:`, response);
    return { success: true, messageId: response };
  } catch (error) {
    console.error('❌ [FCM] 알림 전송 실패:', error);
    return { success: false, error: error.message };
  }
};

/**
 * 특정 사용자의 모든 알림 조회
 */
export const getNotifications = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { isRead, notificationType, limit = 50 } = req.query;

    let query = 'SELECT * FROM notifications WHERE user_id = ?';
    const params = [userId];

    if (isRead !== undefined) {
      query += ' AND is_read = ?';
      params.push(isRead === 'true');
    }

    if (notificationType) {
      query += ' AND notification_type = ?';
      params.push(notificationType);
    }

    query += ' ORDER BY created_at DESC LIMIT ?';
    params.push(parseInt(limit));

    const [rows] = await pool.query(query, params);

    res.json({
      success: true,
      data: rows,
      count: rows.length,
    });
  } catch (error) {
    console.error('❌ [Notification] 알림 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '알림 조회 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 알림 생성 (스케줄링)
 */
export const createNotification = async (req, res) => {
  try {
    const userId = req.user.uid;
    const {
      petId,
      title,
      body,
      notificationType,
      scheduledAt,
      sendImmediately = false,
      fcmToken,
    } = req.body;

    const notificationId = `notif_${Date.now()}_${uuidv4().split('-')[0]}`;

    // 알림 데이터베이스에 저장
    await pool.query(
      `INSERT INTO notifications (
        id, user_id, pet_id, title, body, notification_type, scheduled_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        notificationId,
        userId,
        petId || null,
        title,
        body,
        notificationType || 'general',
        scheduledAt || new Date(),
      ]
    );

    // 즉시 전송 옵션
    if (sendImmediately && fcmToken) {
      const fcmResult = await sendFCMNotification(fcmToken, title, body, {
        notificationId,
        notificationType: notificationType || 'general',
        petId: petId || '',
      });

      if (fcmResult.success) {
        // 전송 성공 시 DB 업데이트
        await pool.query(
          'UPDATE notifications SET is_sent = true, sent_at = NOW() WHERE id = ?',
          [notificationId]
        );
      }
    }

    const [rows] = await pool.query(
      'SELECT * FROM notifications WHERE id = ?',
      [notificationId]
    );

    console.log(`✅ [Notification] 알림 생성: ${title} (${notificationId})`);

    res.status(201).json({
      success: true,
      message: '알림이 생성되었습니다.',
      data: rows[0],
    });
  } catch (error) {
    console.error('❌ [Notification] 알림 생성 에러:', error);
    res.status(500).json({
      success: false,
      error: '알림 생성 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 알림 읽음 처리
 */
export const markAsRead = async (req, res) => {
  try {
    const { notificationId } = req.params;
    const userId = req.user.uid;

    // 소유권 확인
    const [notification] = await pool.query(
      'SELECT * FROM notifications WHERE id = ? AND user_id = ?',
      [notificationId, userId]
    );

    if (notification.length === 0) {
      return res.status(404).json({
        success: false,
        error: '알림을 찾을 수 없습니다.',
      });
    }

    // 읽음 처리
    await pool.query(
      'UPDATE notifications SET is_read = true WHERE id = ? AND user_id = ?',
      [notificationId, userId]
    );

    console.log(`✅ [Notification] 알림 읽음 처리: ${notificationId}`);

    res.json({
      success: true,
      message: '알림이 읽음 처리되었습니다.',
    });
  } catch (error) {
    console.error('❌ [Notification] 알림 읽음 처리 에러:', error);
    res.status(500).json({
      success: false,
      error: '알림 읽음 처리 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 모든 알림 읽음 처리
 */
export const markAllAsRead = async (req, res) => {
  try {
    const userId = req.user.uid;

    await pool.query(
      'UPDATE notifications SET is_read = true WHERE user_id = ? AND is_read = false',
      [userId]
    );

    console.log(`✅ [Notification] 모든 알림 읽음 처리: ${userId}`);

    res.json({
      success: true,
      message: '모든 알림이 읽음 처리되었습니다.',
    });
  } catch (error) {
    console.error('❌ [Notification] 모든 알림 읽음 처리 에러:', error);
    res.status(500).json({
      success: false,
      error: '알림 읽음 처리 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 알림 삭제
 */
export const deleteNotification = async (req, res) => {
  try {
    const { notificationId } = req.params;
    const userId = req.user.uid;

    // 소유권 확인
    const [notification] = await pool.query(
      'SELECT * FROM notifications WHERE id = ? AND user_id = ?',
      [notificationId, userId]
    );

    if (notification.length === 0) {
      return res.status(404).json({
        success: false,
        error: '알림을 찾을 수 없습니다.',
      });
    }

    await pool.query(
      'DELETE FROM notifications WHERE id = ? AND user_id = ?',
      [notificationId, userId]
    );

    console.log(`✅ [Notification] 알림 삭제: ${notificationId}`);

    res.json({
      success: true,
      message: '알림이 삭제되었습니다.',
    });
  } catch (error) {
    console.error('❌ [Notification] 알림 삭제 에러:', error);
    res.status(500).json({
      success: false,
      error: '알림 삭제 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 읽지 않은 알림 개수 조회
 */
export const getUnreadCount = async (req, res) => {
  try {
    const userId = req.user.uid;

    const [result] = await pool.query(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = false',
      [userId]
    );

    res.json({
      success: true,
      data: {
        unreadCount: result[0].count,
      },
    });
  } catch (error) {
    console.error('❌ [Notification] 읽지 않은 알림 개수 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '읽지 않은 알림 개수 조회 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * FCM 푸시 알림 직접 전송 (테스트용)
 */
export const sendPushNotification = async (req, res) => {
  try {
    const { fcmToken, title, body, data } = req.body;

    if (!fcmToken) {
      return res.status(400).json({
        success: false,
        error: 'FCM 토큰이 필요합니다.',
      });
    }

    const result = await sendFCMNotification(fcmToken, title, body, data);

    if (result.success) {
      res.json({
        success: true,
        message: '푸시 알림이 전송되었습니다.',
        messageId: result.messageId,
      });
    } else {
      res.status(500).json({
        success: false,
        error: '푸시 알림 전송 실패',
        message: result.error,
      });
    }
  } catch (error) {
    console.error('❌ [Notification] 푸시 알림 전송 에러:', error);
    res.status(500).json({
      success: false,
      error: '푸시 알림 전송 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 예약된 알림 자동 전송 (크론잡용)
 */
export const sendScheduledNotifications = async () => {
  try {
    // 전송되지 않은 예약 알림 조회
    const [notifications] = await pool.query(
      `SELECT n.*, u.fcm_token
       FROM notifications n
       LEFT JOIN user_fcm_tokens u ON n.user_id = u.user_id
       WHERE n.is_sent = false
       AND n.scheduled_at <= NOW()
       LIMIT 100`
    );

    console.log(`📬 [Notification] ${notifications.length}개의 예약 알림 처리 중...`);

    for (const notification of notifications) {
      if (notification.fcm_token) {
        const result = await sendFCMNotification(
          notification.fcm_token,
          notification.title,
          notification.body,
          {
            notificationId: notification.id,
            notificationType: notification.notification_type,
            petId: notification.pet_id || '',
          }
        );

        if (result.success) {
          await pool.query(
            'UPDATE notifications SET is_sent = true, sent_at = NOW() WHERE id = ?',
            [notification.id]
          );
        }
      }
    }

    console.log(`✅ [Notification] 예약 알림 전송 완료`);
    return { success: true, sent: notifications.length };
  } catch (error) {
    console.error('❌ [Notification] 예약 알림 전송 에러:', error);
    return { success: false, error: error.message };
  }
};

/**
 * FCM 토큰 저장/업데이트
 */
export const saveFCMToken = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { fcmToken, deviceType } = req.body;

    if (!fcmToken) {
      return res.status(400).json({
        success: false,
        error: 'FCM 토큰이 필요합니다.',
      });
    }

    // user_fcm_tokens 테이블 생성 (없는 경우)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS user_fcm_tokens (
        id VARCHAR(128) PRIMARY KEY,
        user_id VARCHAR(128) NOT NULL,
        fcm_token TEXT NOT NULL,
        device_type VARCHAR(50) COMMENT 'android, ios',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_user_id (user_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `);

    // 기존 토큰 확인
    const [existing] = await pool.query(
      'SELECT * FROM user_fcm_tokens WHERE user_id = ? AND device_type = ?',
      [userId, deviceType || 'android']
    );

    if (existing.length > 0) {
      // 토큰 업데이트
      await pool.query(
        'UPDATE user_fcm_tokens SET fcm_token = ?, updated_at = NOW() WHERE user_id = ? AND device_type = ?',
        [fcmToken, userId, deviceType || 'android']
      );
      console.log(`✅ [FCM] 토큰 업데이트: ${userId}`);
    } else {
      // 새 토큰 저장
      const tokenId = `fcm_${Date.now()}_${uuidv4().split('-')[0]}`;
      await pool.query(
        'INSERT INTO user_fcm_tokens (id, user_id, fcm_token, device_type) VALUES (?, ?, ?, ?)',
        [tokenId, userId, fcmToken, deviceType || 'android']
      );
      console.log(`✅ [FCM] 새 토큰 저장: ${userId}`);
    }

    res.json({
      success: true,
      message: 'FCM 토큰이 저장되었습니다.',
    });
  } catch (error) {
    console.error('❌ [Notification] FCM 토큰 저장 에러:', error);
    res.status(500).json({
      success: false,
      error: 'FCM 토큰 저장 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 알림 설정 조회
 */
export const getNotificationSettings = async (req, res) => {
  try {
    const userId = req.user.uid;

    // notification_settings 테이블 확인 및 조회
    const [settings] = await pool.query(
      'SELECT * FROM notification_settings WHERE user_id = ?',
      [userId]
    ).catch(() => [[]]);

    if (settings.length > 0) {
      const setting = settings[0];
      res.json({
        success: true,
        data: {
          pushEnabled: setting.push_enabled || true,
          emailEnabled: setting.email_enabled || false,
          notificationTypes: setting.notification_types
            ? (typeof setting.notification_types === 'string'
                ? JSON.parse(setting.notification_types)
                : setting.notification_types)
            : {
                vaccination: true,
                feeding: true,
                walk: true,
                medical: true,
                general: true,
              },
        },
      });
    } else {
      // 설정이 없으면 기본값 반환
      res.json({
        success: true,
        data: {
          pushEnabled: true,
          emailEnabled: false,
          notificationTypes: {
            vaccination: true,
            feeding: true,
            walk: true,
            medical: true,
            general: true,
          },
        },
      });
    }
  } catch (error) {
    console.error('❌ [Notification] 설정 조회 에러:', error);
    // 테이블이 없어도 기본값 반환
    res.json({
      success: true,
      data: {
        pushEnabled: true,
        emailEnabled: false,
        notificationTypes: {
          vaccination: true,
          feeding: true,
          walk: true,
          medical: true,
          general: true,
        },
      },
    });
  }
};

/**
 * 알림 설정 업데이트
 */
export const updateNotificationSettings = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { pushEnabled, emailEnabled, notificationTypes } = req.body;

    // 테이블 존재 확인 및 생성
    await pool.query(`
      CREATE TABLE IF NOT EXISTS notification_settings (
        user_id VARCHAR(255) PRIMARY KEY,
        push_enabled BOOLEAN DEFAULT true,
        email_enabled BOOLEAN DEFAULT false,
        notification_types JSON,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `).catch(() => {});

    // 기존 설정 확인
    const [existing] = await pool.query(
      'SELECT * FROM notification_settings WHERE user_id = ?',
      [userId]
    ).catch(() => [[]]);

    const notificationTypesJson = notificationTypes
      ? JSON.stringify(notificationTypes)
      : null;

    if (existing.length > 0) {
      // 설정 업데이트
      const updates = [];
      const values = [];

      if (pushEnabled !== undefined) {
        updates.push('push_enabled = ?');
        values.push(pushEnabled);
      }
      if (emailEnabled !== undefined) {
        updates.push('email_enabled = ?');
        values.push(emailEnabled);
      }
      if (notificationTypesJson) {
        updates.push('notification_types = ?');
        values.push(notificationTypesJson);
      }

      if (updates.length > 0) {
        updates.push('updated_at = NOW()');
        values.push(userId);

        await pool.query(
          `UPDATE notification_settings SET ${updates.join(', ')} WHERE user_id = ?`,
          values
        );
      }

      console.log(`✅ [Notification] 설정 업데이트: ${userId}`);
    } else {
      // 새 설정 생성
      await pool.query(
        'INSERT INTO notification_settings (user_id, push_enabled, email_enabled, notification_types) VALUES (?, ?, ?, ?)',
        [
          userId,
          pushEnabled !== undefined ? pushEnabled : true,
          emailEnabled !== undefined ? emailEnabled : false,
          notificationTypesJson || JSON.stringify({
            vaccination: true,
            feeding: true,
            walk: true,
            medical: true,
            general: true,
          }),
        ]
      );

      console.log(`✅ [Notification] 새 설정 생성: ${userId}`);
    }

    res.json({
      success: true,
      message: '알림 설정이 업데이트되었습니다.',
    });
  } catch (error) {
    console.error('❌ [Notification] 설정 업데이트 에러:', error);
    res.status(500).json({
      success: false,
      error: '알림 설정 업데이트 중 오류 발생',
      message: error.message,
    });
  }
};

/**
 * 알림 통계 조회
 */
export const getNotificationStats = async (req, res) => {
  try {
    const userId = req.user.uid;

    // 총 알림 개수
    const [totalResult] = await pool.query(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ?',
      [userId]
    );

    // 읽지 않은 알림 개수
    const [unreadResult] = await pool.query(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = false',
      [userId]
    );

    // 읽은 알림 개수
    const [readResult] = await pool.query(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = true',
      [userId]
    );

    const totalCount = totalResult[0].count;
    const unreadCount = unreadResult[0].count;
    const readCount = readResult[0].count;

    res.json({
      success: true,
      data: {
        totalCount,
        unreadCount,
        readCount,
      },
    });
  } catch (error) {
    console.error('❌ [Notification] 통계 조회 에러:', error);
    res.status(500).json({
      success: false,
      error: '알림 통계 조회 중 오류 발생',
      message: error.message,
    });
  }
};

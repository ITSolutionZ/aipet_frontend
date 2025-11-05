import express from 'express';
import { body, param, query } from 'express-validator';
import {
  getNotifications,
  createNotification,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  getUnreadCount,
  sendPushNotification,
  saveFCMToken,
} from '../controllers/notification.controller.js';
import { authenticateFirebase } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';

const router = express.Router();

// 모든 알림 라우트는 인증 필요
router.use(authenticateFirebase);

/**
 * @route   GET /api/v1/notifications
 * @desc    알림 목록 조회
 * @access  Private
 */
router.get(
  '/',
  [
    query('isRead').optional().isBoolean(),
    query('notificationType').optional().isString(),
    query('limit').optional().isInt({ min: 1, max: 100 }),
  ],
  validate,
  getNotifications
);

/**
 * @route   POST /api/v1/notifications
 * @desc    알림 생성 (스케줄링)
 * @access  Private
 */
router.post(
  '/',
  [
    body('title').notEmpty().trim().withMessage('알림 제목은 필수입니다.'),
    body('body').notEmpty().trim().withMessage('알림 내용은 필수입니다.'),
    body('petId').optional().isString(),
    body('notificationType')
      .optional()
      .isIn(['vaccination', 'feeding', 'walk', 'medical', 'general'])
      .withMessage('유효한 알림 타입이 아닙니다.'),
    body('scheduledAt').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('sendImmediately').optional().isBoolean(),
    body('fcmToken').optional().isString(),
  ],
  validate,
  createNotification
);

/**
 * @route   GET /api/v1/notifications/unread-count
 * @desc    읽지 않은 알림 개수 조회
 * @access  Private
 */
router.get('/unread-count', getUnreadCount);

/**
 * @route   PUT /api/v1/notifications/mark-all-read
 * @desc    모든 알림 읽음 처리
 * @access  Private
 */
router.put('/mark-all-read', markAllAsRead);

/**
 * @route   PUT /api/v1/notifications/:notificationId/read
 * @desc    알림 읽음 처리
 * @access  Private
 */
router.put(
  '/:notificationId/read',
  [param('notificationId').notEmpty().withMessage('알림 ID가 필요합니다.')],
  validate,
  markAsRead
);

/**
 * @route   DELETE /api/v1/notifications/:notificationId
 * @desc    알림 삭제
 * @access  Private
 */
router.delete(
  '/:notificationId',
  [param('notificationId').notEmpty().withMessage('알림 ID가 필요합니다.')],
  validate,
  deleteNotification
);

/**
 * @route   POST /api/v1/notifications/push
 * @desc    FCM 푸시 알림 직접 전송 (테스트용)
 * @access  Private
 */
router.post(
  '/push',
  [
    body('fcmToken').notEmpty().withMessage('FCM 토큰이 필요합니다.'),
    body('title').notEmpty().trim().withMessage('알림 제목은 필수입니다.'),
    body('body').notEmpty().trim().withMessage('알림 내용은 필수입니다.'),
    body('data').optional().isObject(),
  ],
  validate,
  sendPushNotification
);

/**
 * @route   POST /api/v1/notifications/fcm-token
 * @desc    FCM 토큰 저장/업데이트
 * @access  Private
 */
router.post(
  '/fcm-token',
  [
    body('fcmToken').notEmpty().withMessage('FCM 토큰이 필요합니다.'),
    body('deviceType')
      .optional()
      .isIn(['android', 'ios'])
      .withMessage('디바이스 타입은 android 또는 ios여야 합니다.'),
  ],
  validate,
  saveFCMToken
);

export default router;

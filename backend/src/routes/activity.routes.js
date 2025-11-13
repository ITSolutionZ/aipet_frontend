import express from 'express';
import { body, param, query } from 'express-validator';
import {
  getWalks,
  createWalk,
  updateWalk,
  deleteWalk,
  getWalkStats,
  getFeedings,
  createFeeding,
  updateFeeding,
  deleteFeeding,
  getFeedingStats,
  getActivities,
  createActivity,
} from '../controllers/activity.controller.js';
import { authenticateFirebase } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';

const router = express.Router();

// 모든 활동 라우트는 인증 필요
router.use(authenticateFirebase);

// ===========================
// 산책 (Walks)
// ===========================

/**
 * @route   GET /api/v1/activity/pets/:petId/walks
 * @desc    특정 펫의 산책 기록 조회
 * @access  Private
 */
router.get(
  '/pets/:petId/walks',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    query('startDate').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    query('endDate').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    query('limit').optional().isInt({ min: 1, max: 100 }),
  ],
  validate,
  getWalks
);

/**
 * @route   POST /api/v1/activity/pets/:petId/walks
 * @desc    산책 기록 생성
 * @access  Private
 */
router.post(
  '/pets/:petId/walks',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    body('startTime')
      .notEmpty()
      .isISO8601()
      .withMessage('시작 시간은 필수이며 유효한 날짜 형식이어야 합니다.'),
    body('endTime').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('durationMinutes').optional().isInt({ min: 0 }),
    body('distanceMeters').optional().isInt({ min: 0 }),
    body('routeData').optional().isArray(),
    body('temperature').optional().isFloat(),
    body('weather').optional().isString().trim(),
    body('poopCount').optional().isInt({ min: 0 }),
    body('peeCount').optional().isInt({ min: 0 }),
    body('notes').optional().isString(),
  ],
  validate,
  createWalk
);

/**
 * @route   PUT /api/v1/activity/pets/:petId/walks/:walkId
 * @desc    산책 기록 업데이트
 * @access  Private
 */
router.put(
  '/pets/:petId/walks/:walkId',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    param('walkId').notEmpty().withMessage('산책 ID가 필요합니다.'),
    body('startTime').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('endTime').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('durationMinutes').optional().isInt({ min: 0 }),
    body('distanceMeters').optional().isInt({ min: 0 }),
    body('routeData').optional().isArray(),
    body('temperature').optional().isFloat(),
    body('weather').optional().isString().trim(),
    body('poopCount').optional().isInt({ min: 0 }),
    body('peeCount').optional().isInt({ min: 0 }),
    body('notes').optional().isString(),
  ],
  validate,
  updateWalk
);

/**
 * @route   DELETE /api/v1/activity/pets/:petId/walks/:walkId
 * @desc    산책 기록 삭제
 * @access  Private
 */
router.delete(
  '/pets/:petId/walks/:walkId',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    param('walkId').notEmpty().withMessage('산책 ID가 필요합니다.'),
  ],
  validate,
  deleteWalk
);

/**
 * @route   GET /api/v1/activity/pets/:petId/walks/stats
 * @desc    산책 통계 조회
 * @access  Private
 */
router.get(
  '/pets/:petId/walks/stats',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    query('period').optional().isInt({ min: 1 }),
  ],
  validate,
  getWalkStats
);

// ===========================
// 급식 (Feedings)
// ===========================

/**
 * @route   GET /api/v1/activity/pets/:petId/feedings
 * @desc    특정 펫의 급식 기록 조회
 * @access  Private
 */
router.get(
  '/pets/:petId/feedings',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    query('startDate').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    query('endDate').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    query('limit').optional().isInt({ min: 1, max: 100 }),
  ],
  validate,
  getFeedings
);

/**
 * @route   POST /api/v1/activity/pets/:petId/feedings
 * @desc    급식 기록 생성
 * @access  Private
 */
router.post(
  '/pets/:petId/feedings',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    body('feedingTime').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('foodType').optional().isString().trim(),
    body('foodBrand').optional().isString().trim(),
    body('amountGrams').optional().isFloat({ min: 0 }),
    body('mealType')
      .optional()
      .isIn(['breakfast', 'lunch', 'dinner', 'snack'])
      .withMessage('식사 타입은 breakfast, lunch, dinner, snack 중 하나여야 합니다.'),
    body('notes').optional().isString(),
  ],
  validate,
  createFeeding
);

/**
 * @route   PUT /api/v1/activity/pets/:petId/feedings/:feedingId
 * @desc    급식 기록 업데이트
 * @access  Private
 */
router.put(
  '/pets/:petId/feedings/:feedingId',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    param('feedingId').notEmpty().withMessage('급식 ID가 필요합니다.'),
    body('feedingTime').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('foodType').optional().isString().trim(),
    body('foodBrand').optional().isString().trim(),
    body('amountGrams').optional().isFloat({ min: 0 }),
    body('mealType')
      .optional()
      .isIn(['breakfast', 'lunch', 'dinner', 'snack'])
      .withMessage('식사 타입은 breakfast, lunch, dinner, snack 중 하나여야 합니다.'),
    body('notes').optional().isString(),
  ],
  validate,
  updateFeeding
);

/**
 * @route   DELETE /api/v1/activity/pets/:petId/feedings/:feedingId
 * @desc    급식 기록 삭제
 * @access  Private
 */
router.delete(
  '/pets/:petId/feedings/:feedingId',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    param('feedingId').notEmpty().withMessage('급식 ID가 필요합니다.'),
  ],
  validate,
  deleteFeeding
);

/**
 * @route   GET /api/v1/activity/pets/:petId/feedings/stats
 * @desc    급식 통계 조회
 * @access  Private
 */
router.get(
  '/pets/:petId/feedings/stats',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    query('period').optional().isInt({ min: 1 }),
  ],
  validate,
  getFeedingStats
);

// ===========================
// 기타 활동 (Activities)
// ===========================

/**
 * @route   GET /api/v1/activity/pets/:petId/activities
 * @desc    특정 펫의 기타 활동 기록 조회
 * @access  Private
 */
router.get(
  '/pets/:petId/activities',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    query('activityType').optional().isString().trim(),
    query('startDate').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    query('endDate').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    query('limit').optional().isInt({ min: 1, max: 100 }),
  ],
  validate,
  getActivities
);

/**
 * @route   POST /api/v1/activity/pets/:petId/activities
 * @desc    기타 활동 기록 생성
 * @access  Private
 */
router.post(
  '/pets/:petId/activities',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    body('activityType').notEmpty().isString().trim().withMessage('활동 타입은 필수입니다.'),
    body('startTime')
      .notEmpty()
      .isISO8601()
      .withMessage('시작 시간은 필수이며 유효한 날짜 형식이어야 합니다.'),
    body('endTime').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('durationMinutes').optional().isInt({ min: 0 }),
    body('notes').optional().isString(),
  ],
  validate,
  createActivity
);

export default router;

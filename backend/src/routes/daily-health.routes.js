import express from 'express';
import { body, param, query } from 'express-validator';
import {
  getDailyHealthRecords,
  getDailyHealthRecordById,
  createDailyHealthRecord,
  updateDailyHealthRecord,
  deleteDailyHealthRecord,
  getDailyHealthStats,
  getDailyHealthRecordByDate,
} from '../controllers/daily-health.controller.js';
import { authenticateFirebase } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';

const router = express.Router();

// 모든 일일 건강 기록 라우트는 인증 필요
router.use(authenticateFirebase);

/**
 * @route   GET /api/v1/daily-health/records
 * @desc    일일 건강 기록 목록 조회
 * @access  Private
 */
router.get(
  '/records',
  [
    query('petId').optional().isInt(),
    query('startDate').optional().isDate(),
    query('endDate').optional().isDate(),
    query('limit').optional().isInt({ min: 1, max: 100 }),
  ],
  validate,
  getDailyHealthRecords
);

/**
 * @route   GET /api/v1/daily-health/records/by-date
 * @desc    특정 날짜의 건강 기록 조회
 * @access  Private
 */
router.get(
  '/records/by-date',
  [
    query('petId').notEmpty().isInt().withMessage('petId가 필요합니다.'),
    query('recordDate').notEmpty().isDate().withMessage('유효한 날짜가 필요합니다.'),
  ],
  validate,
  getDailyHealthRecordByDate
);

/**
 * @route   GET /api/v1/daily-health/records/:recordId
 * @desc    특정 건강 기록 조회
 * @access  Private
 */
router.get(
  '/records/:recordId',
  [param('recordId').notEmpty().isInt().withMessage('유효한 기록 ID가 필요합니다.')],
  validate,
  getDailyHealthRecordById
);

/**
 * @route   POST /api/v1/daily-health/records
 * @desc    일일 건강 기록 생성
 * @access  Private
 */
router.post(
  '/records',
  [
    body('petId').notEmpty().isInt().withMessage('petId가 필요합니다.'),
    body('recordDate')
      .notEmpty()
      .isDate()
      .withMessage('유효한 날짜가 필요합니다.'),
    body('mealCount').optional().isInt({ min: 0 }),
    body('poopCount').optional().isInt({ min: 0 }),
    body('exerciseDuration').optional().isInt({ min: 0 }),
    body('sleepDuration').optional().isInt({ min: 0 }),
    body('mood')
      .optional()
      .isIn(['good', 'normal', 'bad'])
      .withMessage('유효한 기분 상태가 아닙니다.'),
    body('condition')
      .optional()
      .isIn(['excellent', 'good', 'normal', 'poor'])
      .withMessage('유효한 컨디션 상태가 아닙니다.'),
    body('symptoms').optional().isArray(),
    body('notes').optional().isString(),
  ],
  validate,
  createDailyHealthRecord
);

/**
 * @route   PUT /api/v1/daily-health/records/:recordId
 * @desc    일일 건강 기록 수정
 * @access  Private
 */
router.put(
  '/records/:recordId',
  [
    param('recordId').notEmpty().isInt().withMessage('유효한 기록 ID가 필요합니다.'),
    body('mealCount').optional().isInt({ min: 0 }),
    body('poopCount').optional().isInt({ min: 0 }),
    body('exerciseDuration').optional().isInt({ min: 0 }),
    body('sleepDuration').optional().isInt({ min: 0 }),
    body('mood')
      .optional()
      .isIn(['good', 'normal', 'bad'])
      .withMessage('유효한 기분 상태가 아닙니다.'),
    body('condition')
      .optional()
      .isIn(['excellent', 'good', 'normal', 'poor'])
      .withMessage('유효한 컨디션 상태가 아닙니다.'),
    body('symptoms').optional().isArray(),
    body('notes').optional().isString(),
  ],
  validate,
  updateDailyHealthRecord
);

/**
 * @route   DELETE /api/v1/daily-health/records/:recordId
 * @desc    일일 건강 기록 삭제
 * @access  Private
 */
router.delete(
  '/records/:recordId',
  [param('recordId').notEmpty().isInt().withMessage('유효한 기록 ID가 필요합니다.')],
  validate,
  deleteDailyHealthRecord
);

/**
 * @route   GET /api/v1/daily-health/stats
 * @desc    일일 건강 통계 조회
 * @access  Private
 */
router.get(
  '/stats',
  [
    query('petId').notEmpty().isInt().withMessage('petId가 필요합니다.'),
    query('startDate').optional().isDate(),
    query('endDate').optional().isDate(),
  ],
  validate,
  getDailyHealthStats
);

export default router;

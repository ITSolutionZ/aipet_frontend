import express from 'express';
import { body, param, query } from 'express-validator';
import {
  getBookings,
  getBookingById,
  createBooking,
  updateBooking,
  cancelBooking,
  updateBookingStatus,
  getUpcomingBookings,
  getBookingHistory,
} from '../controllers/booking.controller.js';
import { authenticateFirebase } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';

const router = express.Router();

// 모든 예약 라우트는 인증 필요
router.use(authenticateFirebase);

/**
 * @route   GET /api/v1/bookings
 * @desc    예약 목록 조회
 * @access  Private
 */
router.get(
  '/',
  [
    query('petId').optional().isInt(),
    query('status')
      .optional()
      .isIn(['pending', 'confirmed', 'cancelled', 'completed']),
    query('startDate').optional().isDate(),
    query('endDate').optional().isDate(),
    query('limit').optional().isInt({ min: 1, max: 100 }),
  ],
  validate,
  getBookings
);

/**
 * @route   GET /api/v1/bookings/upcoming
 * @desc    다가오는 예약 조회
 * @access  Private
 */
router.get(
  '/upcoming',
  [query('limit').optional().isInt({ min: 1, max: 100 })],
  validate,
  getUpcomingBookings
);

/**
 * @route   GET /api/v1/bookings/history
 * @desc    예약 이력 조회
 * @access  Private
 */
router.get(
  '/history',
  [query('limit').optional().isInt({ min: 1, max: 100 })],
  validate,
  getBookingHistory
);

/**
 * @route   GET /api/v1/bookings/:bookingId
 * @desc    예약 상세 조회
 * @access  Private
 */
router.get(
  '/:bookingId',
  [param('bookingId').notEmpty().isInt().withMessage('유효한 예약 ID가 필요합니다.')],
  validate,
  getBookingById
);

/**
 * @route   POST /api/v1/bookings
 * @desc    예약 생성
 * @access  Private
 */
router.post(
  '/',
  [
    body('petId').notEmpty().isInt().withMessage('petId가 필요합니다.'),
    body('facilityName').notEmpty().trim().withMessage('시설명이 필요합니다.'),
    body('facilityType').notEmpty().trim().withMessage('시설 유형이 필요합니다.'),
    body('bookingDate')
      .notEmpty()
      .isDate()
      .withMessage('유효한 예약 날짜가 필요합니다.'),
    body('bookingTime')
      .notEmpty()
      .matches(/^([01]\d|2[0-3]):([0-5]\d)(:([0-5]\d))?$/)
      .withMessage('유효한 예약 시간이 필요합니다 (HH:MM 형식).'),
    body('facilityId').optional().isString(),
    body('facilityAddress').optional().isString(),
    body('facilityPhone').optional().isString(),
    body('serviceType').optional().isString(),
    body('notes').optional().isString(),
  ],
  validate,
  createBooking
);

/**
 * @route   PUT /api/v1/bookings/:bookingId
 * @desc    예약 수정
 * @access  Private
 */
router.put(
  '/:bookingId',
  [
    param('bookingId').notEmpty().isInt().withMessage('유효한 예약 ID가 필요합니다.'),
    body('bookingDate').optional().isDate(),
    body('bookingTime')
      .optional()
      .matches(/^([01]\d|2[0-3]):([0-5]\d)(:([0-5]\d))?$/),
    body('serviceType').optional().isString(),
    body('notes').optional().isString(),
  ],
  validate,
  updateBooking
);

/**
 * @route   DELETE /api/v1/bookings/:bookingId
 * @desc    예약 취소
 * @access  Private
 */
router.delete(
  '/:bookingId',
  [param('bookingId').notEmpty().isInt().withMessage('유효한 예약 ID가 필요합니다.')],
  validate,
  cancelBooking
);

/**
 * @route   PUT /api/v1/bookings/:bookingId/status
 * @desc    예약 상태 변경
 * @access  Private
 */
router.put(
  '/:bookingId/status',
  [
    param('bookingId').notEmpty().isInt().withMessage('유효한 예약 ID가 필요합니다.'),
    body('status')
      .notEmpty()
      .isIn(['pending', 'confirmed', 'cancelled', 'completed'])
      .withMessage('유효한 상태가 필요합니다.'),
  ],
  validate,
  updateBookingStatus
);

export default router;

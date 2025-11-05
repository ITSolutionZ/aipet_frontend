import express from 'express';
import { body } from 'express-validator';
import {
  verifyToken,
  getCurrentUser,
  syncUser,
  logout,
} from '../controllers/auth.controller.js';
import { authenticateFirebase } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';

const router = express.Router();

/**
 * @route   POST /api/v1/auth/verify-token
 * @desc    Firebase ID Token 검증 (프론트엔드 호환)
 * @access  Private
 */
router.post('/verify-token', authenticateFirebase, verifyToken);

/**
 * @route   GET /api/v1/auth/me
 * @desc    현재 로그인한 사용자 정보 조회
 * @access  Private
 */
router.get('/me', authenticateFirebase, getCurrentUser);

/**
 * @route   POST /api/v1/users
 * @desc    사용자 생성 또는 업데이트 (Firebase UID 동기화)
 * @access  Private
 */
router.post(
  '/users',
  authenticateFirebase,
  [
    body('email').optional().isEmail().withMessage('유효한 이메일 주소를 입력해주세요.'),
    body('displayName').optional().isString().trim(),
    body('photoURL').optional().isString(),
    body('provider').optional().isString(),
  ],
  validate,
  syncUser
);

/**
 * @route   POST /api/v1/auth/logout
 * @desc    로그아웃
 * @access  Private
 */
router.post('/logout', authenticateFirebase, logout);

export default router;

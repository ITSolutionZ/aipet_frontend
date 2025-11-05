import express from 'express';
import { body, param } from 'express-validator';
import {
  getAllPets,
  getPetById,
  createPet,
  updatePet,
  deletePet,
  getPetStats,
} from '../controllers/pet.controller.js';
import { authenticateFirebase } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';

const router = express.Router();

// 모든 펫 라우트는 인증 필요
router.use(authenticateFirebase);

/**
 * @route   GET /api/v1/pets
 * @desc    모든 펫 조회 (현재 사용자 소유)
 * @access  Private
 */
router.get('/', getAllPets);

/**
 * @route   GET /api/v1/pets/stats
 * @desc    펫 통계 정보 조회
 * @access  Private
 */
router.get('/stats', getPetStats);

/**
 * @route   GET /api/v1/pets/:id
 * @desc    특정 펫 조회
 * @access  Private
 */
router.get(
  '/:id',
  [param('id').notEmpty().withMessage('펫 ID가 필요합니다.')],
  validate,
  getPetById
);

/**
 * @route   POST /api/v1/pets
 * @desc    새 펫 생성
 * @access  Private
 */
router.post(
  '/',
  [
    body('name').notEmpty().trim().withMessage('펫 이름은 필수입니다.'),
    body('type').notEmpty().withMessage('펫 타입은 필수입니다.'),
    body('breed').optional().isString().trim(),
    body('birthDate').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('gender')
      .optional()
      .isIn(['male', 'female', 'unknown'])
      .withMessage('성별은 male, female, unknown 중 하나여야 합니다.'),
    body('weight').optional().isFloat({ min: 0 }).withMessage('체중은 0 이상이어야 합니다.'),
    body('photoUrl').optional().isString(),
    body('microchipNumber').optional().isString().trim(),
    body('isNeutered').optional().isBoolean(),
    body('color').optional().isString().trim(),
    body('notes').optional().isString(),
  ],
  validate,
  createPet
);

/**
 * @route   PUT /api/v1/pets/:id
 * @desc    펫 정보 업데이트
 * @access  Private
 */
router.put(
  '/:id',
  [
    param('id').notEmpty().withMessage('펫 ID가 필요합니다.'),
    body('name').optional().notEmpty().trim(),
    body('type').optional().notEmpty(),
    body('breed').optional().isString().trim(),
    body('birthDate').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('gender')
      .optional()
      .isIn(['male', 'female', 'unknown'])
      .withMessage('성별은 male, female, unknown 중 하나여야 합니다.'),
    body('weight').optional().isFloat({ min: 0 }).withMessage('체중은 0 이상이어야 합니다.'),
    body('photoUrl').optional().isString(),
    body('microchipNumber').optional().isString().trim(),
    body('isNeutered').optional().isBoolean(),
    body('color').optional().isString().trim(),
    body('notes').optional().isString(),
  ],
  validate,
  updatePet
);

/**
 * @route   DELETE /api/v1/pets/:id
 * @desc    펫 삭제 (Soft Delete)
 * @access  Private
 */
router.delete(
  '/:id',
  [param('id').notEmpty().withMessage('펫 ID가 필요합니다.')],
  validate,
  deletePet
);

export default router;

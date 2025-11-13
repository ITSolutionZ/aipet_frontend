import express from 'express';
import { body, param } from 'express-validator';
import {
  getVaccinations,
  createVaccination,
  updateVaccination,
  deleteVaccination,
  getMedicalRecords,
  createMedicalRecord,
  updateMedicalRecord,
  deleteMedicalRecord,
  getWeightHistory,
  createWeightRecord,
  updateWeightRecord,
  deleteWeightRecord,
} from '../controllers/health.controller.js';
import { authenticateFirebase } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';

const router = express.Router();

// 모든 건강 라우트는 인증 필요
router.use(authenticateFirebase);

// ===========================
// 예방접종 (Vaccinations)
// ===========================

/**
 * @route   GET /api/v1/health/pets/:petId/vaccinations
 * @desc    특정 펫의 예방접종 기록 조회
 * @access  Private
 */
router.get(
  '/pets/:petId/vaccinations',
  [param('petId').notEmpty().withMessage('펫 ID가 필요합니다.')],
  validate,
  getVaccinations
);

/**
 * @route   POST /api/v1/health/pets/:petId/vaccinations
 * @desc    예방접종 기록 생성
 * @access  Private
 */
router.post(
  '/pets/:petId/vaccinations',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    body('vaccineName').notEmpty().trim().withMessage('백신명은 필수입니다.'),
    body('vaccineType').optional().isString().trim(),
    body('vaccinationDate')
      .notEmpty()
      .isISO8601()
      .withMessage('접종일은 필수이며 유효한 날짜 형식이어야 합니다.'),
    body('nextDueDate').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('veterinarianName').optional().isString().trim(),
    body('clinicName').optional().isString().trim(),
    body('notes').optional().isString(),
  ],
  validate,
  createVaccination
);

/**
 * @route   PUT /api/v1/health/pets/:petId/vaccinations/:vaccinationId
 * @desc    예방접종 기록 업데이트
 * @access  Private
 */
router.put(
  '/pets/:petId/vaccinations/:vaccinationId',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    param('vaccinationId').notEmpty().withMessage('예방접종 ID가 필요합니다.'),
    body('vaccineName').optional().notEmpty().trim(),
    body('vaccineType').optional().isString().trim(),
    body('vaccinationDate').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('nextDueDate').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('veterinarianName').optional().isString().trim(),
    body('clinicName').optional().isString().trim(),
    body('notes').optional().isString(),
  ],
  validate,
  updateVaccination
);

/**
 * @route   DELETE /api/v1/health/pets/:petId/vaccinations/:vaccinationId
 * @desc    예방접종 기록 삭제
 * @access  Private
 */
router.delete(
  '/pets/:petId/vaccinations/:vaccinationId',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    param('vaccinationId').notEmpty().withMessage('예방접종 ID가 필요합니다.'),
  ],
  validate,
  deleteVaccination
);

// ===========================
// 의료 기록 (Medical Records)
// ===========================

/**
 * @route   GET /api/v1/health/pets/:petId/medical-records
 * @desc    특정 펫의 의료 기록 조회
 * @access  Private
 */
router.get(
  '/pets/:petId/medical-records',
  [param('petId').notEmpty().withMessage('펫 ID가 필요합니다.')],
  validate,
  getMedicalRecords
);

/**
 * @route   POST /api/v1/health/pets/:petId/medical-records
 * @desc    의료 기록 생성
 * @access  Private
 */
router.post(
  '/pets/:petId/medical-records',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    body('visitDate')
      .notEmpty()
      .isISO8601()
      .withMessage('방문일은 필수이며 유효한 날짜 형식이어야 합니다.'),
    body('visitType').optional().isString().trim(),
    body('diagnosis').optional().isString(),
    body('treatment').optional().isString(),
    body('prescription').optional().isString(),
    body('veterinarianName').optional().isString().trim(),
    body('clinicName').optional().isString().trim(),
    body('cost').optional().isFloat({ min: 0 }).withMessage('비용은 0 이상이어야 합니다.'),
    body('notes').optional().isString(),
  ],
  validate,
  createMedicalRecord
);

/**
 * @route   PUT /api/v1/health/pets/:petId/medical-records/:recordId
 * @desc    의료 기록 업데이트
 * @access  Private
 */
router.put(
  '/pets/:petId/medical-records/:recordId',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    param('recordId').notEmpty().withMessage('의료 기록 ID가 필요합니다.'),
    body('visitDate').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('visitType').optional().isString().trim(),
    body('diagnosis').optional().isString(),
    body('treatment').optional().isString(),
    body('prescription').optional().isString(),
    body('veterinarianName').optional().isString().trim(),
    body('clinicName').optional().isString().trim(),
    body('cost').optional().isFloat({ min: 0 }).withMessage('비용은 0 이상이어야 합니다.'),
    body('notes').optional().isString(),
  ],
  validate,
  updateMedicalRecord
);

/**
 * @route   DELETE /api/v1/health/pets/:petId/medical-records/:recordId
 * @desc    의료 기록 삭제
 * @access  Private
 */
router.delete(
  '/pets/:petId/medical-records/:recordId',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    param('recordId').notEmpty().withMessage('의료 기록 ID가 필요합니다.'),
  ],
  validate,
  deleteMedicalRecord
);

// ===========================
// 체중 기록 (Weight History)
// ===========================

/**
 * @route   GET /api/v1/health/pets/:petId/weight-history
 * @desc    특정 펫의 체중 기록 조회
 * @access  Private
 */
router.get(
  '/pets/:petId/weight-history',
  [param('petId').notEmpty().withMessage('펫 ID가 필요합니다.')],
  validate,
  getWeightHistory
);

/**
 * @route   POST /api/v1/health/pets/:petId/weight-history
 * @desc    체중 기록 생성
 * @access  Private
 */
router.post(
  '/pets/:petId/weight-history',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    body('weight')
      .notEmpty()
      .isFloat({ min: 0 })
      .withMessage('체중은 필수이며 0 이상이어야 합니다.'),
    body('measuredAt').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('notes').optional().isString(),
  ],
  validate,
  createWeightRecord
);

/**
 * @route   PUT /api/v1/health/pets/:petId/weight-history/:weightId
 * @desc    체중 기록 업데이트
 * @access  Private
 */
router.put(
  '/pets/:petId/weight-history/:weightId',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    param('weightId').notEmpty().withMessage('체중 기록 ID가 필요합니다.'),
    body('weight').optional().isFloat({ min: 0 }).withMessage('체중은 0 이상이어야 합니다.'),
    body('measuredAt').optional().isISO8601().withMessage('유효한 날짜 형식이 아닙니다.'),
    body('notes').optional().isString(),
  ],
  validate,
  updateWeightRecord
);

/**
 * @route   DELETE /api/v1/health/pets/:petId/weight-history/:weightId
 * @desc    체중 기록 삭제
 * @access  Private
 */
router.delete(
  '/pets/:petId/weight-history/:weightId',
  [
    param('petId').notEmpty().withMessage('펫 ID가 필요합니다.'),
    param('weightId').notEmpty().withMessage('체중 기록 ID가 필요합니다.'),
  ],
  validate,
  deleteWeightRecord
);

export default router;

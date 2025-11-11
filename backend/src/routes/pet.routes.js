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
 * @openapi
 * /api/v1/pets:
 *   get:
 *     tags:
 *       - Pets
 *     summary: ペット一覧取得
 *     description: ログイン中のユーザーが所有するペット一覧を取得します
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: ペット一覧の取得に成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Pet'
 *                 count:
 *                   type: integer
 *                   example: 3
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.get('/', getAllPets);

/**
 * @openapi
 * /api/v1/pets/stats:
 *   get:
 *     tags:
 *       - Pets
 *     summary: ペット統計情報取得
 *     description: ユーザーのペットに関する統計情報を取得します
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: 統計情報の取得に成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     total:
 *                       type: integer
 *                       example: 3
 *                     byType:
 *                       type: object
 *                       example: {"dog": 2, "cat": 1}
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.get('/stats', getPetStats);

/**
 * @openapi
 * /api/v1/pets/{id}:
 *   get:
 *     tags:
 *       - Pets
 *     summary: ペット詳細取得
 *     description: 指定されたIDのペット情報を取得します
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ペットID
 *     responses:
 *       200:
 *         description: ペット情報の取得に成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   $ref: '#/components/schemas/Pet'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       403:
 *         $ref: '#/components/responses/ForbiddenError'
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
 */
router.get(
  '/:id',
  [param('id').notEmpty().withMessage('펫 ID가 필요합니다.')],
  validate,
  getPetById
);

/**
 * @openapi
 * /api/v1/pets:
 *   post:
 *     tags:
 *       - Pets
 *     summary: ペット作成
 *     description: 新しいペットを登録します
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/PetInput'
 *     responses:
 *       201:
 *         description: ペットの作成に成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: ペットを作成しました
 *                 data:
 *                   $ref: '#/components/schemas/Pet'
 *       400:
 *         $ref: '#/components/responses/ValidationError'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
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
 * @openapi
 * /api/v1/pets/{id}:
 *   put:
 *     tags:
 *       - Pets
 *     summary: ペット情報更新
 *     description: 指定されたペットの情報を更新します
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ペットID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/PetInput'
 *     responses:
 *       200:
 *         description: ペット情報の更新に成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: ペット情報を更新しました
 *                 data:
 *                   $ref: '#/components/schemas/Pet'
 *       400:
 *         $ref: '#/components/responses/ValidationError'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       403:
 *         $ref: '#/components/responses/ForbiddenError'
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
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
 * @openapi
 * /api/v1/pets/{id}:
 *   delete:
 *     tags:
 *       - Pets
 *     summary: ペット削除
 *     description: 指定されたペットを削除します（論理削除）
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ペットID
 *     responses:
 *       200:
 *         description: ペットの削除に成功
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: ペットを削除しました
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       403:
 *         $ref: '#/components/responses/ForbiddenError'
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
 */
router.delete(
  '/:id',
  [param('id').notEmpty().withMessage('펫 ID가 필요합니다.')],
  validate,
  deletePet
);

export default router;

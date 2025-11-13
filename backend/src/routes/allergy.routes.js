import express from 'express';
import { body, param, query } from 'express-validator';
import {
  getAllergyRecords,
  getAllergyRecordById,
  createAllergyRecord,
  updateAllergyRecord,
  deleteAllergyRecord,
  getAllergyStatistics,
} from '../controllers/allergy.controller.js';
import { authenticateFirebase } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';

const router = express.Router();

// 모든 알레르기 라우트는 인증 필요
router.use(authenticateFirebase);

/**
 * @openapi
 * /api/v1/allergy/pets/{petId}/records:
 *   get:
 *     tags:
 *       - Allergy
 *     summary: ペットのアレルギー記録一覧取得
 *     description: 特定のペットのアレルギー記録一覧を取得します
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: petId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ペットID
 *       - in: query
 *         name: severity
 *         schema:
 *           type: string
 *           enum: [low, moderate, high, critical]
 *         description: 重症度でフィルタリング
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 100
 *         description: 取得件数の上限
 *     responses:
 *       200:
 *         description: アレルギー記録一覧の取得に成功
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
 *                   example: アレルギー記録を取得しました
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/AllergyRecord'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.get(
  '/pets/:petId/records',
  [
    param('petId').isInt().withMessage('ペットIDは整数である必要があります'),
    query('severity')
      .optional()
      .isIn(['low', 'moderate', 'high', 'critical'])
      .withMessage('重症度は low, moderate, high, critical のいずれかである必要があります'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 500 })
      .withMessage('limitは1〜500の整数である必要があります'),
  ],
  validate,
  getAllergyRecords
);

/**
 * @openapi
 * /api/v1/allergy/records/{recordId}:
 *   get:
 *     tags:
 *       - Allergy
 *     summary: アレルギー記録詳細取得
 *     description: 特定のアレルギー記録の詳細を取得します
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: recordId
 *         required: true
 *         schema:
 *           type: integer
 *         description: アレルギー記録ID
 *     responses:
 *       200:
 *         description: アレルギー記録の取得に成功
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
 *                   example: アレルギー記録を取得しました
 *                 data:
 *                   $ref: '#/components/schemas/AllergyRecord'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       404:
 *         description: アレルギー記録が見つかりません
 */
router.get(
  '/records/:recordId',
  [param('recordId').isInt().withMessage('記録IDは整数である必要があります')],
  validate,
  getAllergyRecordById
);

/**
 * @openapi
 * /api/v1/allergy/pets/{petId}/records:
 *   post:
 *     tags:
 *       - Allergy
 *     summary: アレルギー記録作成
 *     description: ペットの新しいアレルギー記録を作成します
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: petId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ペットID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - severity
 *               - occurredAt
 *             properties:
 *               products:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: アレルギーを引き起こした製品リスト
 *                 example: ["ドッグフードA", "おやつB"]
 *               reactions:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: アレルギー反応の症状リスト
 *                 example: ["皮膚の赤み", "かゆみ", "嘔吐"]
 *               severity:
 *                 type: string
 *                 enum: [low, moderate, high, critical]
 *                 description: 重症度
 *                 example: moderate
 *               occurredAt:
 *                 type: string
 *                 format: date-time
 *                 description: 発生日時（ISO 8601形式）
 *                 example: 2025-11-12T10:00:00Z
 *               notes:
 *                 type: string
 *                 description: メモ
 *                 example: 食後30分程度で症状が現れた
 *     responses:
 *       201:
 *         description: アレルギー記録の作成に成功
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
 *                   example: アレルギー記録を作成しました
 *                 data:
 *                   $ref: '#/components/schemas/AllergyRecord'
 *       400:
 *         description: バリデーションエラー
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       404:
 *         description: ペットが見つかりません
 */
router.post(
  '/pets/:petId/records',
  [
    param('petId').isInt().withMessage('ペットIDは整数である必要があります'),
    body('products')
      .optional()
      .isArray()
      .withMessage('productsは配列である必要があります'),
    body('reactions')
      .optional()
      .isArray()
      .withMessage('reactionsは配列である必要があります'),
    body('severity')
      .notEmpty()
      .isIn(['low', 'moderate', 'high', 'critical'])
      .withMessage('重症度は low, moderate, high, critical のいずれかである必要があります'),
    body('occurredAt')
      .notEmpty()
      .isISO8601()
      .withMessage('発生日時は有効なISO 8601形式である必要があります'),
    body('notes').optional().trim(),
  ],
  validate,
  createAllergyRecord
);

/**
 * @openapi
 * /api/v1/allergy/records/{recordId}:
 *   put:
 *     tags:
 *       - Allergy
 *     summary: アレルギー記録更新
 *     description: 既存のアレルギー記録を更新します
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: recordId
 *         required: true
 *         schema:
 *           type: integer
 *         description: アレルギー記録ID
 *     requestBody:
 *       required: false
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               products:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: アレルギーを引き起こした製品リスト
 *               reactions:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: アレルギー反応の症状リスト
 *               severity:
 *                 type: string
 *                 enum: [low, moderate, high, critical]
 *                 description: 重症度
 *               occurredAt:
 *                 type: string
 *                 format: date-time
 *                 description: 発生日時（ISO 8601形式）
 *               notes:
 *                 type: string
 *                 description: メモ
 *     responses:
 *       200:
 *         description: アレルギー記録の更新に成功
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
 *                   example: アレルギー記録を更新しました
 *                 data:
 *                   $ref: '#/components/schemas/AllergyRecord'
 *       400:
 *         description: 更新する項目がありません
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       404:
 *         description: アレルギー記録が見つかりません
 */
router.put(
  '/records/:recordId',
  [
    param('recordId').isInt().withMessage('記録IDは整数である必要があります'),
    body('products')
      .optional()
      .isArray()
      .withMessage('productsは配列である必要があります'),
    body('reactions')
      .optional()
      .isArray()
      .withMessage('reactionsは配列である必要があります'),
    body('severity')
      .optional()
      .isIn(['low', 'moderate', 'high', 'critical'])
      .withMessage('重症度は low, moderate, high, critical のいずれかである必要があります'),
    body('occurredAt')
      .optional()
      .isISO8601()
      .withMessage('発生日時は有効なISO 8601形式である必要があります'),
    body('notes').optional().trim(),
  ],
  validate,
  updateAllergyRecord
);

/**
 * @openapi
 * /api/v1/allergy/records/{recordId}:
 *   delete:
 *     tags:
 *       - Allergy
 *     summary: アレルギー記録削除
 *     description: 既存のアレルギー記録を削除します
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: recordId
 *         required: true
 *         schema:
 *           type: integer
 *         description: アレルギー記録ID
 *     responses:
 *       200:
 *         description: アレルギー記録の削除に成功
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
 *                   example: アレルギー記録を削除しました
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       404:
 *         description: アレルギー記録が見つかりません
 */
router.delete(
  '/records/:recordId',
  [param('recordId').isInt().withMessage('記録IDは整数である必要があります')],
  validate,
  deleteAllergyRecord
);

/**
 * @openapi
 * /api/v1/allergy/pets/{petId}/statistics:
 *   get:
 *     tags:
 *       - Allergy
 *     summary: アレルギー統計取得
 *     description: ペットのアレルギー統計情報を取得します
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: petId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ペットID
 *     responses:
 *       200:
 *         description: アレルギー統計の取得に成功
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
 *                   example: アレルギー統計を取得しました
 *                 data:
 *                   type: object
 *                   properties:
 *                     total:
 *                       type: integer
 *                       description: 総記録数
 *                       example: 10
 *                     bySeverity:
 *                       type: object
 *                       description: 重症度別の件数
 *                       properties:
 *                         low:
 *                           type: integer
 *                           example: 3
 *                         moderate:
 *                           type: integer
 *                           example: 5
 *                         high:
 *                           type: integer
 *                           example: 2
 *                         critical:
 *                           type: integer
 *                           example: 0
 *                     lastOccurrence:
 *                       type: string
 *                       format: date-time
 *                       description: 最後のアレルギー発生日時
 *                       example: 2025-11-12T10:00:00Z
 *                     topReactions:
 *                       type: array
 *                       description: 最も頻繁な反応トップ5
 *                       items:
 *                         type: object
 *                         properties:
 *                           reaction:
 *                             type: string
 *                             example: かゆみ
 *                           count:
 *                             type: integer
 *                             example: 7
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.get(
  '/pets/:petId/statistics',
  [param('petId').isInt().withMessage('ペットIDは整数である必要があります')],
  validate,
  getAllergyStatistics
);

/**
 * @openapi
 * components:
 *   schemas:
 *     AllergyRecord:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *           description: アレルギー記録ID
 *           example: 1
 *         pet_id:
 *           type: integer
 *           description: ペットID
 *           example: 123
 *         products:
 *           type: array
 *           items:
 *             type: string
 *           description: アレルギーを引き起こした製品リスト
 *           example: ["ドッグフードA", "おやつB"]
 *         reactions:
 *           type: array
 *           items:
 *             type: string
 *           description: アレルギー反応の症状リスト
 *           example: ["皮膚の赤み", "かゆみ", "嘔吐"]
 *         severity:
 *           type: string
 *           enum: [low, moderate, high, critical]
 *           description: 重症度
 *           example: moderate
 *         occurred_at:
 *           type: string
 *           format: date-time
 *           description: 発生日時
 *           example: 2025-11-12T10:00:00Z
 *         notes:
 *           type: string
 *           nullable: true
 *           description: メモ
 *           example: 食後30分程度で症状が現れた
 *         created_at:
 *           type: string
 *           format: date-time
 *           description: 作成日時
 *           example: 2025-11-12T10:30:00Z
 *         updated_at:
 *           type: string
 *           format: date-time
 *           description: 更新日時
 *           example: 2025-11-12T10:30:00Z
 */

export default router;

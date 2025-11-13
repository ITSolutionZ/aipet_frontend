import express from 'express';
import { body, param, query } from 'express-validator';
import {
  getSchedules,
  getScheduleById,
  createSchedule,
  updateSchedule,
  deleteSchedule,
  updateScheduleStatus,
} from '../controllers/schedule.controller.js';
import { authenticateFirebase } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';

const router = express.Router();

// 모든 스케줄 라우트는 인증 필요
router.use(authenticateFirebase);

/**
 * @openapi
 * /api/v1/schedules:
 *   get:
 *     tags:
 *       - Schedules
 *     summary: スケジュール一覧取得
 *     description: ログイン中のユーザーのスケジュール一覧を取得します（フィルタリング可能）
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: query
 *         name: petId
 *         schema:
 *           type: integer
 *         description: ペットIDでフィルタリング
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [walk, feeding, medication, grooming, medical, hotel, daycare, training, checkup, vaccination, weight, custom]
 *         description: スケジュールタイプでフィルタリング
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [pending, confirmed, inProgress, completed, cancelled, missed]
 *         description: ステータスでフィルタリング
 *       - in: query
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date-time
 *         description: 開始日時の下限（ISO 8601形式）
 *       - in: query
 *         name: endDate
 *         schema:
 *           type: string
 *           format: date-time
 *         description: 開始日時の上限（ISO 8601形式）
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 100
 *         description: 取得件数の上限
 *     responses:
 *       200:
 *         description: スケジュール一覧の取得に成功
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
 *                   example: スケジュールリストを取得しました
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Schedule'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.get(
  '/',
  [
    query('petId').optional().isInt().withMessage('ペットIDは整数である必要があります'),
    query('type')
      .optional()
      .isIn([
        'walk',
        'feeding',
        'medication',
        'grooming',
        'medical',
        'hotel',
        'daycare',
        'training',
        'checkup',
        'vaccination',
        'weight',
        'custom',
      ])
      .withMessage('無効なスケジュールタイプです'),
    query('status')
      .optional()
      .isIn(['pending', 'confirmed', 'inProgress', 'completed', 'cancelled', 'missed'])
      .withMessage('無効なステータスです'),
    query('startDate').optional().isISO8601().withMessage('有効な日時形式（ISO 8601）が必要です'),
    query('endDate').optional().isISO8601().withMessage('有効な日時形式（ISO 8601）が必要です'),
    query('limit').optional().isInt({ min: 1, max: 1000 }).withMessage('制限は1～1000の範囲である必要があります'),
  ],
  validate,
  getSchedules
);

/**
 * @openapi
 * /api/v1/schedules/{scheduleId}:
 *   get:
 *     tags:
 *       - Schedules
 *     summary: スケジュール詳細取得
 *     description: 指定されたIDのスケジュール情報を取得します
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: scheduleId
 *         required: true
 *         schema:
 *           type: integer
 *         description: スケジュールID
 *     responses:
 *       200:
 *         description: スケジュール情報の取得に成功
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
 *                   example: スケジュールを取得しました
 *                 data:
 *                   $ref: '#/components/schemas/Schedule'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       403:
 *         $ref: '#/components/responses/ForbiddenError'
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
 */
router.get(
  '/:scheduleId',
  [param('scheduleId').isInt().withMessage('スケジュールIDは整数である必要があります')],
  validate,
  getScheduleById
);

/**
 * @openapi
 * /api/v1/schedules:
 *   post:
 *     tags:
 *       - Schedules
 *     summary: スケジュール作成
 *     description: 新しいスケジュールを作成します
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ScheduleInput'
 *     responses:
 *       201:
 *         description: スケジュールの作成に成功
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
 *                   example: スケジュールを作成しました
 *                 data:
 *                   $ref: '#/components/schemas/Schedule'
 *       400:
 *         $ref: '#/components/responses/ValidationError'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.post(
  '/',
  [
    body('petId').isInt().withMessage('ペットIDは整数である必要があります'),
    body('title').notEmpty().trim().withMessage('タイトルは必須です'),
    body('description').optional().trim(),
    body('startDatetime').isISO8601().withMessage('有効な開始日時（ISO 8601）が必要です'),
    body('endDatetime').optional().isISO8601().withMessage('有効な終了日時（ISO 8601）が必要です'),
    body('duration').optional().isInt({ min: 0 }).withMessage('期間は0以上の整数である必要があります'),
    body('type')
      .isIn([
        'walk',
        'feeding',
        'medication',
        'grooming',
        'medical',
        'hotel',
        'daycare',
        'training',
        'checkup',
        'vaccination',
        'weight',
        'custom',
      ])
      .withMessage('無効なスケジュールタイプです'),
    body('status')
      .optional()
      .isIn(['pending', 'confirmed', 'inProgress', 'completed', 'cancelled', 'missed'])
      .withMessage('無効なステータスです'),
    body('priority')
      .optional()
      .isIn(['low', 'normal', 'high', 'urgent'])
      .withMessage('無効な優先度です'),
    body('location').optional().trim(),
    body('latitude')
      .optional()
      .isFloat({ min: -90, max: 90 })
      .withMessage('緯度は-90～90の範囲である必要があります'),
    body('longitude')
      .optional()
      .isFloat({ min: -180, max: 180 })
      .withMessage('経度は-180～180の範囲である必要があります'),
    body('facilityId').optional().trim(),
    body('facilityName').optional().trim(),
    body('staffName').optional().trim(),
    body('staffPhone').optional().trim(),
    body('price').optional().isFloat({ min: 0 }).withMessage('価格は0以上である必要があります'),
    body('services').optional().isArray().withMessage('サービスは配列である必要があります'),
    body('hasReminder').optional().isBoolean().withMessage('リマインダーフラグはブール値である必要があります'),
    body('reminderTime').optional().isInt({ min: 0 }).withMessage('リマインダー時間は0以上の整数である必要があります'),
    body('reminderTimes').optional().isArray().withMessage('リマインダー時間は配列である必要があります'),
    body('isRecurring').optional().isBoolean().withMessage('繰り返しフラグはブール値である必要があります'),
    body('recurrenceRule').optional().trim(),
    body('notes').optional().trim(),
    body('specialRequests').optional().trim(),
    body('customData').optional().isObject().withMessage('カスタムデータはオブジェクトである必要があります'),
  ],
  validate,
  createSchedule
);

/**
 * @openapi
 * /api/v1/schedules/{scheduleId}:
 *   put:
 *     tags:
 *       - Schedules
 *     summary: スケジュール更新
 *     description: 指定されたスケジュールの情報を更新します
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: scheduleId
 *         required: true
 *         schema:
 *           type: integer
 *         description: スケジュールID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/ScheduleInput'
 *     responses:
 *       200:
 *         description: スケジュール情報の更新に成功
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
 *                   example: スケジュールを更新しました
 *                 data:
 *                   $ref: '#/components/schemas/Schedule'
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
  '/:scheduleId',
  [
    param('scheduleId').isInt().withMessage('スケジュールIDは整数である必要があります'),
    body('petId').optional().isInt().withMessage('ペットIDは整数である必要があります'),
    body('title').optional().notEmpty().trim(),
    body('description').optional().trim(),
    body('startDatetime').optional().isISO8601().withMessage('有効な開始日時（ISO 8601）が必要です'),
    body('endDatetime').optional().isISO8601().withMessage('有効な終了日時（ISO 8601）が必要です'),
    body('duration').optional().isInt({ min: 0 }).withMessage('期間は0以上の整数である必要があります'),
    body('type')
      .optional()
      .isIn([
        'walk',
        'feeding',
        'medication',
        'grooming',
        'medical',
        'hotel',
        'daycare',
        'training',
        'checkup',
        'vaccination',
        'weight',
        'custom',
      ])
      .withMessage('無効なスケジュールタイプです'),
    body('status')
      .optional()
      .isIn(['pending', 'confirmed', 'inProgress', 'completed', 'cancelled', 'missed'])
      .withMessage('無効なステータスです'),
    body('priority')
      .optional()
      .isIn(['low', 'normal', 'high', 'urgent'])
      .withMessage('無効な優先度です'),
    body('location').optional().trim(),
    body('latitude')
      .optional()
      .isFloat({ min: -90, max: 90 })
      .withMessage('緯度は-90～90の範囲である必要があります'),
    body('longitude')
      .optional()
      .isFloat({ min: -180, max: 180 })
      .withMessage('経度は-180～180の範囲である必要があります'),
    body('facilityId').optional().trim(),
    body('facilityName').optional().trim(),
    body('staffName').optional().trim(),
    body('staffPhone').optional().trim(),
    body('price').optional().isFloat({ min: 0 }).withMessage('価格は0以上である必要があります'),
    body('services').optional().isArray().withMessage('サービスは配列である必要があります'),
    body('hasReminder').optional().isBoolean().withMessage('リマインダーフラグはブール値である必要があります'),
    body('reminderTime').optional().isInt({ min: 0 }).withMessage('リマインダー時間は0以上の整数である必要があります'),
    body('reminderTimes').optional().isArray().withMessage('リマインダー時間は配列である必要があります'),
    body('isRecurring').optional().isBoolean().withMessage('繰り返しフラグはブール値である必要があります'),
    body('recurrenceRule').optional().trim(),
    body('notes').optional().trim(),
    body('specialRequests').optional().trim(),
    body('customData').optional().isObject().withMessage('カスタムデータはオブジェクトである必要があります'),
  ],
  validate,
  updateSchedule
);

/**
 * @openapi
 * /api/v1/schedules/{scheduleId}/status:
 *   put:
 *     tags:
 *       - Schedules
 *     summary: スケジュールステータス更新
 *     description: 指定されたスケジュールのステータスを更新します
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: scheduleId
 *         required: true
 *         schema:
 *           type: integer
 *         description: スケジュールID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - status
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [pending, confirmed, inProgress, completed, cancelled, missed]
 *                 example: completed
 *     responses:
 *       200:
 *         description: ステータスの更新に成功
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
 *                   example: スケジュールステータスを更新しました
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
  '/:scheduleId/status',
  [
    param('scheduleId').isInt().withMessage('スケジュールIDは整数である必要があります'),
    body('status')
      .isIn(['pending', 'confirmed', 'inProgress', 'completed', 'cancelled', 'missed'])
      .withMessage('無効なステータスです'),
  ],
  validate,
  updateScheduleStatus
);

/**
 * @openapi
 * /api/v1/schedules/{scheduleId}:
 *   delete:
 *     tags:
 *       - Schedules
 *     summary: スケジュール削除
 *     description: 指定されたスケジュールを削除します
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: scheduleId
 *         required: true
 *         schema:
 *           type: integer
 *         description: スケジュールID
 *     responses:
 *       200:
 *         description: スケジュールの削除に成功
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
 *                   example: スケジュールを削除しました
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       403:
 *         $ref: '#/components/responses/ForbiddenError'
 *       404:
 *         $ref: '#/components/responses/NotFoundError'
 */
router.delete(
  '/:scheduleId',
  [param('scheduleId').isInt().withMessage('スケジュールIDは整数である必要があります')],
  validate,
  deleteSchedule
);

export default router;

import express from 'express';
import { param, query } from 'express-validator';
import {
  getDashboardStatistics,
  getPetStatistics,
  getActivityStatistics,
  getHealthStatistics,
} from '../controllers/statistics.controller.js';
import { authenticateFirebase } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';

const router = express.Router();

// 모든 통계 라우트는 인증 필요
router.use(authenticateFirebase);

/**
 * @openapi
 * /api/v1/statistics/dashboard:
 *   get:
 *     tags:
 *       - Statistics
 *     summary: ダッシュボード統計取得
 *     description: ホーム画面用のダッシュボード統計データを取得します
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: ダッシュボード統計の取得に成功
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
 *                   example: ダッシュボード統計を取得しました
 *                 data:
 *                   type: object
 *                   properties:
 *                     pets:
 *                       type: object
 *                       properties:
 *                         total:
 *                           type: integer
 *                           description: 総ペット数
 *                           example: 2
 *                     walks:
 *                       type: object
 *                       properties:
 *                         today:
 *                           type: object
 *                           properties:
 *                             count:
 *                               type: integer
 *                               example: 3
 *                             distance:
 *                               type: number
 *                               example: 5.2
 *                             duration:
 *                               type: integer
 *                               example: 3600
 *                         weekly:
 *                           type: object
 *                           properties:
 *                             distance:
 *                               type: number
 *                               example: 15.5
 *                             goal:
 *                               type: number
 *                               example: 10.0
 *                             progress:
 *                               type: number
 *                               example: 155.0
 *                     appointments:
 *                       type: object
 *                       properties:
 *                         upcoming:
 *                           type: integer
 *                           example: 2
 *                     health:
 *                       type: object
 *                       properties:
 *                         alerts:
 *                           type: array
 *                           items:
 *                             type: object
 *                             properties:
 *                               petName:
 *                                 type: string
 *                               message:
 *                                 type: string
 *                               dueDate:
 *                                 type: string
 *                                 format: date
 *                     feedings:
 *                       type: object
 *                       properties:
 *                         today:
 *                           type: integer
 *                           example: 4
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.get('/dashboard', getDashboardStatistics);

/**
 * @openapi
 * /api/v1/statistics/pets/{petId}:
 *   get:
 *     tags:
 *       - Statistics
 *     summary: ペット統計取得
 *     description: 特定のペットの詳細統計データを取得します
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
 *         description: ペット統計の取得に成功
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
 *                   example: ペット統計を取得しました
 *                 data:
 *                   type: object
 *                   properties:
 *                     petName:
 *                       type: string
 *                       example: ポチ
 *                     walks:
 *                       type: object
 *                       properties:
 *                         total:
 *                           type: integer
 *                         totalDistance:
 *                           type: number
 *                         totalDuration:
 *                           type: integer
 *                         avgDistance:
 *                           type: number
 *                         avgDuration:
 *                           type: integer
 *                     feedings:
 *                       type: object
 *                       properties:
 *                         total:
 *                           type: integer
 *                         totalAmount:
 *                           type: number
 *                     health:
 *                       type: object
 *                       properties:
 *                         vaccinations:
 *                           type: integer
 *                         medicalRecords:
 *                           type: integer
 *                         weightRecords:
 *                           type: integer
 *                     activities:
 *                       type: object
 *                       properties:
 *                         total:
 *                           type: integer
 *                     schedules:
 *                       type: object
 *                       properties:
 *                         total:
 *                           type: integer
 *                         completed:
 *                           type: integer
 *                         pending:
 *                           type: integer
 *                         cancelled:
 *                           type: integer
 *                     recentTrend:
 *                       type: array
 *                       description: 最近30日の散歩トレンド
 *                       items:
 *                         type: object
 *                         properties:
 *                           date:
 *                             type: string
 *                             format: date
 *                           walks:
 *                             type: integer
 *                           distance:
 *                             type: number
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       404:
 *         description: ペットが見つかりません
 */
router.get(
  '/pets/:petId',
  [param('petId').isInt().withMessage('ペットIDは整数である必要があります')],
  validate,
  getPetStatistics
);

/**
 * @openapi
 * /api/v1/statistics/activity:
 *   get:
 *     tags:
 *       - Statistics
 *     summary: アクティビティ統計取得
 *     description: 期間別のアクティビティ統計データを取得します
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: query
 *         name: period
 *         schema:
 *           type: string
 *           enum: [day, week, month, year]
 *           default: week
 *         description: 統計期間
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [walk, feeding, activity]
 *         description: アクティビティタイプ（未指定の場合は全て）
 *     responses:
 *       200:
 *         description: アクティビティ統計の取得に成功
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
 *                   example: アクティビティ統計を取得しました
 *                 data:
 *                   type: object
 *                   properties:
 *                     period:
 *                       type: string
 *                       example: week
 *                     walks:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           period:
 *                             type: string
 *                           count:
 *                             type: integer
 *                           totalDistance:
 *                             type: number
 *                           totalDuration:
 *                             type: integer
 *                           avgDistance:
 *                             type: number
 *                     feedings:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           period:
 *                             type: string
 *                           count:
 *                             type: integer
 *                           totalAmount:
 *                             type: number
 *                     activities:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           period:
 *                             type: string
 *                           byType:
 *                             type: object
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.get(
  '/activity',
  [
    query('period')
      .optional()
      .isIn(['day', 'week', 'month', 'year'])
      .withMessage('期間は day, week, month, year のいずれかである必要があります'),
    query('type')
      .optional()
      .isIn(['walk', 'feeding', 'activity'])
      .withMessage(
        'タイプは walk, feeding, activity のいずれかである必要があります'
      ),
  ],
  validate,
  getActivityStatistics
);

/**
 * @openapi
 * /api/v1/statistics/health:
 *   get:
 *     tags:
 *       - Statistics
 *     summary: 健康統計取得
 *     description: ペットの健康関連統計データを取得します
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: 健康統計の取得に成功
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
 *                   example: 健康統計を取得しました
 *                 data:
 *                   type: object
 *                   properties:
 *                     vaccinations:
 *                       type: object
 *                       properties:
 *                         total:
 *                           type: integer
 *                           description: 総予防接種数
 *                         overdue:
 *                           type: integer
 *                           description: 期限切れ数
 *                         upcoming:
 *                           type: integer
 *                           description: 30日以内の予定数
 *                     medicalRecords:
 *                       type: array
 *                       description: 最近6ヶ月の診療記録統計
 *                       items:
 *                         type: object
 *                         properties:
 *                           month:
 *                             type: string
 *                             example: 2025-11
 *                           count:
 *                             type: integer
 *                           visitType:
 *                             type: string
 *                     weights:
 *                       type: array
 *                       description: ペット別の最新体重
 *                       items:
 *                         type: object
 *                         properties:
 *                           petId:
 *                             type: integer
 *                           petName:
 *                             type: string
 *                           currentWeight:
 *                             type: number
 *                             nullable: true
 *                           measuredAt:
 *                             type: string
 *                             format: date-time
 *                             nullable: true
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.get('/health', getHealthStatistics);

export default router;

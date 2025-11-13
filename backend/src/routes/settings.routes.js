import express from 'express';
import { body } from 'express-validator';
import {
  getUserProfile,
  updateUserProfile,
  getAppSettings,
  saveAppSettings,
  getUserLocation,
  saveUserLocation,
} from '../controllers/settings.controller.js';
import { authenticateFirebase } from '../middlewares/auth.middleware.js';
import { validate } from '../middlewares/validation.middleware.js';

const router = express.Router();

// 모든 설정 라우트는 인증 필요
router.use(authenticateFirebase);

// ============================================================================
// User Profile
// ============================================================================

/**
 * @openapi
 * /api/v1/settings/profile:
 *   get:
 *     tags:
 *       - Settings
 *     summary: ユーザープロフィール取得
 *     description: ログイン中のユーザーのプロフィール情報を取得します
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: プロフィール情報の取得に成功
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
 *                   example: ユーザープロフィールを取得しました
 *                 data:
 *                   type: object
 *                   properties:
 *                     user_id:
 *                       type: string
 *                     display_name:
 *                       type: string
 *                     phone_number:
 *                       type: string
 *                     profile_image_url:
 *                       type: string
 *                     bio:
 *                       type: string
 *                     created_at:
 *                       type: string
 *                       format: date-time
 *                     updated_at:
 *                       type: string
 *                       format: date-time
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       404:
 *         description: ユーザーが見つかりません
 */
router.get('/profile', getUserProfile);

/**
 * @openapi
 * /api/v1/settings/profile:
 *   put:
 *     tags:
 *       - Settings
 *     summary: ユーザープロフィール更新
 *     description: ログイン中のユーザーのプロフィール情報を更新します
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: false
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               displayName:
 *                 type: string
 *                 description: 表示名
 *                 example: 田中太郎
 *               phoneNumber:
 *                 type: string
 *                 description: 電話番号
 *                 example: 090-1234-5678
 *               profileImageUrl:
 *                 type: string
 *                 description: プロフィール画像URL
 *               bio:
 *                 type: string
 *                 description: 自己紹介
 *     responses:
 *       200:
 *         description: プロフィール更新に成功
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
 *                   example: ユーザープロフィールを更新しました
 *                 data:
 *                   type: object
 *       400:
 *         description: 更新する項目がありません
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.put(
  '/profile',
  [
    body('displayName').optional().trim(),
    body('phoneNumber').optional().trim(),
    body('profileImageUrl').optional().trim(),
    body('bio').optional().trim(),
  ],
  validate,
  updateUserProfile
);

// ============================================================================
// App Settings
// ============================================================================

/**
 * @openapi
 * /api/v1/settings/app:
 *   get:
 *     tags:
 *       - Settings
 *     summary: アプリ設定取得
 *     description: ユーザーのアプリ設定を取得します（存在しない場合はデフォルト設定を作成）
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: アプリ設定の取得に成功
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
 *                   example: アプリ設定を取得しました
 *                 data:
 *                   type: object
 *                   properties:
 *                     language:
 *                       type: string
 *                       enum: [ja, en, ko]
 *                       example: ja
 *                     theme:
 *                       type: string
 *                       enum: [light, dark, system]
 *                       example: system
 *                     notifications_enabled:
 *                       type: boolean
 *                       example: true
 *                     auto_backup:
 *                       type: boolean
 *                       example: false
 *                     biometric_login:
 *                       type: boolean
 *                       example: false
 *                     sync_frequency:
 *                       type: string
 *                       enum: [realtime, hourly, daily, manual]
 *                       example: hourly
 *                     created_at:
 *                       type: string
 *                       format: date-time
 *                     updated_at:
 *                       type: string
 *                       format: date-time
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.get('/app', getAppSettings);

/**
 * @openapi
 * /api/v1/settings/app:
 *   put:
 *     tags:
 *       - Settings
 *     summary: アプリ設定保存
 *     description: ユーザーのアプリ設定を保存します
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: false
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               language:
 *                 type: string
 *                 enum: [ja, en, ko]
 *                 description: アプリの言語設定
 *               theme:
 *                 type: string
 *                 enum: [light, dark, system]
 *                 description: テーマ設定
 *               notificationsEnabled:
 *                 type: boolean
 *                 description: 通知の有効/無効
 *               autoBackup:
 *                 type: boolean
 *                 description: 自動バックアップの有効/無効
 *               biometricLogin:
 *                 type: boolean
 *                 description: 生体認証ログインの有効/無効
 *               syncFrequency:
 *                 type: string
 *                 enum: [realtime, hourly, daily, manual]
 *                 description: データ同期の頻度
 *     responses:
 *       200:
 *         description: アプリ設定の保存に成功
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
 *                   example: アプリ設定を保存しました
 *                 data:
 *                   type: object
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.put(
  '/app',
  [
    body('language')
      .optional()
      .isIn(['ja', 'en', 'ko'])
      .withMessage('言語は ja, en, ko のいずれかである必要があります'),
    body('theme')
      .optional()
      .isIn(['light', 'dark', 'system'])
      .withMessage('テーマは light, dark, system のいずれかである必要があります'),
    body('notificationsEnabled')
      .optional()
      .isBoolean()
      .withMessage('通知設定はブール値である必要があります'),
    body('autoBackup')
      .optional()
      .isBoolean()
      .withMessage('自動バックアップ設定はブール値である必要があります'),
    body('biometricLogin')
      .optional()
      .isBoolean()
      .withMessage('生体認証設定はブール値である必要があります'),
    body('syncFrequency')
      .optional()
      .isIn(['realtime', 'hourly', 'daily', 'manual'])
      .withMessage(
        '同期頻度は realtime, hourly, daily, manual のいずれかである必要があります'
      ),
  ],
  validate,
  saveAppSettings
);

// ============================================================================
// User Location
// ============================================================================

/**
 * @openapi
 * /api/v1/settings/location:
 *   get:
 *     tags:
 *       - Settings
 *     summary: ユーザー位置情報取得
 *     description: ユーザーの保存された位置情報（住所）を取得します
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: 位置情報の取得に成功
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
 *                   example: 位置情報を取得しました
 *                 data:
 *                   type: object
 *                   nullable: true
 *                   properties:
 *                     postal_code:
 *                       type: string
 *                       example: 150-0001
 *                     address:
 *                       type: string
 *                       example: 東京都渋谷区神宮前1-2-3
 *                     detail_address:
 *                       type: string
 *                       nullable: true
 *                       example: マンション名 101号室
 *                     created_at:
 *                       type: string
 *                       format: date-time
 *                     updated_at:
 *                       type: string
 *                       format: date-time
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.get('/location', getUserLocation);

/**
 * @openapi
 * /api/v1/settings/location:
 *   put:
 *     tags:
 *       - Settings
 *     summary: ユーザー位置情報保存
 *     description: ユーザーの位置情報（住所）を保存します
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - postalCode
 *               - address
 *             properties:
 *               postalCode:
 *                 type: string
 *                 description: 郵便番号
 *                 example: 150-0001
 *               address:
 *                 type: string
 *                 description: 住所
 *                 example: 東京都渋谷区神宮前1-2-3
 *               detailAddress:
 *                 type: string
 *                 description: 詳細住所（建物名、部屋番号など）
 *                 example: マンション名 101号室
 *     responses:
 *       200:
 *         description: 位置情報の保存に成功
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
 *                   example: 位置情報を保存しました
 *                 data:
 *                   type: object
 *       400:
 *         description: 郵便番号と住所は必須です
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 */
router.put(
  '/location',
  [
    body('postalCode')
      .notEmpty()
      .trim()
      .withMessage('郵便番号は必須です'),
    body('address')
      .notEmpty()
      .trim()
      .withMessage('住所は必須です'),
    body('detailAddress').optional().trim(),
  ],
  validate,
  saveUserLocation
);

export default router;

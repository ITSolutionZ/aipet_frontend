import express from 'express';
import authRoutes from './auth.routes.js';
import petRoutes from './pet.routes.js';
import healthRoutes from './health.routes.js';
import activityRoutes from './activity.routes.js';
import notificationRoutes from './notification.routes.js';
import boardRoutes from './board.routes.js';
import dailyHealthRoutes from './daily-health.routes.js';
import bookingRoutes from './booking.routes.js';
import scheduleRoutes from './schedule.routes.js';
import settingsRoutes from './settings.routes.js';
import allergyRoutes from './allergy.routes.js';

const router = express.Router();

// API 버전 및 라우트 설정
const API_VERSION = process.env.API_VERSION || 'v1';

// Health check
router.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'AIPet Backend API is running',
    version: API_VERSION,
    timestamp: new Date().toISOString(),
  });
});

// 라우트 등록
router.use('/auth', authRoutes);
router.use('/users', authRoutes); // /users 엔드포인트도 auth 라우터로 처리 (프론트엔드 호환)
router.use('/pets', petRoutes);
router.use('/health', healthRoutes);
router.use('/activity', activityRoutes);
router.use('/notifications', notificationRoutes);
router.use('/board', boardRoutes);
router.use('/daily-health', dailyHealthRoutes);
router.use('/bookings', bookingRoutes);
router.use('/schedules', scheduleRoutes);
router.use('/settings', settingsRoutes);
router.use('/allergy', allergyRoutes);

export default router;

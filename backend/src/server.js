import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import swaggerUi from 'swagger-ui-express';
import { testConnection, initializeDatabase } from './config/database.js';
import { initializeFirebase } from './config/firebase.js';
import swaggerSpec from './config/swagger.js';
import routes from './routes/index.js';
import { errorHandler, notFoundHandler } from './middlewares/error.middleware.js';
import {
  startNotificationScheduler,
  startDailyReminderScheduler,
} from './services/notification.scheduler.js';
import pool from './config/database.js';
// 새로운 고급 미들웨어 시스템
import {
  createLoggingMiddleware,
  errorLoggingMiddleware,
  performanceMonitoringMiddleware,
  requestIdMiddleware,
  securityLoggingMiddleware,
  requestSizeLoggingMiddleware,
  statsMiddleware,
  getStats,
} from './middlewares/logging.middleware.js';
import { globalErrorHandler } from './utils/error-handler.js';

// 환경 변수 로드
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const API_VERSION = process.env.API_VERSION || 'v1';

// ===========================
// 미들웨어 설정
// ===========================

// CORS 설정
const corsOptions = {
  origin: function (origin, callback) {
    // 개발 환경에서는 모든 origin 허용
    if (process.env.NODE_ENV === 'development') {
      callback(null, true);
    } else {
      // 프로덕션에서는 허용된 origin만 허용
      const allowedOrigins = process.env.CORS_ORIGIN?.split(',') || [];
      if (!origin || allowedOrigins.indexOf(origin) !== -1) {
        callback(null, true);
      } else {
        callback(new Error('CORS policy: Origin not allowed'));
      }
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};
app.use(cors(corsOptions));

// 보안 헤더 설정
app.use(helmet());

// 압축
app.use(compression());

// Request ID 추가 (추적용)
app.use(requestIdMiddleware);

// Body parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 고급 로깅 시스템
app.use(createLoggingMiddleware());

// 성능 모니터링
app.use(performanceMonitoringMiddleware);

// 보안 패턴 감지
app.use(securityLoggingMiddleware);

// 요청 크기 모니터링
app.use(requestSizeLoggingMiddleware);

// 통계 수집
app.use(statsMiddleware);

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15분
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
  message: {
    success: false,
    error: 'Too many requests from this IP, please try again later.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api', limiter);

// ===========================
// 라우트 설정
// ===========================

/**
 * @openapi
 * /:
 *   get:
 *     tags:
 *       - Health
 *     summary: ヘルスチェック
 *     description: APIサーバーの稼働状態を確認します
 *     responses:
 *       200:
 *         description: サーバーが正常に稼働中
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
 *                   example: AIPet Backend API
 *                 version:
 *                   type: string
 *                   example: v1
 *                 status:
 *                   type: string
 *                   example: running
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 */
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'AIPet Backend API',
    version: API_VERSION,
    status: 'running',
    timestamp: new Date().toISOString(),
  });
});

// Swagger UI
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customSiteTitle: 'AIPet API Documentation',
  customCss: '.swagger-ui .topbar { display: none }',
}));

// Swagger JSON
app.get('/api-docs.json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

// API 라우트
app.use(`/api/${API_VERSION}`, routes);

// 통계 조회 엔드포인트 (관리용)
app.get('/api/stats', (req, res) => {
  const stats = getStats();
  res.json({
    success: true,
    message: '서버 통계를 조회했습니다',
    data: stats,
  });
});

// ===========================
// 에러 핸들링
// ===========================

// 에러 로깅 미들웨어
app.use(errorLoggingMiddleware);

// 404 처리
app.use(notFoundHandler);

// 전역 에러 핸들러 (새로운 고급 에러 핸들러)
app.use(globalErrorHandler);

// ===========================
// 서버 시작
// ===========================

const startServer = async () => {
  try {
    console.log('\n🚀 AIPet Backend 서버 시작 중...\n');

    // 1. Firebase 초기화 (선택사항)
    console.log('📱 Firebase Admin SDK 초기화 중...');
    const firebaseApp = initializeFirebase();
    if (!firebaseApp) {
      console.warn('⚠️  [Warning] Firebase 없이 서버를 시작합니다.');
      console.warn('⚠️  [Warning] 인증이 필요한 API는 작동하지 않습니다.\n');
    }

    // 2. 데이터베이스 연결 테스트
    console.log('🗄️  데이터베이스 연결 확인 중...');
    const isConnected = await testConnection();
    if (!isConnected) {
      throw new Error('데이터베이스 연결 실패');
    }

    // 3. 데이터베이스 테이블 초기화
    console.log('📊 데이터베이스 테이블 초기화 중...');
    await initializeDatabase();

    // 4. 서버 시작
    app.listen(PORT, () => {
      console.log('\n✅ 서버 시작 완료!\n');
      console.log('====================================');
      console.log(`🌐 서버 주소: http://localhost:${PORT}`);
      console.log(`📡 API 엔드포인트: http://localhost:${PORT}/api/${API_VERSION}`);
      console.log(`📖 Swagger UI: http://localhost:${PORT}/api-docs`);
      console.log(`🔧 환경: ${process.env.NODE_ENV || 'development'}`);
      console.log('====================================\n');
      console.log('📚 주요 엔드포인트:');
      console.log(`   GET  / - 헬스 체크`);
      console.log(`   GET  /api/${API_VERSION} - API 정보`);
      console.log(`   GET  /api-docs - Swagger API ドキュメント`);
      console.log(`   GET  /api/stats - 서버 통계 (관리용)`);
      console.log(`   POST /api/${API_VERSION}/auth/verify-token - 토큰 검증`);
      console.log(`   POST /api/${API_VERSION}/users - 사용자 동기화`);
      console.log(`   GET  /api/${API_VERSION}/auth/me - 현재 사용자`);
      console.log(`   GET  /api/${API_VERSION}/pets - 펫 목록`);
      console.log(`   POST /api/${API_VERSION}/pets - 펫 생성`);
      console.log(`   GET  /api/${API_VERSION}/notifications - 알림 목록`);
      console.log(`   POST /api/${API_VERSION}/notifications - 알림 생성`);
      console.log('\n💡 TIP: Android 에뮬레이터에서 테스트하려면');
      console.log('   adb reverse tcp:3000 tcp:3000 명령어를 실행하세요.\n');

      // 5. 알림 스케줄러 시작
      console.log('📬 [Notification] 알림 시스템 초기화 중...\n');
      startNotificationScheduler();
      startDailyReminderScheduler(pool);
      console.log('✅ [Notification] 알림 스케줄러 시작 완료\n');
    });
  } catch (error) {
    console.error('\n❌ 서버 시작 실패:', error.message);
    console.error(error);
    process.exit(1);
  }
};

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('\n⚠️  SIGTERM 신호를 받았습니다. 서버를 종료합니다...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('\n⚠️  SIGINT 신호를 받았습니다. 서버를 종료합니다...');
  process.exit(0);
});

// 서버 시작
startServer();

export default app;

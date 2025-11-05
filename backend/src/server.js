import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { testConnection, initializeDatabase } from './config/database.js';
import { initializeFirebase } from './config/firebase.js';
import routes from './routes/index.js';
import { errorHandler, notFoundHandler } from './middlewares/error.middleware.js';
import {
  startNotificationScheduler,
  startDailyReminderScheduler,
} from './services/notification.scheduler.js';
import pool from './config/database.js';

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

// 로깅 (개발 환경)
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Body parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

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

// 헬스 체크 (루트)
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'AIPet Backend API',
    version: API_VERSION,
    status: 'running',
    timestamp: new Date().toISOString(),
  });
});

// API 라우트
app.use(`/api/${API_VERSION}`, routes);

// ===========================
// 에러 핸들링
// ===========================

// 404 처리
app.use(notFoundHandler);

// 전역 에러 핸들러
app.use(errorHandler);

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
      console.log(`🔧 환경: ${process.env.NODE_ENV || 'development'}`);
      console.log('====================================\n');
      console.log('📚 주요 엔드포인트:');
      console.log(`   GET  / - 헬스 체크`);
      console.log(`   GET  /api/${API_VERSION} - API 정보`);
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

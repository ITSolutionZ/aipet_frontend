/**
 * 로깅 미들웨어
 *
 * API 요청/응답을 로깅하고 성능을 모니터링합니다.
 */

import morgan from 'morgan';
import chalk from 'chalk';

/**
 * 커스텀 Morgan 토큰 정의
 */

// 상태 코드에 따른 색상
morgan.token('status-colored', (req, res) => {
  const status = res.statusCode;
  const color =
    status >= 500
      ? 'red'
      : status >= 400
      ? 'yellow'
      : status >= 300
      ? 'cyan'
      : status >= 200
      ? 'green'
      : 'white';
  return chalk[color](status);
});

// 응답 시간에 따른 색상
morgan.token('response-time-colored', (req, res) => {
  const ms = parseFloat(morgan['response-time'](req, res));
  const color = ms > 1000 ? 'red' : ms > 500 ? 'yellow' : 'green';
  return chalk[color](`${ms.toFixed(2)}ms`);
});

// 메서드에 따른 색상
morgan.token('method-colored', (req) => {
  const method = req.method;
  const colors = {
    GET: 'blue',
    POST: 'green',
    PUT: 'yellow',
    DELETE: 'red',
    PATCH: 'magenta',
  };
  return chalk[colors[method] || 'white'](method.padEnd(7));
});

// 사용자 ID (Firebase Auth)
morgan.token('user-id', (req) => {
  return req.user?.uid ? chalk.cyan(req.user.uid.substring(0, 8)) : chalk.gray('anonymous');
});

// 요청 바디 크기
morgan.token('body-size', (req) => {
  if (!req.body || Object.keys(req.body).length === 0) {
    return chalk.gray('0B');
  }
  const size = JSON.stringify(req.body).length;
  return chalk.blue(`${(size / 1024).toFixed(2)}KB`);
});

/**
 * 개발 환경용 상세 로깅 포맷
 */
const developmentFormat = [
  chalk.gray('['),
  ':date[iso]',
  chalk.gray(']'),
  ':method-colored',
  chalk.white(':url'),
  chalk.gray('│'),
  ':status-colored',
  chalk.gray('│'),
  ':response-time-colored',
  chalk.gray('│'),
  'User:',
  ':user-id',
  chalk.gray('│'),
  'Body:',
  ':body-size',
].join(' ');

/**
 * 프로덕션 환경용 JSON 로깅 포맷
 */
const productionFormat = JSON.stringify({
  timestamp: ':date[iso]',
  method: ':method',
  url: ':url',
  status: ':status',
  responseTime: ':response-time',
  contentLength: ':res[content-length]',
  userAgent: ':user-agent',
  userId: ':user-id',
  referrer: ':referrer',
  ip: ':remote-addr',
});

/**
 * 로깅 스킵 조건
 */
const skipLogging = (req, res) => {
  // 헬스체크 엔드포인트는 로깅하지 않음
  if (req.path === '/health' || req.path === '/') {
    return true;
  }

  // 정적 파일 요청 스킵
  if (req.path.match(/\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$/)) {
    return true;
  }

  return false;
};

/**
 * 로깅 미들웨어 생성
 */
export const createLoggingMiddleware = () => {
  const isDevelopment = process.env.NODE_ENV === 'development';

  return morgan(isDevelopment ? developmentFormat : productionFormat, {
    skip: skipLogging,
    stream: {
      write: (message) => {
        // 개발 환경: 콘솔에 색상 출력
        if (isDevelopment) {
          console.log(message.trim());
        } else {
          // 프로덕션: JSON 로그 (로그 수집 도구용)
          try {
            const log = JSON.parse(message);
            console.log(JSON.stringify({
              ...log,
              level: 'info',
              service: 'aipet-backend',
            }));
          } catch (e) {
            console.log(message.trim());
          }
        }
      },
    },
  });
};

/**
 * 에러 로깅 미들웨어
 */
export const errorLoggingMiddleware = (err, req, res, next) => {
  const errorLog = {
    timestamp: new Date().toISOString(),
    level: 'error',
    service: 'aipet-backend',
    method: req.method,
    url: req.url,
    path: req.path,
    statusCode: err.statusCode || 500,
    errorType: err.type || 'INTERNAL_ERROR',
    errorMessage: err.message,
    userId: req.user?.uid,
    ip: req.ip,
    userAgent: req.get('user-agent'),
  };

  // 개발 환경에서는 스택 트레이스 포함
  if (process.env.NODE_ENV === 'development') {
    errorLog.stack = err.stack;
    console.error(chalk.red('🔴 Error:'), errorLog);
  } else {
    console.error(JSON.stringify(errorLog));
  }

  next(err);
};

/**
 * 성능 모니터링 미들웨어
 */
export const performanceMonitoringMiddleware = (req, res, next) => {
  const startTime = Date.now();

  // 응답 종료 시 성능 로그
  res.on('finish', () => {
    const duration = Date.now() - startTime;

    // 느린 요청 경고 (1초 이상)
    if (duration > 1000) {
      console.warn(chalk.yellow('⚠️  Slow Request:'), {
        method: req.method,
        url: req.url,
        duration: `${duration}ms`,
        statusCode: res.statusCode,
        userId: req.user?.uid,
      });
    }

    // 매우 느린 요청 알림 (3초 이상)
    if (duration > 3000) {
      console.error(chalk.red('🐌 Very Slow Request:'), {
        method: req.method,
        url: req.url,
        duration: `${duration}ms`,
        statusCode: res.statusCode,
        userId: req.user?.uid,
        query: req.query,
        body: req.body,
      });
    }
  });

  next();
};

/**
 * 요청 ID 미들웨어 (추적용)
 */
export const requestIdMiddleware = (req, res, next) => {
  const requestId = req.get('X-Request-ID') ||
                    `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

  req.requestId = requestId;
  res.setHeader('X-Request-ID', requestId);

  next();
};

/**
 * 보안 헤더 로깅 미들웨어
 */
export const securityLoggingMiddleware = (req, res, next) => {
  // 의심스러운 요청 패턴 감지
  const suspiciousPatterns = [
    /(\.\.|\/etc\/|\/proc\/)/i, // Path traversal
    /(union|select|insert|update|delete|drop|create|alter)/i, // SQL Injection
    /(<script|javascript:|onerror=|onclick=)/i, // XSS
  ];

  const isSuspicious = suspiciousPatterns.some(
    (pattern) =>
      pattern.test(req.url) ||
      pattern.test(JSON.stringify(req.body)) ||
      pattern.test(JSON.stringify(req.query))
  );

  if (isSuspicious) {
    console.warn(chalk.red('🚨 Suspicious Request Detected:'), {
      timestamp: new Date().toISOString(),
      method: req.method,
      url: req.url,
      ip: req.ip,
      userAgent: req.get('user-agent'),
      body: req.body,
      query: req.query,
      userId: req.user?.uid,
    });
  }

  next();
};

/**
 * 요청 크기 제한 로깅
 */
export const requestSizeLoggingMiddleware = (req, res, next) => {
  const contentLength = parseInt(req.get('content-length') || '0');
  const maxSize = 10 * 1024 * 1024; // 10MB

  if (contentLength > maxSize) {
    console.warn(chalk.yellow('⚠️  Large Request:'), {
      method: req.method,
      url: req.url,
      contentLength: `${(contentLength / 1024 / 1024).toFixed(2)}MB`,
      userId: req.user?.uid,
    });
  }

  next();
};

/**
 * 일일 통계 로깅 (메모리 기반)
 */
class DailyStats {
  constructor() {
    this.stats = {
      totalRequests: 0,
      successRequests: 0,
      errorRequests: 0,
      averageResponseTime: 0,
      slowRequests: 0,
      byMethod: {},
      byEndpoint: {},
    };
    this.resetDaily();
  }

  resetDaily() {
    setInterval(() => {
      console.log(chalk.blue('📊 Daily Statistics:'), this.stats);
      this.stats = {
        totalRequests: 0,
        successRequests: 0,
        errorRequests: 0,
        averageResponseTime: 0,
        slowRequests: 0,
        byMethod: {},
        byEndpoint: {},
      };
    }, 24 * 60 * 60 * 1000); // 24시간마다 리셋
  }

  record(req, res, duration) {
    this.stats.totalRequests++;

    if (res.statusCode < 400) {
      this.stats.successRequests++;
    } else {
      this.stats.errorRequests++;
    }

    // 평균 응답 시간 계산
    this.stats.averageResponseTime =
      (this.stats.averageResponseTime * (this.stats.totalRequests - 1) + duration) /
      this.stats.totalRequests;

    if (duration > 1000) {
      this.stats.slowRequests++;
    }

    // 메서드별 통계
    this.stats.byMethod[req.method] = (this.stats.byMethod[req.method] || 0) + 1;

    // 엔드포인트별 통계
    const endpoint = `${req.method} ${req.route?.path || req.path}`;
    this.stats.byEndpoint[endpoint] = (this.stats.byEndpoint[endpoint] || 0) + 1;
  }
}

const dailyStats = new DailyStats();

export const statsMiddleware = (req, res, next) => {
  const startTime = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - startTime;
    dailyStats.record(req, res, duration);
  });

  next();
};

// 통계 조회 엔드포인트용
export const getStats = () => dailyStats.stats;

export default {
  createLoggingMiddleware,
  errorLoggingMiddleware,
  performanceMonitoringMiddleware,
  requestIdMiddleware,
  securityLoggingMiddleware,
  requestSizeLoggingMiddleware,
  statsMiddleware,
  getStats,
};

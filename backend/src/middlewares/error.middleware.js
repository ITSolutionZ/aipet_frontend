/**
 * 전역 에러 핸들링 미들웨어
 */
export const errorHandler = (err, req, res, next) => {
  console.error('❌ [Error]:', err);

  // 기본 에러 상태 코드
  const statusCode = err.statusCode || 500;

  // 에러 응답
  res.status(statusCode).json({
    success: false,
    error: err.message || '서버 내부 오류',
    ...(process.env.NODE_ENV === 'development' && {
      stack: err.stack,
      details: err.details,
    }),
  });
};

/**
 * 404 Not Found 핸들러
 */
export const notFoundHandler = (req, res, next) => {
  res.status(404).json({
    success: false,
    error: '요청하신 리소스를 찾을 수 없습니다.',
    path: req.originalUrl,
    method: req.method,
  });
};

/**
 * 커스텀 에러 클래스
 */
export class ApiError extends Error {
  constructor(statusCode, message, details = null) {
    super(message);
    this.statusCode = statusCode;
    this.details = details;
    Error.captureStackTrace(this, this.constructor);
  }
}

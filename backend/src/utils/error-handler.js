/**
 * 공통 에러 핸들링 유틸리티
 *
 * 일관된 에러 응답 형식과 로깅을 제공합니다.
 */

/**
 * 에러 타입 정의
 */
export const ErrorTypes = {
  VALIDATION: 'VALIDATION_ERROR',
  AUTHENTICATION: 'AUTHENTICATION_ERROR',
  AUTHORIZATION: 'AUTHORIZATION_ERROR',
  NOT_FOUND: 'NOT_FOUND',
  CONFLICT: 'CONFLICT',
  DATABASE: 'DATABASE_ERROR',
  EXTERNAL_API: 'EXTERNAL_API_ERROR',
  INTERNAL: 'INTERNAL_ERROR',
};

/**
 * HTTP 상태 코드 매핑
 */
const statusCodeMap = {
  [ErrorTypes.VALIDATION]: 400,
  [ErrorTypes.AUTHENTICATION]: 401,
  [ErrorTypes.AUTHORIZATION]: 403,
  [ErrorTypes.NOT_FOUND]: 404,
  [ErrorTypes.CONFLICT]: 409,
  [ErrorTypes.DATABASE]: 500,
  [ErrorTypes.EXTERNAL_API]: 502,
  [ErrorTypes.INTERNAL]: 500,
};

/**
 * 커스텀 에러 클래스
 */
export class AppError extends Error {
  constructor(type, message, details = null) {
    super(message);
    this.type = type;
    this.statusCode = statusCodeMap[type] || 500;
    this.details = details;
    this.timestamp = new Date().toISOString();
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * 에러 응답 생성
 */
export const createErrorResponse = (error, includeStack = false) => {
  const response = {
    success: false,
    error: {
      type: error.type || ErrorTypes.INTERNAL,
      message: error.message || 'エラーが発生しました',
      timestamp: error.timestamp || new Date().toISOString(),
    },
  };

  // 상세 정보 추가 (있는 경우)
  if (error.details) {
    response.error.details = error.details;
  }

  // 개발 환경에서만 스택 트레이스 포함
  if (includeStack && error.stack) {
    response.error.stack = error.stack;
  }

  return response;
};

/**
 * 데이터베이스 에러 처리
 */
export const handleDatabaseError = (operation, error) => {
  console.error(`❌ Database Error in ${operation}:`, error);

  // MySQL 특정 에러 처리
  if (error.code) {
    switch (error.code) {
      case 'ER_DUP_ENTRY':
        return new AppError(
          ErrorTypes.CONFLICT,
          '既に存在するデータです',
          { sqlCode: error.code }
        );
      case 'ER_NO_REFERENCED_ROW':
      case 'ER_NO_REFERENCED_ROW_2':
        return new AppError(
          ErrorTypes.NOT_FOUND,
          '参照されるデータが見つかりません',
          { sqlCode: error.code }
        );
      case 'ER_ROW_IS_REFERENCED':
      case 'ER_ROW_IS_REFERENCED_2':
        return new AppError(
          ErrorTypes.CONFLICT,
          '他のデータから参照されているため削除できません',
          { sqlCode: error.code }
        );
      case 'ER_LOCK_WAIT_TIMEOUT':
        return new AppError(
          ErrorTypes.DATABASE,
          'データベースがビジー状態です。しばらくしてから再試行してください',
          { sqlCode: error.code }
        );
      case 'ER_ACCESS_DENIED_ERROR':
        return new AppError(
          ErrorTypes.DATABASE,
          'データベース接続エラー',
          { sqlCode: error.code }
        );
      default:
        return new AppError(
          ErrorTypes.DATABASE,
          'データベース操作に失敗しました',
          { sqlCode: error.code, sqlMessage: error.sqlMessage }
        );
    }
  }

  return new AppError(
    ErrorTypes.DATABASE,
    'データベース操作に失敗しました',
    { originalError: error.message }
  );
};

/**
 * 검증 에러 처리
 */
export const handleValidationError = (errors) => {
  const details = errors.map((err) => ({
    field: err.path || err.param,
    message: err.msg,
    value: err.value,
  }));

  return new AppError(
    ErrorTypes.VALIDATION,
    '入力データが正しくありません',
    details
  );
};

/**
 * 인증 에러 처리
 */
export const handleAuthError = (message = '認証に失敗しました') => {
  return new AppError(ErrorTypes.AUTHENTICATION, message);
};

/**
 * 권한 에러 처리
 */
export const handleAuthorizationError = (message = 'アクセス権限がありません') => {
  return new AppError(ErrorTypes.AUTHORIZATION, message);
};

/**
 * Not Found 에러 처리
 */
export const handleNotFoundError = (resource = 'リソース') => {
  return new AppError(ErrorTypes.NOT_FOUND, `${resource}が見つかりません`);
};

/**
 * 에러 로깅 (상세)
 */
export const logError = (context, error, additionalInfo = {}) => {
  const errorLog = {
    timestamp: new Date().toISOString(),
    context,
    type: error.type || 'UNKNOWN',
    message: error.message,
    statusCode: error.statusCode,
    ...additionalInfo,
  };

  console.error('🔴 Error Log:', JSON.stringify(errorLog, null, 2));

  // 스택 트레이스 (개발 환경)
  if (process.env.NODE_ENV === 'development' && error.stack) {
    console.error('Stack Trace:', error.stack);
  }
};

/**
 * 성공 응답 생성
 */
export const createSuccessResponse = (message, data = null, meta = null) => {
  const response = {
    success: true,
    message,
  };

  if (data !== null) {
    response.data = data;
  }

  if (meta) {
    response.meta = meta;
  }

  return response;
};

/**
 * 페이지네이션 메타데이터 생성
 */
export const createPaginationMeta = (page, limit, total) => {
  const totalPages = Math.ceil(total / limit);
  return {
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total: parseInt(total),
      totalPages,
      hasNext: page < totalPages,
      hasPrev: page > 1,
    },
  };
};

/**
 * 비동기 핸들러 래퍼 (try-catch 자동화)
 */
export const asyncHandler = (fn) => {
  return async (req, res, next) => {
    try {
      await fn(req, res, next);
    } catch (error) {
      // AppError인 경우
      if (error instanceof AppError) {
        logError(`${req.method} ${req.path}`, error, {
          userId: req.user?.uid,
          body: req.body,
          query: req.query,
        });

        return res.status(error.statusCode).json(
          createErrorResponse(
            error,
            process.env.NODE_ENV === 'development'
          )
        );
      }

      // 예상치 못한 에러
      logError(`${req.method} ${req.path}`, error, {
        userId: req.user?.uid,
        body: req.body,
        query: req.query,
      });

      const internalError = new AppError(
        ErrorTypes.INTERNAL,
        'サーバーエラーが発生しました'
      );

      return res.status(500).json(
        createErrorResponse(
          internalError,
          process.env.NODE_ENV === 'development'
        )
      );
    }
  };
};

/**
 * 트랜잭션 헬퍼
 */
export const withTransaction = async (pool, callback) => {
  const connection = await pool.getConnection();
  await connection.beginTransaction();

  try {
    const result = await callback(connection);
    await connection.commit();
    return result;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

/**
 * 글로벌 에러 핸들러 미들웨어
 */
export const globalErrorHandler = (err, req, res, next) => {
  logError(`Global Error Handler - ${req.method} ${req.path}`, err, {
    userId: req.user?.uid,
    body: req.body,
    query: req.query,
    params: req.params,
  });

  if (err instanceof AppError) {
    return res.status(err.statusCode).json(
      createErrorResponse(err, process.env.NODE_ENV === 'development')
    );
  }

  // 예상치 못한 에러
  const internalError = new AppError(
    ErrorTypes.INTERNAL,
    'サーバーエラーが発生しました'
  );

  return res.status(500).json(
    createErrorResponse(
      internalError,
      process.env.NODE_ENV === 'development'
    )
  );
};

export default {
  ErrorTypes,
  AppError,
  createErrorResponse,
  handleDatabaseError,
  handleValidationError,
  handleAuthError,
  handleAuthorizationError,
  handleNotFoundError,
  logError,
  createSuccessResponse,
  createPaginationMeta,
  asyncHandler,
  withTransaction,
  globalErrorHandler,
};

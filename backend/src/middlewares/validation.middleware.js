import { validationResult } from 'express-validator';

/**
 * 유효성 검증 결과를 확인하는 미들웨어
 */
export const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      error: '입력 데이터 유효성 검증 실패',
      errors: errors.array().map((err) => ({
        field: err.path,
        message: err.msg,
        value: err.value,
      })),
    });
  }
  next();
};

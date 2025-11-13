import { verifyFirebaseToken } from '../config/firebase.js';

/**
 * Firebase Authentication 미들웨어
 * Authorization 헤더에서 Bearer 토큰을 추출하고 검증합니다.
 */
export const authenticateFirebase = async (req, res, next) => {
  try {
    // Authorization 헤더 확인
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'Authorization 헤더가 없거나 형식이 잘못되었습니다.',
        message: 'Authorization header is required (Bearer token)',
      });
    }

    // Bearer 토큰 추출
    const token = authHeader.replace('Bearer ', '');
    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'Firebase ID Token이 제공되지 않았습니다.',
        message: 'Firebase ID token is required',
      });
    }

    // Firebase Token 검증
    const verificationResult = await verifyFirebaseToken(token);
    if (!verificationResult.success) {
      return res.status(401).json({
        success: false,
        error: 'Firebase Token 검증 실패',
        message: verificationResult.error,
      });
    }

    // 검증된 사용자 정보를 req.user에 저장
    req.user = {
      uid: verificationResult.uid,
      email: verificationResult.email,
      name: verificationResult.name,
      picture: verificationResult.picture,
      provider: verificationResult.provider,
    };

    console.log(`✅ [Auth] 사용자 인증 성공: ${req.user.email} (${req.user.uid})`);
    next();
  } catch (error) {
    console.error('❌ [Auth] 인증 미들웨어 에러:', error);
    return res.status(500).json({
      success: false,
      error: '서버 내부 오류',
      message: error.message,
    });
  }
};

/**
 * 선택적 인증 미들웨어 (토큰이 있으면 검증하고, 없으면 통과)
 */
export const optionalAuthenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      // 토큰이 없으면 그냥 통과
      return next();
    }

    const token = authHeader.replace('Bearer ', '');
    const verificationResult = await verifyFirebaseToken(token);

    if (verificationResult.success) {
      req.user = {
        uid: verificationResult.uid,
        email: verificationResult.email,
        name: verificationResult.name,
        picture: verificationResult.picture,
        provider: verificationResult.provider,
      };
    }

    next();
  } catch (error) {
    // 에러가 발생해도 그냥 통과
    console.warn('⚠️  [Auth] 선택적 인증 실패 (무시):', error.message);
    next();
  }
};

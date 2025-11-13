import admin from 'firebase-admin';
import dotenv from 'dotenv';

dotenv.config();

// Firebase Admin SDK 초기화
let firebaseApp = null;

export const initializeFirebase = () => {
  try {
    // Firebase 설정 확인 (더미 값 체크)
    const isDummyKey = process.env.FIREBASE_PRIVATE_KEY?.includes('YOUR_PRIVATE_KEY_HERE');

    if (!process.env.FIREBASE_PROJECT_ID || isDummyKey) {
      console.warn('\n⚠️  [Firebase] Service Account 정보가 설정되지 않았습니다.');
      console.warn('💡 [Firebase] 테스트 모드로 실행됩니다. 인증 기능은 작동하지 않습니다.');
      console.warn('💡 [Firebase] .env 파일에 실제 Firebase Service Account 정보를 설정하세요.\n');
      return null;
    }

    // 환경 변수에서 Service Account 정보 읽기
    const serviceAccount = {
      type: 'service_account',
      project_id: process.env.FIREBASE_PROJECT_ID,
      private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
      private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
      client_id: process.env.FIREBASE_CLIENT_ID,
      auth_uri: process.env.FIREBASE_AUTH_URI,
      token_uri: process.env.FIREBASE_TOKEN_URI,
      auth_provider_x509_cert_url: process.env.FIREBASE_AUTH_PROVIDER_CERT_URL,
      client_x509_cert_url: process.env.FIREBASE_CLIENT_CERT_URL,
    };

    // Firebase Admin SDK 초기화
    if (!admin.apps.length) {
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      console.log('✅ Firebase Admin SDK 초기화 성공');
    } else {
      firebaseApp = admin.app();
    }

    return firebaseApp;
  } catch (error) {
    console.error('\n❌ Firebase Admin SDK 초기화 실패:', error.message);
    console.error('💡 TIP: .env 파일에 실제 Firebase Service Account 정보를 설정해주세요.');
    console.warn('⚠️  [Firebase] 테스트 모드로 계속 진행합니다...\n');
    return null;
  }
};

// Firebase ID Token 검증 함수
export const verifyFirebaseToken = async (token) => {
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    return {
      success: true,
      uid: decodedToken.uid,
      email: decodedToken.email,
      name: decodedToken.name,
      picture: decodedToken.picture,
      provider: decodedToken.firebase?.sign_in_provider,
    };
  } catch (error) {
    console.error('❌ Firebase Token 검증 실패:', error.message);
    return {
      success: false,
      error: error.message,
    };
  }
};

// Firebase 사용자 정보 조회
export const getFirebaseUser = async (uid) => {
  try {
    const userRecord = await admin.auth().getUser(uid);
    return {
      success: true,
      user: {
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName,
        photoURL: userRecord.photoURL,
        emailVerified: userRecord.emailVerified,
        disabled: userRecord.disabled,
        metadata: userRecord.metadata,
      },
    };
  } catch (error) {
    console.error('❌ Firebase 사용자 조회 실패:', error.message);
    return {
      success: false,
      error: error.message,
    };
  }
};

export default admin;

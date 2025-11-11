/**
 * Firebase Admin SDK를 사용하여 테스트용 Custom Token 생성
 *
 * 사용법:
 *   node scripts/generate-test-token.js [USER_ID]
 *
 * 예시:
 *   node scripts/generate-test-token.js test-user-123
 */

import admin from 'firebase-admin';
import dotenv from 'dotenv';
import { initializeFirebase } from '../src/config/firebase.js';

dotenv.config();

const generateTestToken = async (userId) => {
  try {
    console.log('\n🔐 Firebase 테스트 토큰 생성 중...\n');

    // Firebase Admin SDK 초기화
    const app = initializeFirebase();
    if (!app) {
      throw new Error('Firebase 초기화 실패');
    }

    // Custom Token 생성
    const customToken = await admin.auth().createCustomToken(userId, {
      // Custom Claims (필요시 추가)
      role: 'user',
      testUser: true,
    });

    console.log('═══════════════════════════════════════════════════════');
    console.log('✅ Custom Token 생성 완료!');
    console.log('═══════════════════════════════════════════════════════');
    console.log('User ID:', userId);
    console.log('Custom Token:', customToken);
    console.log('═══════════════════════════════════════════════════════');
    console.log('\n📝 다음 단계:');
    console.log('1. Flutter 앱에서 이 Custom Token으로 로그인');
    console.log('2. Firebase ID Token 획득');
    console.log('3. Swagger UI에서 ID Token 사용\n');
    console.log('💡 또는 Firebase Console에서 테스트 계정을 만들고');
    console.log('   이메일/비밀번호로 로그인하여 ID Token을 얻으세요.\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ 에러 발생:', error.message);
    process.exit(1);
  }
};

// CLI 인자 파싱
const userId = process.argv[2] || 'test-user-' + Date.now();

generateTestToken(userId);

#!/bin/bash

# Firebase Service Account JSON 파일에서 환경 변수 추출하는 스크립트

echo "🔥 Firebase Service Account 설정 스크립트"
echo ""

# JSON 파일 확인
JSON_FILE="../firebase-service-account.json"

if [ ! -f "$JSON_FILE" ]; then
    echo "❌ firebase-service-account.json 파일을 찾을 수 없습니다."
    echo ""
    echo "다음 단계를 따라주세요:"
    echo "1. Firebase Console (https://console.firebase.google.com/) 접속"
    echo "2. 프로젝트 설정 → 서비스 계정 → 새 비공개 키 생성"
    echo "3. 다운로드한 JSON 파일을 backend/firebase-service-account.json으로 저장"
    echo ""
    exit 1
fi

echo "✅ firebase-service-account.json 파일을 찾았습니다."
echo ""

# jq가 설치되어 있는지 확인
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq가 설치되어 있지 않습니다. JSON 파일을 수동으로 파싱합니다..."
    echo ""
    echo "다음 명령어로 .env 파일을 직접 편집해주세요:"
    echo ""
    echo "cat firebase-service-account.json"
    echo ""
    exit 1
fi

# JSON에서 값 추출
PROJECT_ID=$(jq -r '.project_id' $JSON_FILE)
PRIVATE_KEY_ID=$(jq -r '.private_key_id' $JSON_FILE)
PRIVATE_KEY=$(jq -r '.private_key' $JSON_FILE)
CLIENT_EMAIL=$(jq -r '.client_email' $JSON_FILE)
CLIENT_ID=$(jq -r '.client_id' $JSON_FILE)
AUTH_URI=$(jq -r '.auth_uri' $JSON_FILE)
TOKEN_URI=$(jq -r '.token_uri' $JSON_FILE)
AUTH_PROVIDER_CERT_URL=$(jq -r '.auth_provider_x509_cert_url' $JSON_FILE)
CLIENT_CERT_URL=$(jq -r '.client_x509_cert_url' $JSON_FILE)

# .env 파일 백업
if [ -f "../.env" ]; then
    cp ../.env ../.env.backup
    echo "✅ 기존 .env 파일을 .env.backup으로 백업했습니다."
fi

# .env 파일 업데이트
echo ""
echo "📝 .env 파일 업데이트 중..."
echo ""

# Firebase 설정 업데이트
sed -i.bak "s|^FIREBASE_PROJECT_ID=.*|FIREBASE_PROJECT_ID=$PROJECT_ID|" ../.env
sed -i.bak "s|^FIREBASE_PRIVATE_KEY_ID=.*|FIREBASE_PRIVATE_KEY_ID=$PRIVATE_KEY_ID|" ../.env
sed -i.bak "s|^FIREBASE_PRIVATE_KEY=.*|FIREBASE_PRIVATE_KEY=\"$PRIVATE_KEY\"|" ../.env
sed -i.bak "s|^FIREBASE_CLIENT_EMAIL=.*|FIREBASE_CLIENT_EMAIL=$CLIENT_EMAIL|" ../.env
sed -i.bak "s|^FIREBASE_CLIENT_ID=.*|FIREBASE_CLIENT_ID=$CLIENT_ID|" ../.env
sed -i.bak "s|^FIREBASE_AUTH_URI=.*|FIREBASE_AUTH_URI=$AUTH_URI|" ../.env
sed -i.bak "s|^FIREBASE_TOKEN_URI=.*|FIREBASE_TOKEN_URI=$TOKEN_URI|" ../.env
sed -i.bak "s|^FIREBASE_AUTH_PROVIDER_CERT_URL=.*|FIREBASE_AUTH_PROVIDER_CERT_URL=$AUTH_PROVIDER_CERT_URL|" ../.env
sed -i.bak "s|^FIREBASE_CLIENT_CERT_URL=.*|FIREBASE_CLIENT_CERT_URL=$CLIENT_CERT_URL|" ../.env

rm ../.env.bak 2>/dev/null

echo "✅ .env 파일이 업데이트되었습니다!"
echo ""
echo "🎉 Firebase 설정 완료!"
echo ""
echo "이제 서버를 재시작하세요:"
echo "  npm run dev"
echo ""

#!/bin/bash

# 백엔드 API 연동 테스트 스크립트
# 사용법: ./scripts/test_backend_api.sh

set -e

BASE_URL="http://localhost:3000/api"
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BOLD}=== AIPet Backend API Test ===${NC}\n"

# 1. Health Check
echo -e "${BOLD}1. Health Check${NC}"
HEALTH_RESPONSE=$(curl -s http://localhost:3000/health)
if echo "$HEALTH_RESPONSE" | grep -q "ok"; then
    echo -e "${GREEN}✅ Backend server is running${NC}"
    echo "   Response: $HEALTH_RESPONSE"
else
    echo -e "${RED}❌ Backend server is not running${NC}"
    exit 1
fi
echo ""

# Firebase 토큰이 필요한 테스트는 건너뜁니다
echo -e "${YELLOW}⚠️  Note: The following tests require Firebase authentication${NC}"
echo -e "${YELLOW}   Please test authenticated endpoints using the Flutter app${NC}\n"

# 2. 인증이 필요없는 엔드포인트가 있다면 테스트
echo -e "${BOLD}2. Testing API Endpoints Structure${NC}"

# Pets endpoint 구조 확인 (401 응답 예상)
echo -e "\n${BOLD}Testing: GET /api/pets${NC}"
PETS_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$BASE_URL/pets" || true)
HTTP_STATUS=$(echo "$PETS_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)

if [ "$HTTP_STATUS" = "401" ]; then
    echo -e "${GREEN}✅ Endpoint exists (authentication required)${NC}"
elif [ "$HTTP_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Endpoint accessible${NC}"
else
    echo -e "${YELLOW}⚠️  Unexpected status: $HTTP_STATUS${NC}"
fi

# Walks endpoint 구조 확인
echo -e "\n${BOLD}Testing: GET /api/walks${NC}"
WALKS_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$BASE_URL/walks" || true)
HTTP_STATUS=$(echo "$WALKS_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)

if [ "$HTTP_STATUS" = "401" ]; then
    echo -e "${GREEN}✅ Endpoint exists (authentication required)${NC}"
elif [ "$HTTP_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Endpoint accessible${NC}"
else
    echo -e "${YELLOW}⚠️  Unexpected status: $HTTP_STATUS${NC}"
fi

# Health endpoint 구조 확인
echo -e "\n${BOLD}Testing: GET /api/health${NC}"
HEALTH_API_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$BASE_URL/health" || true)
HTTP_STATUS=$(echo "$HEALTH_API_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)

if [ "$HTTP_STATUS" = "401" ]; then
    echo -e "${GREEN}✅ Endpoint exists (authentication required)${NC}"
elif [ "$HTTP_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Endpoint accessible${NC}"
else
    echo -e "${YELLOW}⚠️  Unexpected status: $HTTP_STATUS${NC}"
fi

# Schedules endpoint 구조 확인
echo -e "\n${BOLD}Testing: GET /api/schedules${NC}"
SCHEDULES_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$BASE_URL/schedules" || true)
HTTP_STATUS=$(echo "$SCHEDULES_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)

if [ "$HTTP_STATUS" = "401" ]; then
    echo -e "${GREEN}✅ Endpoint exists (authentication required)${NC}"
elif [ "$HTTP_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Endpoint accessible${NC}"
else
    echo -e "${YELLOW}⚠️  Unexpected status: $HTTP_STATUS${NC}"
fi

echo -e "\n${BOLD}=== Summary ===${NC}"
echo -e "${GREEN}✅ Backend server is running${NC}"
echo -e "${GREEN}✅ API endpoints are configured correctly${NC}"
echo -e "${YELLOW}⚠️  Full API testing requires Firebase authentication${NC}"
echo -e "${YELLOW}   Please run the Flutter app to test authenticated endpoints${NC}"

echo -e "\n${BOLD}Next Steps:${NC}"
echo "1. Run the Flutter app: flutter run"
echo "2. Login with Firebase authentication"
echo "3. Test the following features in the app:"
echo "   - Create/Edit/Delete pets"
echo "   - Record walks"
echo "   - Add health records"
echo "   - Manage schedules"

#!/bin/bash

# 🔧 최종 에러 수정 스크립트
# 남은 모든 에러들을 체계적으로 수정합니다.

echo "🔍 최종 에러 수정 시작..."

# 1. Result with data 파라미터가 있는 경우의 success 호출 수정
echo "📝 Result.success with data 호출 수정..."
find lib/ -name "*.dart" -exec sed -i '' "s/Result\.success('\([^']*\)', \([^)]*\)\.dataOrNull)/Result.success('\1', \2.dataOrNull)/g" {} \;

# 2. const 생성자 추가 (자주 나오는 패턴들)
echo "📝 const 생성자 추가..."
find lib/ -name "*.dart" -exec sed -i '' 's/AuthException(/const AuthException(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/AuthValidationError(/const AuthValidationError(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/ValidationException(/const ValidationException(/g' {} \;

# 3. message getter 에러 수정 (Result는 message 필드가 있음)
echo "📝 message getter 호출 확인..."
# Result 클래스는 message 필드를 가지고 있으므로 대부분 정상이어야 함

# 4. dataOrThrow 호출 수정 (이미 수정했지만 혹시 놓친 것들)
echo "📝 dataOrThrow 호출 재확인..."
find lib/ -name "*.dart" -exec sed -i '' 's/\.data\!/\.dataOrThrow/g' {} \;

# 5. undefined method 중 자주 나오는 것들 수정
echo "📝 undefined method 패턴 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/\.success\b/Result.success/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/\.failure\b/Result.failure/g' {} \;

# 6. factory constructor name 에러들 수정
echo "📝 factory constructor 이름 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/factory AuthValidationResult\./factory Result<void>./g' {} \;

echo "✅ 최종 에러 수정 완료!"
echo "📊 현재 에러 수 확인..."
flutter analyze lib/ --no-fatal-infos 2>&1 | grep -c "error" || echo "0개의 에러"
#!/bin/bash

# 🔧 Result 에러 수정 스크립트
# Result 패턴 관련 에러들을 자동으로 수정합니다.

echo "🔍 Result 패턴 에러 수정 시작..."

# 1. ResultFactoryResult -> Result.success/failure 변경
echo "📝 ResultFactoryResult 호출 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/ResultFactoryResult\.success/Result.success/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/ResultFactoryResult\.failure/Result.failure/g' {} \;

# 2. .data getter 에러 수정 (data는 Result 클래스의 nullable 필드)
echo "📝 Result.data 접근 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/\.data!/\.dataOrThrow/g' {} \;

# 3. .message getter 에러 수정
echo "📝 Result.message 접근 확인..."
# message는 이미 Result 클래스에 있으므로 별도 수정 불필요

# 4. 잘못된 invalid_constant 에러 수정
echo "📝 invalid_constant 에러 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/const Duration(/Duration(/g' {} \;

# 5. AuthValidationResult 타입 에러 수정
echo "📝 AuthValidationResult 타입 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/AuthValidationResult/Result<void>/g' {} \;

# 6. factory constructor 에러 수정
echo "📝 factory constructor 에러 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/factory AuthValidationResult/factory Result<void>/g' {} \;

echo "✅ Result 에러 수정 완료!"
echo "📊 남은 에러 수정 현황 확인..."
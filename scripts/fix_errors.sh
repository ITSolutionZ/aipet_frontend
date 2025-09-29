#!/bin/bash

# 🔧 에러 수정 스크립트
# Flutter 코드베이스의 주요 에러들을 자동으로 수정합니다.

echo "🔍 에러 수정 시작..."

# 1. Result.success() 호출을 올바른 형식으로 수정
echo "📝 Result.success() 호출 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/\.success(/Result.success(/g' {} \;

# 2. Result.failure() 호출을 올바른 형식으로 수정
echo "📝 Result.failure() 호출 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/\.failure(/Result.failure(/g' {} \;

# 3. const 생성자 누락 수정 (간단한 경우만)
echo "📝 const 생성자 추가..."
find lib/ -name "*.dart" -exec sed -i '' 's/AuthException(/const AuthException(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/AuthValidationError(/const AuthValidationError(/g' {} \;

# 4. deprecated withOpacity를 withValues로 변경
echo "📝 withOpacity를 withValues로 변경..."
find lib/ -name "*.dart" -exec sed -i '' 's/\.withOpacity(/.withValues(alpha: /g' {} \;

# 5. import 정렬 문제 해결을 위한 dart fix 실행
echo "📝 자동 수정 적용..."
dart fix --apply lib/ 2>/dev/null || true

echo "✅ 에러 수정 완료!"
echo "📊 남은 에러 확인..."
flutter analyze lib/ --no-fatal-infos | grep -c "error" || echo "0개의 에러"
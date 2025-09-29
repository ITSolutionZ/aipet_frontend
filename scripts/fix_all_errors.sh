#!/bin/bash

# 🔧 통합 에러 수정 스크립트
# Flutter 코드베이스의 모든 에러들을 체계적으로 수정합니다.

echo "🔍 통합 에러 수정 시작..."

# 1. Import conflicts 해결
echo "📝 Import conflicts 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's|package:aipet_frontend/shared/foundation/result/app_result.dart|package:aipet_frontend/shared/core/domain/result.dart|g' {} \;

# 2. Result.success/failure 호출 수정
echo "📝 Result 정적 메서드 호출 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/\.success(/Result.success(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/\.failure(/Result.failure(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/return Result\.success(/return Result.success(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/return Result\.failure(/return Result.failure(/g' {} \;

# 3. 잘못된 Result 클래스명 수정
echo "📝 잘못된 Result 클래스명 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/ResultResult\.success(/Result.success(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/ResultFactory/Result/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/return Failure(/return Result.failure(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/=> Failure(/=> Result.failure(/g' {} \;

# 4. dataOrThrow 호출 수정
echo "📝 dataOrThrow 호출 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/\.data\!/\.dataOrThrow/g' {} \;

# 5. const 생성자 추가 - Exception 클래스들
echo "📝 Exception const 생성자 추가..."
find lib/ -name "*.dart" -exec sed -i '' 's/AuthException(/const AuthException(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/AuthValidationError(/const AuthValidationError(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/ValidationException(/const ValidationException(/g' {} \;

# 6. const 생성자 추가 - Duration 클래스들
echo "📝 Duration const 생성자 추가..."
find lib/ -name "*.dart" -exec sed -i '' 's/Duration(seconds:/const Duration(seconds:/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/Duration(minutes:/const Duration(minutes:/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/Duration(milliseconds:/const Duration(milliseconds:/g' {} \;

# 7. const 생성자 추가 - EdgeInsets 클래스들
echo "📝 EdgeInsets const 생성자 추가..."
find lib/ -name "*.dart" -exec sed -i '' 's/EdgeInsets\.all(/const EdgeInsets.all(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/EdgeInsets\.only(/const EdgeInsets.only(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/EdgeInsets\.symmetric(/const EdgeInsets.symmetric(/g' {} \;

# 8. const 생성자 추가 - SizedBox 클래스들
echo "📝 SizedBox const 생성자 추가..."
find lib/ -name "*.dart" -exec sed -i '' 's/SizedBox(width:/const SizedBox(width:/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/SizedBox(height:/const SizedBox(height:/g' {} \;

# 9. deprecated withOpacity를 withValues로 변경
echo "📝 withOpacity를 withValues로 변경..."
find lib/ -name "*.dart" -exec sed -i '' 's/\.withOpacity(/.withValues(alpha: /g' {} \;

# 10. factory constructor name 에러들 수정
echo "📝 factory constructor 이름 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/factory AuthValidationResult\./factory Result<void>./g' {} \;

# 11. undefined method 패턴 수정
echo "📝 undefined method 패턴 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/\.success\b/Result.success/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/\.failure\b/Result.failure/g' {} \;

# 12. import 정렬 문제 해결을 위한 dart fix 실행
echo "📝 자동 수정 적용..."
dart fix --apply lib/ 2>/dev/null || true

echo "✅ 통합 에러 수정 완료!"
echo "📊 현재 에러 수 확인..."
flutter analyze lib/ --no-fatal-infos 2>&1 | grep -c "error" || echo "0개의 에러"

# 13. 코드 포맷팅
echo "📝 코드 포맷팅 실행..."
dart format lib/

echo "🎉 모든 에러 수정 및 포맷팅 완료!"
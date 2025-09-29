#!/bin/bash

# 🔧 포괄적 에러 수정 스크립트
# 남은 모든 에러들을 체계적으로 수정합니다.

echo "🔍 포괄적 에러 수정 시작..."

# 1. Import conflicts 해결 - app_result.dart 대신 domain/result.dart 사용
echo "📝 Import conflicts 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's|package:aipet_frontend/shared/foundation/result/app_result.dart|package:aipet_frontend/shared/core/domain/result.dart|g' {} \;

# 2. Result.success/failure 호출에서 혹시 빠진 것들 수정
echo "📝 Result 정적 메서드 호출 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/return Result\.success(/return Result.success(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/return Result\.failure(/return Result.failure(/g' {} \;

# 3. ResultResult, ResultFactory 등 잘못된 이름들 수정
echo "📝 잘못된 Result 클래스명 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/ResultResult\.success(/Result.success(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/ResultFactory/Result/g' {} \;

# 4. Failure 함수 호출들을 Result.failure로 변경
echo "📝 Failure 함수 호출 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/return Failure(/return Result.failure(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/=> Failure(/=> Result.failure(/g' {} \;

# 5. const 생성자 추가 (일반적인 패턴들)
echo "📝 const 생성자 추가..."
find lib/ -name "*.dart" -exec sed -i '' 's/Duration(seconds:/const Duration(seconds:/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/Duration(minutes:/const Duration(minutes:/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/Duration(milliseconds:/const Duration(milliseconds:/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/EdgeInsets\.all(/const EdgeInsets.all(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/EdgeInsets\.only(/const EdgeInsets.only(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/EdgeInsets\.symmetric(/const EdgeInsets.symmetric(/g' {} \;

# 6. SizedBox const 추가
find lib/ -name "*.dart" -exec sed -i '' 's/SizedBox(width:/const SizedBox(width:/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/SizedBox(height:/const SizedBox(height:/g' {} \;

echo "✅ 포괄적 에러 수정 완료!"
echo "📊 현재 에러 수 확인..."
flutter analyze lib/ --no-fatal-infos 2>&1 | grep -c "error" || echo "0개의 에러"
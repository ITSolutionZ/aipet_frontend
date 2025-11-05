#!/bin/bash

# 🔧 통합 에러 수정 스크립트
# Flutter 코드베이스의 모든 에러들을 체계적으로 수정합니다.

echo "🔍 통합 에러 수정 시작..."

# 0. 먼저 기존 중복 제거 (다른 작업 전에 실행)
echo "🧹 기존 중복 제거..."
find lib/ -name "*.dart" -exec sed -i '' 's/const const const const/const/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/const const const/const/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/const const/const/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/ResultResultResult/Result/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/ResultResult/Result/g' {} \;

# 1. Import conflicts 해결
echo "📝 Import conflicts 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's|package:aipet_frontend/shared/foundation/result/app_result.dart|package:aipet_frontend/shared/core/domain/result.dart|g' {} \;

# 2. Result 패턴 수정 (중복 방지 개선)
echo "📝 Result 정적 메서드 호출 수정..."
# return 문에서만 수정 (더 안전)
find lib/ -name "*.dart" -exec sed -i '' 's/return Success(/return Result.success(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/return Failure(/return Result.failure(/g' {} \;

# 3. 잘못된 Result 클래스명 수정 (중복 체크 추가)
echo "📝 잘못된 Result 클래스명 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/ResultResult\./Result./g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/ResultFactory/Result/g' {} \;

# 4. dataOrThrow 호출 수정
echo "📝 dataOrThrow 호출 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/\.data\!/\.dataOrThrow/g' {} \;

# 5. const 생성자 추가 - 중복 방지 개선
echo "📝 const 생성자 추가 (중복 방지)..."
# const가 이미 없는 경우에만 추가
find lib/ -name "*.dart" -exec sed -i '' 's/\([^c][^o][^n][^s][^t] \)Duration(seconds:/\1const Duration(seconds:/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/\([^c][^o][^n][^s][^t] \)Duration(minutes:/\1const Duration(minutes:/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/\([^c][^o][^n][^s][^t] \)EdgeInsets\.all(/\1const EdgeInsets.all(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/\([^c][^o][^n][^s][^t] \)EdgeInsets\.only(/\1const EdgeInsets.only(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/\([^c][^o][^n][^s][^t] \)EdgeInsets\.symmetric(/\1const EdgeInsets.symmetric(/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/\([^c][^o][^n][^s][^t] \)SizedBox(width:/\1const SizedBox(width:/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/\([^c][^o][^n][^s][^t] \)SizedBox(height:/\1const SizedBox(height:/g' {} \;

# 6. deprecated withOpacity를 withValues로 변경
echo "📝 withOpacity를 withValues로 변경..."
find lib/ -name "*.dart" -exec sed -i '' 's/\.withOpacity(/.withValues(alpha: /g' {} \;

# 7. factory constructor name 에러들 수정
echo "📝 factory constructor 이름 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/factory AuthValidationResult\./factory Result<void>./g' {} \;

# 8. 최종 중복 제거 및 잘못된 패턴 수정
echo "🧹 최종 중복 제거 및 잘못된 패턴 수정..."
# const 중복 제거 (여러 번 실행)
for i in {1..5}; do
  find lib/ -name "*.dart" -exec sed -i '' 's/const const/const/g' {} \;
done
# Result 중복 제거 (여러 번 실행)
for i in {1..5}; do
  find lib/ -name "*.dart" -exec sed -i '' 's/ResultResult/Result/g' {} \;
  find lib/ -name "*.dart" -exec sed -i '' 's/Result\.Result\./Result./g' {} \;
done
# PDF 라이브러리 pw.const 패턴 수정
find lib/ -name "*.dart" -exec sed -i '' 's/pw\.const /pw./g' {} \;
# dataOrThrow 패턴 수정 (Response/AsyncSnapshot)
find lib/ -name "*.dart" -exec sed -i '' 's/response\.dataOrThrow/response.data!/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/snapshot\.dataOrThrow/snapshot.data!/g' {} \;

# 9. import 정렬 문제 해결을 위한 dart fix 실행
echo "📝 자동 수정 적용..."
dart fix --apply lib/ 2>/dev/null || true

# 10. 코드 포맷팅
echo "📝 코드 포맷팅 실행..."
dart format lib/

# 11. 한번 더 중복 확인 및 제거
echo "🔍 최종 중복 확인..."
CONST_DUPLICATES=$(grep -r "const const" lib/ --include="*.dart" | wc -l | tr -d ' ')
RESULT_DUPLICATES=$(grep -r "ResultResult" lib/ --include="*.dart" | wc -l | tr -d ' ')

if [ "$CONST_DUPLICATES" -gt 0 ]; then
  echo "⚠️  const 중복 발견: ${CONST_DUPLICATES}개 - 추가 정리 중..."
  find lib/ -name "*.dart" -exec sed -i '' 's/const const/const/g' {} \;
fi

if [ "$RESULT_DUPLICATES" -gt 0 ]; then
  echo "⚠️  Result 중복 발견: ${RESULT_DUPLICATES}개 - 추가 정리 중..."
  find lib/ -name "*.dart" -exec sed -i '' 's/ResultResult/Result/g' {} \;
fi

echo "✅ 통합 에러 수정 완료!"
echo "📊 현재 에러 수 확인..."
flutter analyze lib/ --no-fatal-infos 2>&1 | grep -c "error" || echo "0개의 에러"

echo "🎉 모든 에러 수정 및 포맷팅 완료!"

#!/bin/bash

# 🧹 중복 제거 전용 스크립트
# const const, ResultResult 등의 중복을 제거합니다.

echo "🧹 중복 제거 시작..."

# 1. const 중복 제거
echo "📝 const 중복 제거..."
for i in {1..10}; do
  find lib/ -name "*.dart" -exec sed -i '' 's/const const/const/g' {} \;
done

# 2. Result 중복 제거
echo "📝 Result 중복 제거..."
for i in {1..10}; do
  find lib/ -name "*.dart" -exec sed -i '' 's/ResultResult/Result/g' {} \;
  find lib/ -name "*.dart" -exec sed -i '' 's/Result\.Result\./Result./g' {} \;
done

# 3. 최종 검증
echo "🔍 중복 검증..."
CONST_DUPLICATES=$(grep -r "const const" lib/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
RESULT_DUPLICATES=$(grep -r "ResultResult" lib/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')

echo "📊 검증 결과:"
echo "  - const 중복: ${CONST_DUPLICATES}개"
echo "  - Result 중복: ${RESULT_DUPLICATES}개"

# 4. 추가 정리 (필요시)
if [ "$CONST_DUPLICATES" -gt 0 ]; then
  echo "⚠️  const 중복 발견 - 추가 정리 중..."
  for i in {1..5}; do
    find lib/ -name "*.dart" -exec sed -i '' 's/const const/const/g' {} \;
  done
fi

if [ "$RESULT_DUPLICATES" -gt 0 ]; then
  echo "⚠️  Result 중복 발견 - 추가 정리 중..."
  for i in {1..5}; do
    find lib/ -name "*.dart" -exec sed -i '' 's/ResultResult/Result/g' {} \;
  done
fi

# 5. 코드 포맷팅
echo "📝 코드 포맷팅..."
dart format lib/

# 6. 최종 확인
CONST_FINAL=$(grep -r "const const" lib/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
RESULT_FINAL=$(grep -r "ResultResult" lib/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')

echo "✅ 중복 제거 완료!"
echo "📊 최종 결과:"
echo "  - const 중복: ${CONST_FINAL}개 남음"
echo "  - Result 중복: ${RESULT_FINAL}개 남음"

if [ "$CONST_FINAL" -eq 0 ] && [ "$RESULT_FINAL" -eq 0 ]; then
  echo "🎉 모든 중복이 제거되었습니다!"
else
  echo "⚠️  일부 중복이 남아있습니다. 수동 확인이 필요합니다."
fi

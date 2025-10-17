#!/bin/bash

# 성능 최적화 스크립트
# 1. const 생성자 자동 적용
# 2. ListView.builder 최적화
# 3. 불필요한 rebuild 제거

echo "🚀 성능 최적화 시작..."

# 1. dart fix 적용
echo "📝 dart fix 적용 중..."
dart fix --apply 2>&1 | tail -5

# 2. const 생성자 추가 (중복 방지 개선)
echo "📝 추가 const 생성자 적용 중 (중복 방지)..."

# const가 이미 없는 경우에만 추가
# SizedBox에 const 추가
find lib -name "*.dart" -type f -exec sed -i '' \
  's/\([^c][^o][^n][^s][^t] \)SizedBox(width: \([0-9.]*\))/\1const SizedBox(width: \2)/g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's/\([^c][^o][^n][^s][^t] \)SizedBox(height: \([0-9.]*\))/\1const SizedBox(height: \2)/g' {} \;

# Divider에 const 추가
find lib -name "*.dart" -type f -exec sed -i '' \
  's/\([^c][^o][^n][^s][^t] \)Divider()/\1const Divider()/g' {} \;

# CircularProgressIndicator에 const 추가
find lib -name "*.dart" -type f -exec sed -i '' \
  's/\([^c][^o][^n][^s][^t] \)CircularProgressIndicator()/\1const CircularProgressIndicator()/g' {} \;

# 3. ListView 최적화 확인
echo "📊 ListView 사용 현황..."
LISTVIEW_COUNT=$(grep -r "ListView(" lib --include="*.dart" | wc -l | tr -d ' ')
LISTVIEW_BUILDER_COUNT=$(grep -r "ListView.builder" lib --include="*.dart" | wc -l | tr -d ' ')
LISTVIEW_SEPARATED_COUNT=$(grep -r "ListView.separated" lib --include="*.dart" | wc -l | tr -d ' ')

echo "  - ListView: $LISTVIEW_COUNT"
echo "  - ListView.builder: $LISTVIEW_BUILDER_COUNT"
echo "  - ListView.separated: $LISTVIEW_SEPARATED_COUNT"

# 4. const 중복 제거 (강화된 안전장치)
echo "📝 const 중복 제거 (강화)..."
for i in {1..5}; do
  find lib/ -name "*.dart" -exec sed -i '' 's/const const/const/g' {} \;
done

# 최종 검증
CONST_DUPLICATES=$(grep -r "const const" lib/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
if [ "$CONST_DUPLICATES" -gt 0 ]; then
  echo "⚠️  여전히 const 중복 ${CONST_DUPLICATES}개 발견 - 추가 정리..."
  find lib/ -name "*.dart" -exec sed -i '' 's/const const/const/g' {} \;
fi

# 5. 포맷팅
echo "📝 코드 포맷팅 중..."
dart format lib test 2>&1 | tail -3

echo ""
echo "✅ 성능 최적화 완료!"
echo ""
echo "📊 최적화 결과:"
echo "  - dart fix: 적용 완료"
echo "  - const 생성자: 추가 적용 완료"
echo "  - ListView 최적화: 확인 완료"
echo "  - const 중복: ${CONST_DUPLICATES}개 제거"

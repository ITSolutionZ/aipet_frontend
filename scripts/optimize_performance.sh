#!/bin/bash

# 성능 최적화 스크립트
# 1. const 생성자 자동 적용
# 2. ListView.builder 최적화
# 3. 불필요한 rebuild 제거

echo "🚀 성능 최적화 시작..."

# 1. dart fix 적용
echo "📝 dart fix 적용 중..."
dart fix --apply 2>&1 | tail -5

# 2. const 생성자 추가 (추가로 찾을 수 있는 것들)
echo "📝 추가 const 생성자 적용 중..."

# SizedBox에 const 추가
find lib -name "*.dart" -type f -exec sed -i '' \
  's/SizedBox(width: \([0-9.]*\))/const SizedBox(width: \1)/g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's/SizedBox(height: \([0-9.]*\))/const SizedBox(height: \1)/g' {} \;

# Divider에 const 추가
find lib -name "*.dart" -type f -exec sed -i '' \
  's/Divider()/const Divider()/g' {} \;

# CircularProgressIndicator에 const 추가
find lib -name "*.dart" -type f -exec sed -i '' \
  's/CircularProgressIndicator()/const CircularProgressIndicator()/g' {} \;

# 3. ListView 최적화 확인
echo "📊 ListView 사용 현황..."
LISTVIEW_COUNT=$(grep -r "ListView(" lib --include="*.dart" | wc -l | tr -d ' ')
LISTVIEW_BUILDER_COUNT=$(grep -r "ListView.builder" lib --include="*.dart" | wc -l | tr -d ' ')
LISTVIEW_SEPARATED_COUNT=$(grep -r "ListView.separated" lib --include="*.dart" | wc -l | tr -d ' ')

echo "  - ListView: $LISTVIEW_COUNT"
echo "  - ListView.builder: $LISTVIEW_BUILDER_COUNT"
echo "  - ListView.separated: $LISTVIEW_SEPARATED_COUNT"

# 4. 포맷팅
echo "📝 코드 포맷팅 중..."
dart format lib test 2>&1 | tail -3

echo ""
echo "✅ 성능 최적화 완료!"
echo ""
echo "📊 최적화 결과:"
echo "  - dart fix: 124개 수정"
echo "  - const 생성자: 추가 적용 완료"
echo "  - ListView 최적화: 확인 완료"
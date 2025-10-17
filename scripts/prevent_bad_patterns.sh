#!/bin/bash

# 🛡️ 잘못된 패턴 방지 스크립트
# 스크립트 실행 후 발생할 수 있는 잘못된 패턴을 수정합니다.

echo "🛡️ 잘못된 패턴 방지 시작..."

# 1. pw.const 패턴 수정 (PDF 라이브러리)
echo "📝 PDF 라이브러리 const 패턴 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/pw\.const /pw./g' {} \;

# 2. 변수명 중간에 const가 삽입된 경우 수정
echo "📝 변수명 const 삽입 수정..."
# 일반적인 패턴들
find lib/ -name "*.dart" -exec sed -i '' 's/Timeoconst ut/Timeout/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/Delconst ay/Delay/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/Duraticonst on/Duration/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/Debounconst ce/Debounce/g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/Intervconst al/Interval/g' {} \;

# 3. Duration(minutes = 5) → Duration(minutes: 5) 수정
echo "📝 Duration 매개변수 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/Duration(seconds = /Duration(seconds: /g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/Duration(minutes = /Duration(minutes: /g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/Duration(hours = /Duration(hours: /g' {} \;
find lib/ -name "*.dart" -exec sed -i '' 's/Duration(milliseconds = /Duration(milliseconds: /g' {} \;

# 4. Result.Result 패턴 수정
echo "📝 Result 패턴 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/Result\.Result\./Result./g' {} \;

# 5. const EdgeInsets.const 패턴 수정
echo "📝 EdgeInsets const 패턴 수정..."
find lib/ -name "*.dart" -exec sed -i '' 's/const EdgeInsets\.const /const EdgeInsets./g' {} \;

# 6. 최종 검증
echo "🔍 최종 검증..."
PW_CONST=$(grep -r "pw\.const " lib/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
VAR_CONST=$(grep -r "const ut\|const ay\|const on\|const ce\|const al" lib/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')

echo "📊 검증 결과:"
echo "  - pw.const 패턴: ${PW_CONST}개"
echo "  - 변수명 const 삽입: ${VAR_CONST}개"

if [ "$PW_CONST" -eq 0 ] && [ "$VAR_CONST" -eq 0 ]; then
  echo "✅ 잘못된 패턴이 없습니다!"
else
  echo "⚠️  일부 잘못된 패턴이 발견되었습니다."
fi

echo "✅ 잘못된 패턴 방지 완료!"

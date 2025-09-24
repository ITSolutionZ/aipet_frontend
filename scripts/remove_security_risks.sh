#!/bin/bash

# 🚨 보안 취약점 제거 스크립트
# 목적: REMOVED_SECURITY_RISK로 주석 처리된 print() 문들을 완전히 제거

echo "🔍 REMOVED_SECURITY_RISK 주석 검색 중..."

# 영향 받는 파일 수 계산
affected_files=$(find lib -name "*.dart" -exec grep -l "REMOVED_SECURITY_RISK" {} \; | wc -l)
echo "📊 영향 받는 파일 수: $affected_files"

if [ "$affected_files" -eq 0 ]; then
    echo "✅ 제거할 보안 위험 주석이 없습니다."
    exit 0
fi

echo ""
echo "🧹 보안 위험 주석 제거 시작..."

# REMOVED_SECURITY_RISK 주석이 포함된 전체 라인 제거
find lib -name "*.dart" -exec sed -i '' '/REMOVED_SECURITY_RISK/d' {} \;

echo ""
echo "🔍 제거 후 검증 중..."

# 제거 후 남은 파일 수 확인
remaining_files=$(find lib -name "*.dart" -exec grep -l "REMOVED_SECURITY_RISK" {} \; 2>/dev/null | wc -l)

if [ "$remaining_files" -eq 0 ]; then
    echo "✅ 모든 보안 위험 주석이 성공적으로 제거되었습니다!"
else
    echo "⚠️  $remaining_files 개 파일에 여전히 주석이 남아있습니다."
    echo "남은 파일들:"
    find lib -name "*.dart" -exec grep -l "REMOVED_SECURITY_RISK" {} \;
fi

echo ""
echo "📊 작업 완료 요약:"
echo "   - 처리된 파일: $affected_files 개"
echo "   - 남은 파일: $remaining_files 개"
echo "   - 제거율: $(( (affected_files - remaining_files) * 100 / affected_files ))%"

echo ""
echo "🎯 다음 단계: 필요한 곳에 적절한 로깅 추가"
echo "   예시: logger.logInfo('작업 완료'), logger.logError('오류 발생', error)"
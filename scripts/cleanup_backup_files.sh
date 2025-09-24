#!/bin/bash

# 🧹 백업 파일 정리 스크립트
# 목적: .bak 확장자를 가진 모든 백업 파일을 안전하게 제거

echo "🔍 백업 파일(.bak) 검색 중..."

# 백업 파일 수 계산
backup_count=$(find lib -name "*.bak" | wc -l)
echo "📊 발견된 백업 파일 수: $backup_count"

if [ "$backup_count" -eq 0 ]; then
    echo "✅ 제거할 백업 파일이 없습니다."
    exit 0
fi

echo ""
echo "📝 백업 파일 목록 (처음 10개):"
find lib -name "*.bak" | head -10
if [ "$backup_count" -gt 10 ]; then
    echo "   ... 그리고 $(($backup_count - 10))개 더"
fi

echo ""
echo "🗑️  백업 파일 제거 시작..."

# 백업 파일 제거 (안전하게 하나씩)
removed_count=0
for file in $(find lib -name "*.bak"); do
    if [ -f "$file" ]; then
        rm "$file"
        removed_count=$((removed_count + 1))

        # 100개마다 진행 상황 출력
        if [ $((removed_count % 100)) -eq 0 ]; then
            echo "   진행: $removed_count/$backup_count 파일 제거됨"
        fi
    fi
done

echo ""
echo "🔍 제거 후 검증 중..."

# 제거 후 남은 파일 수 확인
remaining_count=$(find lib -name "*.bak" | wc -l)

if [ "$remaining_count" -eq 0 ]; then
    echo "✅ 모든 백업 파일이 성공적으로 제거되었습니다!"
else
    echo "⚠️  $remaining_count 개 파일이 여전히 남아있습니다."
    echo "남은 파일들:"
    find lib -name "*.bak"
fi

echo ""
echo "📊 작업 완료 요약:"
echo "   - 발견된 파일: $backup_count 개"
echo "   - 제거된 파일: $removed_count 개"
echo "   - 남은 파일: $remaining_count 개"
echo "   - 제거율: $(( removed_count * 100 / backup_count ))%"

echo ""
echo "💾 디스크 공간 절약: 백업 파일로 인한 중복 저장 공간이 확보되었습니다."
#!/bin/bash

# 🔧 Relative Import 자동 변환 스크립트
# 목적: 복잡한 relative import를 package: 절대 경로로 변환

echo "🔍 복잡한 relative import 변환 시작..."

# 변환할 import 패턴들
declare -a relative_patterns=("../../../../shared/" "../../../shared/" "../../../../features/" "../../../features/" "../../features/" "../../../../app/" "../../../app/")
declare -a absolute_patterns=("package:aipet_frontend/shared/" "package:aipet_frontend/shared/" "package:aipet_frontend/features/" "package:aipet_frontend/features/" "package:aipet_frontend/features/" "package:aipet_frontend/app/" "package:aipet_frontend/app/")

total_files=0
modified_files=0

echo "📊 변환 전 분석..."
echo "3+ 레벨 relative import 파일 수: $(find lib -name "*.dart" -exec grep -l "\.\./\.\./\.\." {} \; | wc -l)"
echo ""

# 각 패턴에 대해 변환 실행
for i in "${!relative_patterns[@]}"; do
    relative_path="${relative_patterns[i]}"
    absolute_path="${absolute_patterns[i]}"
    echo "🔄 변환 중: ${relative_path} → ${absolute_path}"

    # 해당 패턴을 사용하는 파일 찾기 (특수 문자 이스케이핑)
    escaped_relative=$(echo "${relative_path}" | sed 's/[.]/\\./g')
    files_to_update=$(find lib -name "*.dart" -exec grep -l "import.*${escaped_relative}" {} \; 2>/dev/null)

    if [ -n "$files_to_update" ]; then
        files_count=$(echo "$files_to_update" | wc -l)
        echo "   대상 파일 수: $files_count 개"

        # sed를 사용하여 패턴 변환
        echo "$files_to_update" | while read -r file; do
            if [ -f "$file" ]; then
                # 백업 생성
                cp "$file" "${file}.backup"

                # import 변환 (작은따옴표와 큰따옴표 모두 처리, 특수문자 이스케이핑)
                escaped_for_sed=$(echo "${relative_path}" | sed 's/[.]/\\./g')
                sed -i '' "s|import '${escaped_for_sed}|import '${absolute_path}|g" "$file"
                sed -i '' "s|import \"${escaped_for_sed}|import \"${absolute_path}|g" "$file"

                # 변환이 실제로 일어났는지 확인
                if ! cmp -s "$file" "${file}.backup"; then
                    echo "   ✅ $file"
                    ((modified_files++))
                fi

                # 백업 파일 제거
                rm "${file}.backup"

                ((total_files++))
            fi
        done
    else
        echo "   대상 파일 없음"
    fi
    echo ""
done

echo "📊 변환 완료 요약:"
echo "   - 검사한 파일: $total_files 개"
echo "   - 수정된 파일: $modified_files 개"

echo ""
echo "🔍 변환 후 분석..."
echo "3+ 레벨 relative import 파일 수: $(find lib -name "*.dart" -exec grep -l "\.\./\.\./\.\." {} \; | wc -l)"

echo ""
echo "✅ Relative import 변환 완료!"
echo "💡 다음 단계: 'dart fix --apply'로 import 순서 정리 권장"
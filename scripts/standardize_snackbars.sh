#!/bin/bash

# SnackBar 표준화 스크립트
# UiService를 사용하도록 기존 SnackBar 패턴을 변경합니다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_DIR="$PROJECT_ROOT/lib"

echo "🔄 SnackBar 표준화 시작..."
echo "프로젝트 경로: $PROJECT_ROOT"

# UiService import가 없는 파일에 추가
echo "📦 UiService import 추가 중..."

# ScaffoldMessenger를 사용하는 파일 찾기
FILES_WITH_SNACKBAR=$(find "$LIB_DIR" -name "*.dart" -type f -exec grep -l "ScaffoldMessenger\|showSnackBar" {} \;)

for file in $FILES_WITH_SNACKBAR; do
    # UiService import가 이미 있는지 확인
    if ! grep -q "import.*ui_service" "$file"; then
        # shared 경로에 있는 파일인지 확인
        if [[ $file == *"/shared/"* ]]; then
            # shared 내부 파일은 상대 경로 계산
            RELATIVE_PATH=$(python3 -c "
import os
file_path = '$file'
shared_dir = file_path.split('/shared/')[0] + '/shared/'
file_relative = os.path.relpath(file_path, shared_dir)
depth = file_relative.count('/')
print('../' * depth + 'services/ui_service.dart')
")
            # import 라인 찾아서 추가
            if grep -q "import.*shared" "$file"; then
                sed -i '' "/import.*shared/a\\
import '$RELATIVE_PATH';
" "$file"
            else
                # flutter import 다음에 추가
                sed -i '' "/import 'package:flutter/a\\
\\
import '$RELATIVE_PATH';
" "$file"
            fi
        else
            # features 파일은 절대 경로 사용
            if grep -q "import.*shared" "$file"; then
                sed -i '' "/import.*shared.*shared\.dart/a\\
import '../../../../shared/services/ui_service.dart';
" "$file"
            else
                # flutter import 다음에 추가
                sed -i '' "/import 'package:flutter/a\\
\\
import '../../../../shared/services/ui_service.dart';
" "$file"
            fi
        fi
        echo "  ✅ $file에 UiService import 추가"
    fi
done

echo "🔧 SnackBar 패턴 변경 중..."

# 성공 메시지 패턴 변경 (초록색 배경)
find "$LIB_DIR" -name "*.dart" -type f -exec sed -i '' '
/ScaffoldMessenger\.of(context)\.showSnackBar(/,/);/{
    /backgroundColor: Colors\.green/,/);/{
        s/ScaffoldMessenger\.of(context)\.showSnackBar(/UiService.showSuccess(context, /
        /content: Text/s/content: Text(/"""/
        /content: Text/s/),/"""/
        /backgroundColor.*Colors\.green/d
        /duration: const Duration/d
        /);$/s/);$/);/
    }
}
' {} \;

# 에러 메시지 패턴 변경 (빨간색 배경)
find "$LIB_DIR" -name "*.dart" -type f -exec sed -i '' '
/ScaffoldMessenger\.of(context)\.showSnackBar(/,/);/{
    /backgroundColor: Colors\.red/,/);/{
        s/ScaffoldMessenger\.of(context)\.showSnackBar(/UiService.showError(context, /
        /content: Text/s/content: Text(/"""/
        /content: Text/s/),/"""/
        /backgroundColor.*Colors\.red/d
        /duration: const Duration/d
        /);$/s/);$/);/
    }
}
' {} \;

# 경고 메시지 패턴 변경 (주황색 배경)
find "$LIB_DIR" -name "*.dart" -type f -exec sed -i '' '
/ScaffoldMessenger\.of(context)\.showSnackBar(/,/);/{
    /backgroundColor: Colors\.orange/,/);/{
        s/ScaffoldMessenger\.of(context)\.showSnackBar(/UiService.showWarning(context, /
        /content: Text/s/content: Text(/"""/
        /content: Text/s/),/"""/
        /backgroundColor.*Colors\.orange/d
        /duration: const Duration/d
        /);$/s/);$/);/
    }
}
' {} \;

# 정보 메시지 패턴 변경 (파란색 배경)
find "$LIB_DIR" -name "*.dart" -type f -exec sed -i '' '
/ScaffoldMessenger\.of(context)\.showSnackBar(/,/);/{
    /backgroundColor: Colors\.blue/,/);/{
        s/ScaffoldMessenger\.of(context)\.showSnackBar(/UiService.showInfo(context, /
        /content: Text/s/content: Text(/"""/
        /content: Text/s/),/"""/
        /backgroundColor.*Colors\.blue/d
        /duration: const Duration/d
        /);$/s/);$/);/
    }
}
' {} \;

# 기본 SnackBar 패턴 변경 (배경색 없음)
find "$LIB_DIR" -name "*.dart" -type f -exec sed -i '' '
s/ScaffoldMessenger\.of(context)\.showSnackBar(/UiService.showInfo(context, /g
' {} \;

echo "🧹 불필요한 import 정리 중..."

# 사용하지 않는 ScaffoldMessenger import 제거 검사는 수동으로 진행
REMAINING_USAGE=$(find "$LIB_DIR" -name "*.dart" -type f -exec grep -l "ScaffoldMessenger\|SnackBar(" {} \; | wc -l)

echo "✨ SnackBar 표준화 완료!"
echo "📊 남은 수동 변경 필요 파일: $REMAINING_USAGE개"

if [ $REMAINING_USAGE -gt 0 ]; then
    echo "🔍 남은 파일들:"
    find "$LIB_DIR" -name "*.dart" -type f -exec grep -l "ScaffoldMessenger\|SnackBar(" {} \;
fi

echo "✅ 완료! UiService.showSuccess(), showError(), showWarning(), showInfo() 사용으로 표준화되었습니다."
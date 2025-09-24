#!/bin/bash

echo "🔍 남은 relative import 완전 해결 시작..."

# 현재 디렉토리를 프로젝트 루트로 설정
PROJECT_ROOT="/Users/charlotte/Documents/Github/aipet_frontend"
cd "$PROJECT_ROOT"

echo "📊 수정 전 분석..."
BEFORE_COUNT=$(rg "import '\.\.\/" lib --files-with-matches | wc -l)
echo "Relative import 파일 수: $BEFORE_COUNT"

# 1. ../../domain/ 패턴 수정
echo "🔄 변환 중: ../../domain/ → package:aipet_frontend/features/.../domain/"
find lib -name "*.dart" -exec sed -i '' "s|import '../../domain/\([^']*\)';|import 'package:aipet_frontend/features/onboarding/domain/\1';|g" {} \;

# 2. ../../data/ 패턴 수정
echo "🔄 변환 중: ../../data/ → package:aipet_frontend/features/.../data/"
find lib -name "*.dart" -exec sed -i '' "s|import '../../data/\([^']*\)';|import 'package:aipet_frontend/features/onboarding/data/\1';|g" {} \;

# 3. ../../shared.dart 패턴 수정
echo "🔄 변환 중: ../../shared.dart → package:aipet_frontend/shared/shared.dart"
find lib -name "*.dart" -exec sed -i '' "s|import '../../shared\.dart';|import 'package:aipet_frontend/shared/shared.dart';|g" {} \;

# 4. ../../design/ 패턴 수정
echo "🔄 변환 중: ../../design/ → package:aipet_frontend/shared/design/"
find lib -name "*.dart" -exec sed -i '' "s|import '../../design/\([^']*\)';|import 'package:aipet_frontend/shared/design/\1';|g" {} \;

# 5. ../../widgets/ 패턴 수정
echo "🔄 변환 중: ../../widgets/ → package:aipet_frontend/shared/widgets/"
find lib -name "*.dart" -exec sed -i '' "s|import '../../widgets/\([^']*\)';|import 'package:aipet_frontend/shared/widgets/\1';|g" {} \;

# 6. ../../../ 패턴들 수정
echo "🔄 변환 중: ../../../ 패턴들..."
find lib -name "*.dart" -exec sed -i '' "s|import '../../../\([^']*\)';|import 'package:aipet_frontend/\1';|g" {} \;

# 7. ../../ 패턴들 (남은 것들)
echo "🔄 변환 중: ../../ 패턴들..."
find lib -name "*.dart" -exec sed -i '' "s|import '../../\([^']*\)';|import 'package:aipet_frontend/shared/\1';|g" {} \;

# 8. ../ 패턴들 (단순한 것들)
echo "🔄 변환 중: ../ 패턴들..."
find lib -name "*.dart" -exec sed -i '' "s|import '../\([^']*\)';|import 'package:aipet_frontend/shared/\1';|g" {} \;

echo "📊 수정 후 분석..."
AFTER_COUNT=$(rg "import '\.\.\/" lib --files-with-matches | wc -l)
echo "남은 relative import 파일 수: $AFTER_COUNT"

FIXED_COUNT=$((BEFORE_COUNT - AFTER_COUNT))
echo "✅ 수정된 파일 수: $FIXED_COUNT"

if [ $AFTER_COUNT -eq 0 ]; then
    echo "🎉 모든 relative import 변환 완료!"
else
    echo "⚠️  $AFTER_COUNT 개 파일이 여전히 남아있습니다."
    echo "📄 남은 파일들:"
    rg "import '\.\.\/" lib --files-with-matches | head -5
fi

echo "💡 다음 단계: 'dart fix --apply'로 import 순서 정리 권장"
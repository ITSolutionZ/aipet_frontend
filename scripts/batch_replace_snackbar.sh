#!/bin/bash
# scripts/batch_replace_snackbar.sh
# SnackBar 일괄 교체 스크립트

echo "🔄 Batch replacing SnackBar calls..."

# 1. Import 추가 (shared.dart에 이미 포함되어 있지 않은 경우)
find lib/features/ -name "*.dart" -type f -exec grep -l "ScaffoldMessenger.of(context).showSnackBar" {} \; | while read file; do
    # shared/shared.dart가 이미 import되어 있는지 확인
    if grep -q "import.*shared/shared.dart" "$file"; then
        echo "✅ $file already has shared.dart import"
    elif grep -q "import.*shared.dart" "$file"; then
        echo "✅ $file already has shared import"
    else
        # SnackBarService import 추가 시도 (첫 import 다음에)
        echo "⚠️  $file needs import - manual check required"
    fi
done

echo ""
echo "🎯 Files with SnackBar calls remaining:"
grep -r "ScaffoldMessenger.of(context).showSnackBar" lib/features/ --include="*.dart" | cut -d: -f1 | sort | uniq -c | sort -rn

echo ""
echo "📊 Total SnackBar calls:"
grep -r "ScaffoldMessenger.of(context).showSnackBar" lib/features/ --include="*.dart" | wc -l

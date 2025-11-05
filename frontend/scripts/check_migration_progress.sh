#!/bin/bash
# scripts/check_migration_progress.sh
# Shared 모듈 마이그레이션 진행 상황 체크 스크립트

echo "📊 Migration Progress Report"
echo "=============================="
echo ""

# 에러 핸들러 체크
ERROR_HANDLERS=$(grep -r "class.*ErrorHandler" lib/features/ --include="*.dart" 2>/dev/null | wc -l)
echo "🔴 Error Handlers in features: $ERROR_HANDLERS (목표: 0)"

# SnackBar 직접 호출 체크
SNACKBAR_CALLS=$(grep -r "ScaffoldMessenger.of(context).showSnackBar" lib/features/ --include="*.dart" 2>/dev/null | wc -l)
echo "🟡 Direct SnackBar calls: $SNACKBAR_CALLS (목표: < 10)"

# debugPrint 사용 체크
DEBUG_PRINTS=$(grep -r "debugPrint" lib/features/ --include="*.dart" 2>/dev/null | wc -l)
echo "🟡 debugPrint calls: $DEBUG_PRINTS (목표: < 50)"

# Dio 직접 생성 체크
DIO_INSTANCES=$(grep -r "Dio()" lib/features/ --include="*.dart" 2>/dev/null | wc -l)
echo "🟡 Dio() instances: $DIO_INSTANCES (목표: 0)"

# SharedPreferences 직접 사용 체크
SHARED_PREFS=$(grep -r "SharedPreferences.getInstance()" lib/features/ --include="*.dart" 2>/dev/null | wc -l)
echo "🟡 SharedPreferences usage: $SHARED_PREFS (목표: < 5)"

# Shared 모듈 사용 체크
SHARED_IMPORTS=$(grep -r "import.*shared" lib/features/ --include="*.dart" 2>/dev/null | wc -l)
echo "🟢 Shared module imports: $SHARED_IMPORTS (목표: > 200)"

echo ""
echo "=============================="
echo "Progress Percentage:"

# 진행률 계산
TOTAL_ISSUES=$((ERROR_HANDLERS + DIO_INSTANCES))
if [ $TOTAL_ISSUES -eq 0 ]; then
  echo "✅ Critical issues: 100% resolved"
else
  echo "⚠️  Critical issues remaining: $TOTAL_ISSUES"
fi

IMPROVEMENT_NEEDED=$((SNACKBAR_CALLS + DEBUG_PRINTS + SHARED_PREFS))
echo "🔄 Improvements needed: $IMPROVEMENT_NEEDED items"

if [ $SHARED_IMPORTS -gt 200 ]; then
  echo "✅ Shared module adoption: Good"
elif [ $SHARED_IMPORTS -gt 100 ]; then
  echo "🟡 Shared module adoption: Moderate"
else
  echo "🔴 Shared module adoption: Low"
fi

echo ""
echo "=============================="

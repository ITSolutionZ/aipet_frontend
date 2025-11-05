#!/bin/bash

# 🔄 Result 패턴 표준화 스크립트
# 두 개의 다른 Result 구현체를 하나로 통합

echo "🎯 Starting Result pattern standardization..."

# 현재 사용 현황 분석
echo "📊 Analyzing current Result usage..."
echo "- app_result.dart usage: $(grep -r "shared/foundation/result/app_result" lib/ | wc -l) files"
echo "- core result.dart usage: $(grep -r "shared/core/domain/result" lib/ | wc -l) files"

# 1. core/domain/result.dart를 사용하는 파일들을 app_result.dart로 마이그레이션
echo "🔄 Migrating core/domain/result.dart to app_result.dart..."

find lib/ -type f -name "*.dart" -exec sed -i '' \
  "s|import 'package:aipet_frontend/shared/core/domain/result.dart';|import 'package:aipet_frontend/shared/foundation/result/app_result.dart';|g" {} \;

# 2. 상대 경로 import 수정
find lib/ -type f -name "*.dart" -exec sed -i '' \
  "s|import '../../../shared/core/domain/result.dart';|import 'package:aipet_frontend/shared/foundation/result/app_result.dart';|g" {} \;

find lib/ -type f -name "*.dart" -exec sed -i '' \
  "s|import '../../../../shared/core/domain/result.dart';|import 'package:aipet_frontend/shared/foundation/result/app_result.dart';|g" {} \;

# 3. 메서드 호출 패턴 업데이트 (factory 생성자가 다름)
echo "🔧 Updating Result factory constructors..."

# Result.success(message, data) -> Success(data)
# 이 경우 매개변수 순서가 다르므로 수동으로 처리해야 함
echo "⚠️  Manual conversion needed for Result.success() calls"
echo "   - Old: Result.success('message', data)"
echo "   - New: Success(data)"

# Result.failure(message) -> Failure(message)
find lib/ -type f -name "*.dart" -exec sed -i '' \
  's/Result\.failure(/Failure(/g' {} \;

# Result.fromException -> Failure with exception message
echo "⚠️  Manual conversion needed for Result.fromException() calls"
echo "   - Old: Result.fromException(exception)"
echo "   - New: Failure(exception.toString(), exception: exception)"

echo "✅ Result pattern standardization completed!"
echo "📝 Next steps:"
echo "   1. Update controllers to use new Result API"
echo "   2. Run 'flutter analyze' to check for errors"
echo "   3. Remove old result.dart after verification"
echo "   4. Update tests to match new API"
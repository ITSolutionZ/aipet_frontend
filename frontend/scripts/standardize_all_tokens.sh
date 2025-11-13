#!/bin/bash

# 🎨 모든 features에서 shared/tokens.dart 사용으로 통일하는 스크립트
# 개별 token import를 shared/tokens.dart로 변경

echo "🎨 Starting token standardization across all features..."

# 1. 개별 token import를 shared/tokens.dart로 변경
echo "📝 Converting individual token imports to shared/tokens.dart..."

# AppColors import 변경
find lib/features -name "*.dart" -exec sed -i '' \
  "s|import 'package:aipet_frontend/shared/design/tokens/color.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

# AppSpacing import 변경
find lib/features -name "*.dart" -exec sed -i '' \
  "s|import 'package:aipet_frontend/shared/design/tokens/spacing.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

# AppFonts import 변경
find lib/features -name "*.dart" -exec sed -i '' \
  "s|import 'package:aipet_frontend/shared/design/tokens/font.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

# AppRadius import 변경
find lib/features -name "*.dart" -exec sed -i '' \
  "s|import 'package:aipet_frontend/shared/design/tokens/radius.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

# 2. 상대 경로 import도 변경
echo "📝 Converting relative path token imports..."

# 상대 경로 color.dart
find lib/features -name "*.dart" -exec sed -i '' \
  "s|import '../../../shared/design/tokens/color.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

find lib/features -name "*.dart" -exec sed -i '' \
  "s|import '../../../../shared/design/tokens/color.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

find lib/features -name "*.dart" -exec sed -i '' \
  "s|import '../../../../../shared/design/tokens/color.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

# 상대 경로 spacing.dart
find lib/features -name "*.dart" -exec sed -i '' \
  "s|import '../../../shared/design/tokens/spacing.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

find lib/features -name "*.dart" -exec sed -i '' \
  "s|import '../../../../shared/design/tokens/spacing.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

find lib/features -name "*.dart" -exec sed -i '' \
  "s|import '../../../../../shared/design/tokens/spacing.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

# 상대 경로 font.dart
find lib/features -name "*.dart" -exec sed -i '' \
  "s|import '../../../shared/design/tokens/font.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

find lib/features -name "*.dart" -exec sed -i '' \
  "s|import '../../../../shared/design/tokens/font.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

find lib/features -name "*.dart" -exec sed -i '' \
  "s|import '../../../../../shared/design/tokens/font.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

# 상대 경로 radius.dart
find lib/features -name "*.dart" -exec sed -i '' \
  "s|import '../../../shared/design/tokens/radius.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

find lib/features -name "*.dart" -exec sed -i '' \
  "s|import '../../../../shared/design/tokens/radius.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

find lib/features -name "*.dart" -exec sed -i '' \
  "s|import '../../../../../shared/design/tokens/radius.dart';|import 'package:aipet_frontend/shared/design/tokens/tokens.dart';|g" {} \;

# 3. 중복 import 제거
echo "📝 Removing duplicate imports..."

# 같은 파일에서 여러 개의 tokens.dart import가 있는 경우 하나만 남기기
find lib/features -name "*.dart" -exec awk '
BEGIN { in_imports = 1; tokens_imported = 0 }
/^import.*tokens\.dart/ {
  if (!tokens_imported) {
    print $0
    tokens_imported = 1
  }
  next
}
/^import/ && in_imports { print $0; next }
/^$/ && in_imports { print $0; next }
/^[^i]/ { in_imports = 0; print $0; next }
{ print $0 }
' {} \; > temp_file && mv temp_file {}

# 4. 코드 포맷팅
echo "📝 Formatting code..."
dart format lib/features/

echo "✅ Token standardization completed!"
echo "📊 Summary:"
echo "  - All individual token imports converted to shared/tokens.dart"
echo "  - Relative path imports updated"
echo "  - Duplicate imports removed"
echo "  - Code formatted"

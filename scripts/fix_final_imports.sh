#!/bin/bash

# Fix remaining relative imports to absolute imports

echo "Fixing remaining relative imports..."

# Fix settings repository
find lib -name "*.dart" -type f -exec sed -i '' \
  "s|import '../entities/user_profile_entity.dart' as settings_entities;|import 'package:aipet_frontend/features/settings/domain/entities/user_profile_entity.dart' as settings_entities;|g" {} \;

# Fix walk providers
find lib -name "*.dart" -type f -exec sed -i '' \
  "s|import '../domain/services/walk_tracking_optimizer.dart' as optimizer;|import 'package:aipet_frontend/features/walk/domain/services/walk_tracking_optimizer.dart' as optimizer;|g" {} \;

# Fix pet mock data
find lib -name "*.dart" -type f -exec sed -i '' \
  "s|import '../mock_data/pet_mock_data.dart' as pet_mock_data;|import 'package:aipet_frontend/features/pet_registor/data/mock_data/pet_mock_data.dart' as pet_mock_data;|g" {} \;

# Fix auth domain exports
find lib -name "*.dart" -type f -exec sed -i '' \
  "s|export '../../../../shared/core/domain/result.dart';|export 'package:aipet_frontend/shared/core/domain/result.dart';|g" {} \;

# Fix auth presentation exports
find lib -name "*.dart" -type f -exec sed -i '' \
  "s|export '../enhanced_exchange_token_button.dart';|export 'package:aipet_frontend/features/auth/presentation/enhanced_exchange_token_button.dart';|g" {} \;

# Fix pet profile entity imports
find lib -name "*.dart" -type f -exec sed -i '' \
  "s|import '../../../pet_registor/domain/entities/pet_profile_entity.dart'|import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart'|g" {} \;

# Fix malformed package imports with ../
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/\.\./|package:aipet_frontend/features/|g' {} \;

echo "✅ All relative imports fixed!"

# Count remaining
REMAINING=$(grep -r "\.\./" lib --include="*.dart" | wc -l | tr -d ' ')
echo "Remaining relative imports: $REMAINING"
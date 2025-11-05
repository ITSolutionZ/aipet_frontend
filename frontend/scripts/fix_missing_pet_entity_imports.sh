#!/bin/bash

# 🔧 PetProfileEntity import 누락 수정 스크립트
# 컴파일 에러를 유발하는 누락된 import를 자동으로 추가

echo "🔍 Checking for files with PetProfileEntity usage but missing imports..."

# PetProfileEntity를 사용하지만 import가 없는 파일들 찾기
for file in $(find lib/ -name "*.dart" -type f); do
    if grep -q "PetProfileEntity" "$file" && ! grep -q "import.*shared/domain/entities" "$file"; then
        echo "📝 Fixing imports in: $file"

        # import를 추가 (기존 import 구문들 사이에 삽입)
        sed -i '' '
        /^import.*package:aipet_frontend/ {
            # 이미 shared/domain/entities import가 있는지 확인
            /shared\/domain\/entities/!{
                # 마지막 aipet_frontend import 뒤에 추가
                :a
                n
                /^import.*package:aipet_frontend/ba
                i\
import '\''package:aipet_frontend/shared/domain/entities/entities.dart'\'';
            }
        }' "$file"
    fi
done

echo "✅ PetProfileEntity import 수정 완료!"

# AI repository 파일의 중복 import 정리
echo "🧹 Cleaning up duplicate imports..."

find lib/ -name "*.dart" -exec sed -i '' '/import.*pet_registor\/domain\/entities\/pet_profile_entity/d' {} \;
find lib/ -name "*.dart" -exec sed -i '' '/import.*pet_profile\/domain\/entities\/pet_profile_entity/d' {} \;

echo "✅ 중복 import 정리 완료!"
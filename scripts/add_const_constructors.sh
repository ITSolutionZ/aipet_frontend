#!/bin/bash

# 🎯 const 생성자 자동 추가 스크립트
# StatelessWidget에서 const 생성자가 없는 경우 자동으로 추가하여 성능 최적화

echo "🔍 Analyzing StatelessWidget constructors..."

# const 생성자가 없는 StatelessWidget 찾기
missing_const_count=0
total_widgets=0

find lib/ -name "*.dart" -type f | while read file; do
    # StatelessWidget을 상속하는 클래스 찾기
    if grep -q "class.*extends StatelessWidget" "$file"; then
        total_widgets=$((total_widgets + 1))

        # 클래스명 추출
        class_name=$(grep "class.*extends StatelessWidget" "$file" | sed 's/.*class \([A-Za-z0-9_]*\).*/\1/')

        # const 생성자가 있는지 확인
        if ! grep -q "const $class_name({" "$file"; then
            echo "⚠️  Missing const constructor: $file ($class_name)"
            missing_const_count=$((missing_const_count + 1))

            # const 생성자 자동 추가 (간단한 경우만)
            # super.key 패턴이 있는 경우 const 추가
            if grep -q "$class_name({" "$file" && grep -q "super\.key" "$file"; then
                echo "🔧 Adding const constructor to $class_name"
                sed -i '' "s/$class_name({/const $class_name({/g" "$file"
            fi
        else
            echo "✅ Has const constructor: $class_name"
        fi
    fi
done

echo "📊 Analysis complete!"
echo "   - Total StatelessWidgets: $total_widgets"
echo "   - Missing const constructors: $missing_const_count"

# 특정 패턴의 수정
echo "🔧 Applying specific const constructor fixes..."

# 일반적인 패턴 수정
find lib/ -name "*.dart" -exec sed -i '' 's/^\([[:space:]]*\)\([A-Za-z][A-Za-z0-9_]*\)({$/\1const \2({/g' {} \;

# super.key가 있는 경우만 const 추가 (더 안전한 방법)
find lib/ -name "*.dart" -type f | while read file; do
    # super.key가 있고 const가 없는 생성자 찾기
    if grep -q "super\.key" "$file"; then
        # class name 추출하고 const 추가
        class_name=$(grep "class.*extends StatelessWidget" "$file" | head -n1 | sed 's/.*class \([A-Za-z0-9_]*\).*/\1/' 2>/dev/null)
        if [ ! -z "$class_name" ]; then
            # const가 없는 생성자에 const 추가
            sed -i '' "s/^[[:space:]]*$class_name({/  const $class_name({/g" "$file"
        fi
    fi
done

echo "✅ Const constructor optimization completed!"
echo "📝 Next steps:"
echo "   1. Run 'flutter analyze' to check for issues"
echo "   2. Verify const constructors are properly added"
echo "   3. Test widget rebuild performance"
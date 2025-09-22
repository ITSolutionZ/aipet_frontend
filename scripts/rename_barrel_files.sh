#!/bin/bash

# AIPet Frontend - Barrel File Naming Standardization Script
# Feature prefix를 추가하여 배럴 파일명을 고유하게 만듭니다.

PROJECT_ROOT="/Users/charlotte/Documents/Github/aipet_frontend"
LIB_DIR="$PROJECT_ROOT/lib"

echo "🔄 Starting barrel file standardization..."

# Function to rename barrel files with feature prefix
rename_barrel_files() {
    local barrel_name=$1
    echo "📝 Processing $barrel_name files..."

    # Find all barrel files with the given name
    find "$LIB_DIR/features" -name "$barrel_name.dart" -type f | while read -r file; do
        # Extract feature name from path
        feature=$(echo "$file" | sed -E 's|.*/features/([^/]+)/.*|\1|')

        # Skip if already has prefix
        if [[ $(basename "$file") == "${feature}_${barrel_name}.dart" ]]; then
            echo "   ✅ $file already has prefix"
            continue
        fi

        # Generate new name
        dir=$(dirname "$file")
        new_file="$dir/${feature}_${barrel_name}.dart"

        echo "   🔄 Renaming: $(basename "$file") → ${feature}_${barrel_name}.dart"
        mv "$file" "$new_file"

        # Update imports in the same directory
        find "$dir" -name "*.dart" -not -name "${feature}_${barrel_name}.dart" -type f | while read -r import_file; do
            if grep -q "import.*$barrel_name.dart" "$import_file"; then
                echo "      📝 Updating import in $(basename "$import_file")"
                sed -i '' "s|'$barrel_name\.dart'|'${feature}_${barrel_name}.dart'|g" "$import_file"
            fi
        done

        # Update imports in parent directories
        parent_dir=$(dirname "$dir")
        find "$parent_dir" -name "*.dart" -type f | while read -r import_file; do
            if grep -q "controllers/$barrel_name" "$import_file" || grep -q "widgets/$barrel_name" "$import_file" || grep -q "screens/$barrel_name" "$import_file"; then
                echo "      📝 Updating import in $(basename "$import_file")"
                sed -i '' "s|controllers/$barrel_name\.dart|controllers/${feature}_${barrel_name}.dart|g" "$import_file"
                sed -i '' "s|widgets/$barrel_name\.dart|widgets/${feature}_${barrel_name}.dart|g" "$import_file"
                sed -i '' "s|screens/$barrel_name\.dart|screens/${feature}_${barrel_name}.dart|g" "$import_file"
            fi
        done
    done
}

# Rename common barrel files
rename_barrel_files "controllers"
rename_barrel_files "widgets"
rename_barrel_files "screens"

echo "✅ Barrel file standardization completed!"
echo ""
echo "📊 Summary of renamed files:"
find "$LIB_DIR/features" -name "*_controllers.dart" -o -name "*_widgets.dart" -o -name "*_screens.dart" | sort
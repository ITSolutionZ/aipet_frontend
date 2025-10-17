#!/bin/bash

# Fix all @freezed classes to use abstract keyword and private constructor

echo "🔧 Fixing all @freezed classes..."

# Find all files with @freezed annotation
grep -r "@freezed" lib --include="*.dart" -l | while read file; do
  # Check if file contains @freezed but not abstract class
  if grep -q "@freezed" "$file" && ! grep -q "^abstract class.*with _\$" "$file"; then
    # Get the class name from the file
    classname=$(grep -A 1 "@freezed" "$file" | grep "class" | sed -E 's/.*class ([A-Z][A-Za-z0-9]*) .*/\1/' | head -1)
    
    if [ -n "$classname" ]; then
      echo "✏️  Fixing $classname in $file"
      # Add abstract keyword
      sed -i '' -E "s/^class ${classname} with _\$/abstract class ${classname} with _\$/g" "$file"
      
      # Add private constructor if missing
      if ! grep -q "const ${classname}\\._();" "$file"; then
        sed -i '' "/^  }) = _${classname};$/a\\
\\
  const ${classname}._();
" "$file"
      fi
    fi
  fi
done

echo "✅ Freezed classes fixed!"

#!/bin/bash
# scripts/find_duplicate_code.sh
# Features 디렉토리의 중복 코드 탐지 스크립트

echo "🔍 Searching for duplicate error handlers..."
grep -r "class.*ErrorHandler\|handleError" lib/features/ --include="*.dart" | sort

echo ""
echo "🔍 Searching for duplicate validation logic..."
grep -r "validateEmail\|validatePassword\|validateRequired" lib/features/ --include="*.dart" | sort

echo ""
echo "🔍 Searching for duplicate date formatting..."
grep -r "formatTime\|formatDate\|formatDuration" lib/features/ --include="*.dart" | sort

echo ""
echo "🔍 Searching for hardcoded error messages..."
grep -r "const String.*Error\|const String.*Message" lib/features/ --include="*.dart" | sort

echo ""
echo "🔍 Searching for Dio instance creation..."
grep -r "Dio()" lib/features/ --include="*.dart" | sort

echo ""
echo "🔍 Searching for SharedPreferences usage..."
grep -r "SharedPreferences\|await prefs" lib/features/ --include="*.dart" | sort

echo ""
echo "🔍 Searching for ScaffoldMessenger calls..."
grep -r "ScaffoldMessenger.of(context).showSnackBar" lib/features/ --include="*.dart" | sort

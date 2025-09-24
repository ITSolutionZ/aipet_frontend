#!/bin/bash

# Script to standardize SnackBar usage across the Flutter project
# This script finds and lists raw ScaffoldMessenger calls that should be converted to SnackBarService

echo "🔍 Searching for raw SnackBar usage patterns..."
echo "================================================"

# Find all Dart files with raw ScaffoldMessenger patterns
echo -e "\n📍 Files with raw ScaffoldMessenger calls:"
rg "ScaffoldMessenger\.of\(" --type dart lib/ | head -20

echo -e "\n📊 Total count by type:"

# Count different patterns
echo "Raw ScaffoldMessenger calls: $(rg "ScaffoldMessenger\.of\(" --type dart lib/ -c | paste -sd+ | bc)"

echo "Files already using SnackBarService: $(rg "SnackBarService\." --type dart lib/ -c | paste -sd+ | bc)"

echo -e "\n🎯 Most common SnackBar content patterns:"

# Find common Japanese/Korean messages that could be standardized
rg "SnackBar\(content: Text\('([^']+)'\)\)" --type dart lib/ -o -r '$1' | sort | uniq -c | sort -nr | head -10

echo -e "\n✅ Recommended SnackBarService methods for common patterns:"
echo "- 成功/保存/更新: SnackBarService.showSaved(context, itemName: '...')"
echo "- エラー/無効な入力: SnackBarService.showError(context, '...')"
echo "- 情報/実装予定: SnackBarService.showInfo(context, '...')"
echo "- 警告: SnackBarService.showWarning(context, '...')"
echo "- ネットワークエラー: SnackBarService.showNetworkError(context)"

echo -e "\n📋 Files to refactor (excluding already converted):"
rg "ScaffoldMessenger\.of\(" --type dart lib/ -l | grep -v snackbar_service | head -10

echo -e "\n⚡ Use this to apply changes:"
echo "1. Replace error messages: SnackBarService.showError(context, 'message')"
echo "2. Replace success messages: SnackBarService.showSaved(context, itemName: 'item')"
echo "3. Replace info messages: SnackBarService.showInfo(context, 'message')"
echo "4. Add import if needed (check if 'shared.dart' already includes it)"
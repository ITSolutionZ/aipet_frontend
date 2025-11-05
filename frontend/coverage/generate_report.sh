#!/bin/bash

# AI Pet Frontend - テストカバレッジレポート生成スクリプト
# 使用方法: ./coverage/generate_report.sh

echo "🚀 AI Pet Frontend テストカバレッジレポート生成開始..."

# カバレッジ付きテスト実行
echo "📊 テスト実行中..."
flutter test test/unit/features/pet_registor/ --coverage

# HTML レポート生成
echo "📄 HTML レポート生成中..."
genhtml coverage/lcov.info -o coverage/html --title "AI Pet Frontend - Test Coverage Report"

# カバレッジサマリー生成
echo "📈 カバレッジサマリー生成中..."
python3 -c "
import re

with open('coverage/lcov.info', 'r') as f:
    content = f.read()

sections = re.split(r'(?=SF:)', content)

total_lines = 0
covered_lines = 0
files_found = 0

for section in sections:
    if 'pet_registor' in section:
        sf_match = re.search(r'SF:(.*)', section)
        lf_match = re.search(r'LF:(\d+)', section)
        lh_match = re.search(r'LH:(\d+)', section)

        if sf_match and lf_match and lh_match:
            filename = sf_match.group(1)
            lf = int(lf_match.group(1))
            lh = int(lh_match.group(1))
            coverage = (lh / lf * 100) if lf > 0 else 0
            print(f'{filename}: {lh}/{lf} ({coverage:.1f}%)')
            total_lines += lf
            covered_lines += lh
            files_found += 1

if total_lines > 0:
    overall_coverage = (covered_lines / total_lines) * 100
    print(f'\\n🎯 Pet Registor 全体カバレッジ:')
    print(f'📁 ファイル数: {files_found}')
    print(f'📊 総行数: {total_lines}')
    print(f'✅ カバーされた行: {covered_lines}')
    print(f'🎯 カバレッジ: {overall_coverage:.1f}%')

    if overall_coverage >= 90:
        print('🎉 目標 90% 達成!')
    else:
        print(f'📈 目標まで {90 - overall_coverage:.1f}% 不足')
else:
    print('No coverage data found for pet_registor')
"

echo "✅ レポート生成完了!"
echo "📂 HTML レポート: coverage/html/index.html"
echo "📄 詳細レポート: coverage/README.md"
echo "📊 テストレポート: coverage/test_report.md"
echo "📈 サマリー: coverage/coverage_summary.json"

# HTML レポートを開く（macOS）
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🌐 HTML レポートを開いています..."
    open coverage/html/index.html
fi

echo "🎉 完了!"

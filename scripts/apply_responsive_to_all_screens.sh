#!/bin/bash

# すべての画面ファイルに完全レスポンシブパターンを適用

echo "🚀 すべての画面ファイルにレスポンシブパターンを適用中..."
echo ""

# カウンター初期化
total_files=0
success_files=0
error_files=0
total_changes=0

# 進捗表示用
processed=0

# すべての*_screen.dartファイルを検索
while IFS= read -r file; do
    ((total_files++))

    # 進捗表示
    echo "[$total_files] 処理中: $file"

    # apply_full_responsive.pyを実行
    output=$(python3 scripts/apply_full_responsive.py --file "$file" 2>&1)

    if [ $? -eq 0 ]; then
        # 成功
        ((success_files++))

        # 変更数を抽出
        changes=$(echo "$output" | grep -oE "✨ 完了! [0-9]+" | grep -oE "[0-9]+")
        if [ ! -z "$changes" ]; then
            ((total_changes += changes))
            if [ "$changes" -gt 0 ]; then
                echo "  ✓ ${changes}個の変更を適用"
            else
                echo "  - 変更なし"
            fi
        fi
    else
        # エラー
        ((error_files++))
        echo "  ✗ エラーが発生しました"
        echo "$output" | tail -3
    fi

    echo ""

done < <(find lib/features -name "*_screen.dart" -type f)

# 結果サマリー
echo "============================================================"
echo "✨ 完全レスポンシブ変換完了!"
echo "============================================================"
echo ""
echo "📊 統計:"
echo "  - 処理されたファイル: ${total_files}個"
echo "  - 成功: ${success_files}個"
echo "  - エラー: ${error_files}個"
echo "  - 適用された総変更数: ${total_changes}個"
echo ""
echo "============================================================"

# エラーがあれば終了コード1を返す
if [ $error_files -gt 0 ]; then
    exit 1
fi

exit 0

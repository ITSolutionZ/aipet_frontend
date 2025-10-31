#!/usr/bin/env python3
"""
使用されていない変数を削除するスクリプト

flutter analyzeの結果を基に、unused_local_variable警告がある行を削除します。
"""

import re
import subprocess
from pathlib import Path

def get_unused_variables():
    """flutter analyzeを実行して使用されていない変数のリストを取得"""
    result = subprocess.run(
        ['flutter', 'analyze', 'lib/features'],
        capture_output=True,
        text=True
    )

    unused_vars = []

    for line in result.stdout.split('\n'):
        if 'unused_local_variable' in line:
            # 例: warning • The value of the local variable 'responsive' isn't used • lib/features/.../file.dart:46:11
            parts = line.split('•')
            if len(parts) >= 3:
                # 変数名を抽出
                var_match = re.search(r"'([^']+)'", parts[1])
                # ファイルとラインを抽出
                location = parts[2].strip()
                file_line = location.split(':')

                if var_match and len(file_line) >= 2:
                    var_name = var_match.group(1)
                    file_path = file_line[0]
                    line_num = int(file_line[1])

                    unused_vars.append({
                        'var': var_name,
                        'file': file_path,
                        'line': line_num
                    })

    return unused_vars

def remove_unused_variable_line(file_path: str, line_num: int, var_name: str) -> bool:
    """指定された行の変数宣言を削除"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        if line_num > len(lines):
            return False

        # 対象行を確認（0-indexed）
        target_line = lines[line_num - 1]

        # responsive, screenWidth, spacing等の変数宣言行かチェック
        if f'final {var_name}' in target_line or f'final responsive' in target_line:
            # その行を削除
            del lines[line_num - 1]

            # ファイルに書き戻す
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(lines)

            print(f"  ✓ {file_path}:{line_num} - '{var_name}' を削除")
            return True

        return False

    except Exception as e:
        print(f"  ✗ エラー: {file_path}:{line_num} - {str(e)}")
        return False

def main():
    print("🧹 使用されていない変数を削除中...\n")

    # 未使用変数を取得
    unused_vars = get_unused_variables()

    if not unused_vars:
        print("✨ 使用されていない変数はありません！")
        return

    print(f"📋 {len(unused_vars)}個の使用されていない変数を検出\n")

    # ファイルごとにグループ化
    files_to_process = {}
    for var_info in unused_vars:
        file_path = var_info['file']
        if file_path not in files_to_process:
            files_to_process[file_path] = []
        files_to_process[file_path].append(var_info)

    # 各ファイルを処理（行番号が大きい順に削除）
    total_removed = 0
    for file_path, var_list in files_to_process.items():
        print(f"\n処理中: {file_path}")

        # 行番号の降順でソート（下から削除）
        var_list.sort(key=lambda x: x['line'], reverse=True)

        for var_info in var_list:
            if remove_unused_variable_line(
                var_info['file'],
                var_info['line'],
                var_info['var']
            ):
                total_removed += 1

    print(f"\n{'='*60}")
    print(f"✨ 完了! {total_removed}個の変数を削除しました")
    print(f"{'='*60}\n")

if __name__ == '__main__':
    main()

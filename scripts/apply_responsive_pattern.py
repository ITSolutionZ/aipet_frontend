#!/usr/bin/env python3
"""
반응형 패턴 자동 적용 스크립트

이 스크립트는 Flutter 앱의 모든 화면에 ResponsiveHelper를 자동으로 적용합니다.

변환 패턴:
1. MediaQuery.of(context).size.width → context.responsive.screenWidth
2. MediaQuery.of(context).size.height → context.responsive.screenHeight
3. MediaQuery.of(context).padding.top → context.responsive.topPadding
4. MediaQuery.of(context).padding.bottom → context.responsive.bottomPadding
5. 하드코딩된 숫자 값 → 반응형 메서드 (수동 확인 필요)

사용법:
    python3 scripts/apply_responsive_pattern.py [옵션]

옵션:
    --dry-run: 실제로 파일을 수정하지 않고 변경 사항만 출력
    --path: 특정 파일 또는 디렉토리 경로 지정 (기본값: lib/features)
    --verbose: 상세한 로그 출력
"""

import os
import re
import sys
import argparse
from pathlib import Path
from typing import List, Tuple, Dict

# 변환 패턴 정의
PATTERNS = [
    # MediaQuery 패턴
    (r'MediaQuery\.of\(context\)\.size\.width', 'context.responsive.screenWidth'),
    (r'MediaQuery\.of\(context\)\.size\.height', 'context.responsive.screenHeight'),
    (r'MediaQuery\.of\(context\)\.padding\.top', 'context.responsive.topPadding'),
    (r'MediaQuery\.of\(context\)\.padding\.bottom', 'context.responsive.bottomPadding'),
    (r'MediaQuery\.of\(context\)\.padding\.left', 'context.responsive.leftPadding'),
    (r'MediaQuery\.of\(context\)\.padding\.right', 'context.responsive.rightPadding'),
    (r'MediaQuery\.of\(context\)\.viewInsets\.bottom', 'context.responsive.keyboardHeight'),

    # 변수로 선언된 경우
    (r'final\s+screenWidth\s*=\s*MediaQuery\.of\(context\)\.size\.width;?',
     'final screenWidth = context.responsive.screenWidth;'),
    (r'final\s+screenHeight\s*=\s*MediaQuery\.of\(context\)\.size\.height;?',
     'final screenHeight = context.responsive.screenHeight;'),
    (r'final\s+screenSize\s*=\s*MediaQuery\.of\(context\)\.size;?',
     'final screenSize = MediaQuery.of(context).size; // TODO: ResponsiveHelper 적용 검토'),

    # statusBarHeight 패턴
    (r'final\s+statusBarHeight\s*=\s*MediaQuery\.of\(context\)\.padding\.top;?',
     'final statusBarHeight = context.responsive.statusBarHeight;'),
]

# import 문 패턴
SHARED_IMPORT = "import 'package:aipet_frontend/shared/shared.dart';"
RESPONSIVE_IMPORT_PATTERN = r"import\s+['\"].*responsive_helper\.dart['\"];"


class ResponsiveApplier:
    def __init__(self, dry_run: bool = False, verbose: bool = False):
        self.dry_run = dry_run
        self.verbose = verbose
        self.modified_files = 0
        self.total_replacements = 0

    def log(self, message: str, level: str = "INFO"):
        """로그 출력"""
        if self.verbose or level == "ERROR":
            print(f"[{level}] {message}")

    def has_mediaquery_usage(self, content: str) -> bool:
        """MediaQuery 사용 여부 확인"""
        return 'MediaQuery.of(context)' in content

    def has_shared_import(self, content: str) -> bool:
        """shared.dart import 확인"""
        return SHARED_IMPORT in content or "package:aipet_frontend/shared/shared.dart" in content

    def has_responsive_import(self, content: str) -> bool:
        """responsive_helper import 확인"""
        return bool(re.search(RESPONSIVE_IMPORT_PATTERN, content))

    def add_shared_import(self, content: str) -> str:
        """shared.dart import 추가"""
        lines = content.split('\n')

        # 이미 import가 있으면 추가하지 않음
        if self.has_shared_import(content):
            return content

        # 마지막 import 문 찾기
        last_import_idx = -1
        for i, line in enumerate(lines):
            if line.strip().startswith('import '):
                last_import_idx = i

        if last_import_idx >= 0:
            # 마지막 import 다음에 추가
            lines.insert(last_import_idx + 1, SHARED_IMPORT)
        else:
            # import가 없으면 파일 시작 부분에 추가
            lines.insert(0, SHARED_IMPORT)
            lines.insert(1, '')

        return '\n'.join(lines)

    def apply_patterns(self, content: str) -> Tuple[str, int]:
        """변환 패턴 적용"""
        replacements = 0
        new_content = content

        for pattern, replacement in PATTERNS:
            matches = re.findall(pattern, new_content)
            if matches:
                new_content = re.sub(pattern, replacement, new_content)
                count = len(matches)
                replacements += count
                self.log(f"  - 패턴 '{pattern[:50]}...' → {count}개 변환", "DEBUG")

        return new_content, replacements

    def process_file(self, file_path: Path) -> bool:
        """파일 처리"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()

            # MediaQuery 사용이 없으면 스킵
            if not self.has_mediaquery_usage(original_content):
                return False

            self.log(f"\n처리 중: {file_path}")

            # 패턴 적용
            new_content, replacements = self.apply_patterns(original_content)

            if replacements > 0:
                # shared import 추가
                if not self.has_shared_import(new_content):
                    new_content = self.add_shared_import(new_content)
                    self.log("  + shared.dart import 추가")

                # responsive_helper import 제거 (shared에서 제공하므로)
                if self.has_responsive_import(new_content):
                    new_content = re.sub(RESPONSIVE_IMPORT_PATTERN + r'\s*', '', new_content)
                    self.log("  - 중복된 responsive_helper import 제거")

                self.log(f"  ✓ {replacements}개 변경 사항 적용")

                # 파일 저장
                if not self.dry_run:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)

                self.modified_files += 1
                self.total_replacements += replacements
                return True

            return False

        except Exception as e:
            self.log(f"파일 처리 중 오류: {file_path} - {str(e)}", "ERROR")
            return False

    def process_directory(self, directory: Path) -> None:
        """디렉토리 처리"""
        dart_files = list(directory.rglob('*.dart'))

        print(f"\n📁 디렉토리: {directory}")
        print(f"📄 총 {len(dart_files)}개의 Dart 파일 발견\n")

        for file_path in dart_files:
            self.process_file(file_path)

        print(f"\n{'='*60}")
        print(f"✨ 완료!")
        print(f"   - 수정된 파일: {self.modified_files}개")
        print(f"   - 총 변경 사항: {self.total_replacements}개")

        if self.dry_run:
            print(f"   ⚠️  DRY-RUN 모드: 실제로 파일이 수정되지 않았습니다.")

        print(f"{'='*60}\n")


def main():
    parser = argparse.ArgumentParser(
        description='Flutter 앱에 ResponsiveHelper 패턴을 자동으로 적용합니다.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
예제:
  # 전체 features 디렉토리 처리 (dry-run)
  python3 scripts/apply_responsive_pattern.py --dry-run

  # 특정 feature만 처리
  python3 scripts/apply_responsive_pattern.py --path lib/features/home

  # 실제 적용
  python3 scripts/apply_responsive_pattern.py --verbose
        """
    )

    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='실제로 파일을 수정하지 않고 변경 사항만 출력'
    )

    parser.add_argument(
        '--path',
        type=str,
        default='lib/features',
        help='처리할 디렉토리 경로 (기본값: lib/features)'
    )

    parser.add_argument(
        '--verbose',
        action='store_true',
        help='상세한 로그 출력'
    )

    args = parser.parse_args()

    # 프로젝트 루트 경로 찾기
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    target_path = project_root / args.path

    if not target_path.exists():
        print(f"❌ 오류: 경로를 찾을 수 없습니다: {target_path}")
        sys.exit(1)

    # 반응형 적용
    applier = ResponsiveApplier(dry_run=args.dry_run, verbose=args.verbose)

    if target_path.is_file():
        applier.process_file(target_path)
    else:
        applier.process_directory(target_path)


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""
완전 반응형 패턴 자동 적용 스크립트

하드코딩된 크기 값들까지 모두 ResponsiveHelper로 변환합니다.

변환 패턴:
1. const SizedBox(height: 24) → SizedBox(height: responsive.rs(24))
2. const SizedBox(width: 16) → SizedBox(width: responsive.rs(16))
3. const EdgeInsets.all(16) → responsive.rPadding(16)
4. const EdgeInsets.symmetric(...) → responsive.rPaddingSymmetric(...)
5. const EdgeInsets.only(...) → responsive.rPaddingOnly(...)
6. const Icon(..., size: 24) → Icon(..., size: responsive.ri(24))
7. TextStyle(fontSize: 20) → TextStyle(fontSize: responsive.rf(20))
8. padding: EdgeInsets.only(bottom: 60) → padding: responsive.rPaddingOnly(bottom: 60)

사용법:
    python3 scripts/apply_full_responsive.py --file <파일경로>
"""

import re
import sys
import argparse
from pathlib import Path

class FullResponsiveApplier:
    def __init__(self, dry_run: bool = False, verbose: bool = False):
        self.dry_run = dry_run
        self.verbose = verbose
        self.changes_count = 0

    def log(self, message: str, level: str = "INFO"):
        """로그 출력"""
        if self.verbose or level == "ERROR":
            print(f"[{level}] {message}")

    def ensure_responsive_variable(self, content: str) -> tuple[str, bool]:
        """final responsive = context.responsive; 선언 확인 및 추가"""
        # build 메서드 찾기
        build_pattern = r'(@override\s+Widget\s+build\s*\([^)]*\)\s*\{)'

        # 이미 responsive 변수가 있는지 확인
        if 'final responsive = context.responsive;' in content or \
           'final responsive = ResponsiveHelper.of(context);' in content:
            return content, False

        # build 메서드 내부에 responsive 변수 추가
        def add_responsive(match):
            build_start = match.group(1)
            # build 메서드 다음 줄에 responsive 변수 추가
            return f"{build_start}\n    final responsive = context.responsive;\n"

        new_content = re.sub(build_pattern, add_responsive, content, count=1)
        added = new_content != content

        if added:
            self.log("  + 'final responsive = context.responsive;' 추가")

        return new_content, added

    def convert_sized_box(self, content: str) -> tuple[str, int]:
        """SizedBox 변환"""
        count = 0

        # const SizedBox(height: 숫자) → SizedBox(height: responsive.rs(숫자))
        pattern1 = r'const\s+SizedBox\s*\(\s*height:\s*(\d+(?:\.\d+)?)\s*\)'
        matches = re.findall(pattern1, content)
        if matches:
            content = re.sub(pattern1, r'SizedBox(height: responsive.rs(\1))', content)
            count += len(matches)
            self.log(f"  - SizedBox(height) {len(matches)}개 변환", "DEBUG")

        # const SizedBox(width: 숫자) → SizedBox(width: responsive.rs(숫자))
        pattern2 = r'const\s+SizedBox\s*\(\s*width:\s*(\d+(?:\.\d+)?)\s*\)'
        matches = re.findall(pattern2, content)
        if matches:
            content = re.sub(pattern2, r'SizedBox(width: responsive.rs(\1))', content)
            count += len(matches)
            self.log(f"  - SizedBox(width) {len(matches)}개 변환", "DEBUG")

        return content, count

    def convert_edge_insets(self, content: str) -> tuple[str, int]:
        """EdgeInsets 변환"""
        count = 0

        # const EdgeInsets.all(숫자) → responsive.rPadding(숫자)
        pattern1 = r'const\s+EdgeInsets\.all\s*\(\s*(\d+(?:\.\d+)?)\s*\)'
        matches = re.findall(pattern1, content)
        if matches:
            content = re.sub(pattern1, r'responsive.rPadding(\1)', content)
            count += len(matches)
            self.log(f"  - EdgeInsets.all {len(matches)}개 변환", "DEBUG")

        # const EdgeInsets.symmetric(horizontal: X, vertical: Y)
        pattern2 = r'const\s+EdgeInsets\.symmetric\s*\(\s*horizontal:\s*(\d+(?:\.\d+)?)\s*,\s*vertical:\s*(\d+(?:\.\d+)?)\s*\)'
        matches = re.findall(pattern2, content)
        if matches:
            content = re.sub(pattern2, r'responsive.rPaddingSymmetric(horizontal: \1, vertical: \2)', content)
            count += len(matches)
            self.log(f"  - EdgeInsets.symmetric {len(matches)}개 변환", "DEBUG")

        # const EdgeInsets.symmetric(horizontal: X)
        pattern3 = r'const\s+EdgeInsets\.symmetric\s*\(\s*horizontal:\s*(\d+(?:\.\d+)?)\s*\)'
        matches = re.findall(pattern3, content)
        if matches:
            content = re.sub(pattern3, r'responsive.rPaddingSymmetric(horizontal: \1)', content)
            count += len(matches)
            self.log(f"  - EdgeInsets.symmetric(horizontal) {len(matches)}개 변환", "DEBUG")

        # const EdgeInsets.symmetric(vertical: Y)
        pattern4 = r'const\s+EdgeInsets\.symmetric\s*\(\s*vertical:\s*(\d+(?:\.\d+)?)\s*\)'
        matches = re.findall(pattern4, content)
        if matches:
            content = re.sub(pattern4, r'responsive.rPaddingSymmetric(vertical: \1)', content)
            count += len(matches)
            self.log(f"  - EdgeInsets.symmetric(vertical) {len(matches)}개 변환", "DEBUG")

        # EdgeInsets.only 패턴들
        # EdgeInsets.only(bottom: 60)
        pattern5 = r'EdgeInsets\.only\s*\(\s*bottom:\s*(\d+(?:\.\d+)?)\s*\)'
        matches = re.findall(pattern5, content)
        if matches:
            content = re.sub(pattern5, r'responsive.rPaddingOnly(bottom: \1)', content)
            count += len(matches)
            self.log(f"  - EdgeInsets.only(bottom) {len(matches)}개 변환", "DEBUG")

        return content, count

    def convert_icon_size(self, content: str) -> tuple[str, int]:
        """Icon size 변환"""
        count = 0

        # const Icon(..., size: 24) → Icon(..., size: responsive.ri(24))
        # 이미 변환된 것은 건너뛰기
        pattern = r'const\s+Icon\s*\([^)]*size:\s*(\d+(?:\.\d+)?)'

        def replace_icon(match):
            # const 제거하고 size를 responsive로 변환
            icon_content = match.group(0)
            icon_content = icon_content.replace('const ', '')
            icon_content = re.sub(r'size:\s*(\d+(?:\.\d+)?)', r'size: responsive.ri(\1)', icon_content)
            return icon_content

        matches = re.findall(pattern, content)
        if matches:
            content = re.sub(pattern, replace_icon, content)
            count += len(matches)
            self.log(f"  - Icon size {len(matches)}개 변환", "DEBUG")

        return content, count

    def convert_text_style(self, content: str) -> tuple[str, int]:
        """TextStyle fontSize 변환"""
        count = 0

        # TextStyle(fontSize: 20) → TextStyle(fontSize: responsive.rf(20))
        # const TextStyle은 이미 처리됨
        pattern = r'TextStyle\s*\([^)]*fontSize:\s*(\d+(?:\.\d+)?)'

        def replace_text_style(match):
            text_style = match.group(0)
            # 이미 responsive.rf가 있으면 건너뛰기
            if 'responsive.rf' in text_style:
                return text_style
            text_style = re.sub(r'fontSize:\s*(\d+(?:\.\d+)?)', r'fontSize: responsive.rf(\1)', text_style)
            # const 제거
            text_style = text_style.replace('const TextStyle', 'TextStyle')
            return text_style

        matches = re.findall(pattern, content)
        if matches:
            content = re.sub(pattern, replace_text_style, content)
            count += len(set(matches))  # 중복 제거
            self.log(f"  - TextStyle fontSize {len(set(matches))}개 변환", "DEBUG")

        return content, count

    def convert_container_height_width(self, content: str) -> tuple[str, int]:
        """Container height/width 변환"""
        count = 0

        # height: 50 패턴 (Container, SizedBox 등)
        pattern1 = r'height:\s*(\d+(?:\.\d+)?)\s*,'

        def replace_height(match):
            value = match.group(1)
            # 이미 responsive가 있으면 건너뛰기
            if 'responsive' in match.group(0):
                return match.group(0)
            return f'height: responsive.rh({value}),'

        # double.infinity는 제외
        temp_content = re.sub(r'height:\s*double\.infinity', 'HEIGHT_INFINITY_PLACEHOLDER', content)
        matches = re.findall(pattern1, temp_content)
        if matches:
            temp_content = re.sub(pattern1, replace_height, temp_content)
            count += len(matches)
            self.log(f"  - height {len(matches)}개 변환", "DEBUG")
        content = temp_content.replace('HEIGHT_INFINITY_PLACEHOLDER', 'height: double.infinity')

        return content, count

    def process_file(self, file_path: Path) -> bool:
        """파일 처리"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()

            self.log(f"\n처리 중: {file_path}")

            content = original_content
            total_changes = 0

            # 1. responsive 변수 추가
            content, added = self.ensure_responsive_variable(content)
            if added:
                total_changes += 1

            # 2. SizedBox 변환
            content, count = self.convert_sized_box(content)
            total_changes += count

            # 3. EdgeInsets 변환
            content, count = self.convert_edge_insets(content)
            total_changes += count

            # 4. Icon size 변환
            content, count = self.convert_icon_size(content)
            total_changes += count

            # 5. TextStyle fontSize 변환
            content, count = self.convert_text_style(content)
            total_changes += count

            # 6. Container height/width 변환
            content, count = self.convert_container_height_width(content)
            total_changes += count

            if total_changes > 0:
                self.log(f"  ✓ {total_changes}개 변경 사항 적용")

                if not self.dry_run:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)

                self.changes_count += total_changes
                return True
            else:
                self.log("  변경 사항 없음")
                return False

        except Exception as e:
            self.log(f"파일 처리 중 오류: {file_path} - {str(e)}", "ERROR")
            return False

def main():
    parser = argparse.ArgumentParser(
        description='Flutter 파일의 하드코딩된 크기를 ResponsiveHelper로 변환합니다.'
    )

    parser.add_argument(
        '--file',
        type=str,
        required=True,
        help='변환할 Dart 파일 경로'
    )

    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='실제로 파일을 수정하지 않고 변경 사항만 출력'
    )

    parser.add_argument(
        '--verbose',
        action='store_true',
        help='상세한 로그 출력'
    )

    args = parser.parse_args()

    file_path = Path(args.file)

    if not file_path.exists():
        print(f"❌ 오류: 파일을 찾을 수 없습니다: {file_path}")
        sys.exit(1)

    applier = FullResponsiveApplier(dry_run=args.dry_run, verbose=args.verbose)

    success = applier.process_file(file_path)

    print(f"\n{'='*60}")
    if success:
        print(f"✨ 완료! {applier.changes_count}개 변경 사항 적용")
    else:
        print("변경 사항 없음")

    if args.dry_run:
        print("⚠️  DRY-RUN 모드: 실제로 파일이 수정되지 않았습니다.")
    print(f"{'='*60}\n")

if __name__ == '__main__':
    main()

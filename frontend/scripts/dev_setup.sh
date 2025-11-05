#!/bin/bash

# AI Pet Frontend - Development Setup Script
# 이 스크립트는 개발 환경을 설정하고 코드 품질을 확인합니다.

echo "🚀 AI Pet Frontend - Development Setup 시작"
echo "==========================================="

# 현재 디렉토리가 프로젝트 루트인지 확인
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 오류: pubspec.yaml 파일을 찾을 수 없습니다."
    echo "프로젝트 루트 디렉토리에서 실행해주세요."
    exit 1
fi

# 1. Flutter 의존성 설치
echo "📦 1. Flutter 의존성 설치 중..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ 오류: Flutter 의존성 설치에 실패했습니다."
    exit 1
fi

# 2. 코드 생성
echo "🔨 2. 코드 생성 중..."
flutter packages pub run build_runner build --delete-conflicting-outputs

if [ $? -ne 0 ]; then
    echo "❌ 오류: 코드 생성에 실패했습니다."
    exit 1
fi

# 3. 코드 포맷팅
echo "🎨 3. 코드 포맷팅 중..."
dart format lib/ test/

# 4. Flutter analyze
echo "🔍 4. Flutter analyze 실행 중..."
flutter analyze

if [ $? -eq 0 ]; then
    echo "✅ Flutter analyze 완료!"
else
    echo "⚠️  경고: Flutter analyze에서 문제가 발견되었습니다."
fi

# 5. 테스트 실행
echo "🧪 5. 테스트 실행 중..."
flutter test

if [ $? -eq 0 ]; then
    echo "✅ 모든 테스트 통과!"
else
    echo "⚠️  경고: 일부 테스트가 실패했습니다."
fi

# 6. 불필요한 import 정리
echo "🧹 6. 불필요한 import 정리 중..."
dart fix --apply

echo "🎉 Development Setup 완료!"
echo "==========================================="
echo "📋 다음 명령어들을 사용할 수 있습니다:"
echo "  ./scripts/build_runner.sh  - 코드 생성"
echo "  ./scripts/format_code.sh   - 코드 포맷팅"
echo "  flutter test               - 테스트 실행"
echo "  flutter analyze            - 코드 분석"

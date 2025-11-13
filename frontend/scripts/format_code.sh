#!/bin/bash

# AI Pet Frontend - Code Formatting Script
# 이 스크립트는 코드 포맷팅을 자동화합니다.

echo "🎨 AI Pet Frontend - Code Formatting 시작"
echo "=========================================="

# 현재 디렉토리가 프로젝트 루트인지 확인
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 오류: pubspec.yaml 파일을 찾을 수 없습니다."
    echo "프로젝트 루트 디렉토리에서 실행해주세요."
    exit 1
fi

# Dart 코드 포맷팅
echo "📝 Dart 코드 포맷팅 중..."
dart format lib/ test/

if [ $? -eq 0 ]; then
    echo "✅ Dart 코드 포맷팅 완료!"
else
    echo "❌ 오류: Dart 코드 포맷팅에 실패했습니다."
    exit 1
fi

# Flutter analyze 실행
echo "🔍 Flutter analyze 실행 중..."
flutter analyze

if [ $? -eq 0 ]; then
    echo "✅ Flutter analyze 완료!"
else
    echo "⚠️  경고: Flutter analyze에서 문제가 발견되었습니다."
    echo "코드를 확인하고 수정해주세요."
fi

# 불필요한 import 정리
echo "🧹 불필요한 import 정리 중..."
dart fix --apply

echo "🎉 Code Formatting 완료!"
echo "=========================================="

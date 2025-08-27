#!/bin/bash

# AI Pet Frontend - Build Runner Script
# 이 스크립트는 코드 생성을 위한 build_runner를 실행합니다.

echo "🚀 AI Pet Frontend - Build Runner 시작"
echo "======================================"

# 현재 디렉토리가 프로젝트 루트인지 확인
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 오류: pubspec.yaml 파일을 찾을 수 없습니다."
    echo "프로젝트 루트 디렉토리에서 실행해주세요."
    exit 1
fi

# Flutter 의존성 확인
echo "📦 Flutter 의존성 확인 중..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ 오류: Flutter 의존성 설치에 실패했습니다."
    exit 1
fi

# 기존 생성 파일 정리
echo "🧹 기존 생성 파일 정리 중..."
flutter packages pub run build_runner clean

# 코드 생성 실행
echo "🔨 코드 생성 중..."
flutter packages pub run build_runner build --delete-conflicting-outputs

if [ $? -eq 0 ]; then
    echo "✅ 코드 생성 완료!"
    echo "📊 생성된 파일:"
    find . -name "*.g.dart" -type f | head -10
    echo "..."
else
    echo "❌ 오류: 코드 생성에 실패했습니다."
    exit 1
fi

# 코드 포맷팅
echo "🎨 코드 포맷팅 중..."
dart format lib/ test/

echo "🎉 Build Runner 완료!"
echo "======================================"

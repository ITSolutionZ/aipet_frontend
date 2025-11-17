#!/bin/bash

# Xcode 빌드 최적화 스크립트
# 병렬 빌드 및 빌드 시간 최적화 설정

echo "🚀 Xcode 빌드 최적화 설정 중..."

# 1. Xcode 병렬 빌드 최대화 (0 = 자동, CPU 코어 수에 맞춤)
echo "📦 Xcode 병렬 빌드 설정..."
defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks 0

# 2. DerivedData 경로 확인 및 최적화
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
echo "📦 DerivedData 경로: $DERIVED_DATA_PATH"

# 3. 빌드 캐시 유지 (최근 7일만 유지)
echo "📦 오래된 빌드 캐시 정리 중..."
find "$DERIVED_DATA_PATH" -type d -mtime +7 -exec rm -rf {} + 2>/dev/null || true

# 4. Xcode 빌드 로그 최적화
echo "📦 Xcode 빌드 로그 설정..."
defaults write com.apple.dt.Xcode IDEShowBuildOperationDuration YES

# 5. Swift 컴파일러 병렬 빌드 활성화
echo "📦 Swift 컴파일러 병렬 빌드 활성화..."
defaults write com.apple.dt.Xcode IDESwiftCompilerParallelBuild YES

echo "✅ Xcode 빌드 최적화 완료!"
echo ""
echo "적용된 최적화:"
echo "  - 병렬 빌드: 자동 (CPU 코어 수에 맞춤)"
echo "  - Swift 병렬 컴파일: 활성화"
echo "  - 빌드 로그 표시: 활성화"
echo ""
echo "다시 빌드해보세요!"

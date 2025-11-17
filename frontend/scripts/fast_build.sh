#!/bin/bash

# Flutter iOS 빌드 최적화 스크립트
# 빌드 시간을 단축하기 위한 최적화 설정

echo "🚀 Flutter iOS 빌드 최적화 시작..."

cd "$(dirname "$0")/.." || exit

# 1. Flutter 빌드 캐시 확인
echo "📦 Flutter 빌드 캐시 확인 중..."
flutter pub get

# 2. iOS Pod 최적화 확인
echo "📦 iOS Pod 확인 중..."
cd ios || exit
if [ ! -d "Pods" ]; then
    echo "Pod 설치 중..."
    pod install --repo-update
else
    echo "Pod 이미 설치되어 있습니다."
fi
cd ..

# 3. 빌드 모드 선택
BUILD_MODE=${1:-debug}

echo "🔨 $BUILD_MODE 모드로 빌드 시작..."

# 4. 빌드 실행 (최적화 옵션 포함)
case $BUILD_MODE in
    debug)
        echo "Debug 모드 빌드 (Hot Reload 지원, 최적화됨)"
        # 시뮬레이터용 빌드 (더 빠름)
        flutter run --debug \
            --no-sound-null-safety \
            --dart-define=FLUTTER_WEB_USE_SKIA=false \
            --target-platform=ios-simulator
        ;;
    profile)
        echo "Profile 모드 빌드 (성능 측정용)"
        flutter run --profile \
            --no-sound-null-safety \
            --target-platform=ios-simulator
        ;;
    release)
        echo "Release 모드 빌드 (최적화됨)"
        flutter run --release \
            --no-sound-null-safety
        ;;
    *)
        echo "알 수 없는 빌드 모드: $BUILD_MODE"
        echo "사용법: ./scripts/fast_build.sh [debug|profile|release]"
        exit 1
        ;;
esac

echo "✅ 빌드 완료!"

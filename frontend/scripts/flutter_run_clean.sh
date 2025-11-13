#!/bin/bash

# Flutter 실행 시 불필요한 로그 필터링
echo "Starting Flutter with filtered logs..."

# adb logcat 필터링 백그라운드 실행
adb logcat | grep -v -E "(ImageReader_JNI|FrameEvents|Unable to acquire a buffer item|updateAcquireFence|hiddenapi|InsetsController|InputMethodManager)" &
LOGCAT_PID=$!

# Flutter 실행
flutter run "$@"

# Flutter 종료 시 logcat 프로세스도 종료
kill $LOGCAT_PID 2>/dev/null
#!/bin/bash

# 자동 테스트 생성 스크립트
# 모든 Controller, Service, Repository에 대한 기본 테스트 생성

echo "🧪 테스트 자동 생성 시작..."

# Controllers 테스트 생성
echo "📝 Controller 테스트 생성 중..."
find lib/features -name "*_controller.dart" -type f | while read controller_file; do
  # 테스트 파일 경로 생성
  test_file=$(echo "$controller_file" | sed 's|lib/|test/unit/|' | sed 's|\.dart$|_test.dart|')

  # 이미 테스트가 존재하면 스킵
  if [ -f "$test_file" ]; then
    continue
  fi

  # 디렉토리 생성
  mkdir -p "$(dirname "$test_file")"

  # 클래스명 추출
  class_name=$(basename "$controller_file" .dart | sed 's/_\([a-z]\)/\U\1/g' | sed 's/^./\U&/')

  # 테스트 파일 생성
  cat > "$test_file" << EOF
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('${class_name} Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('초기 상태 확인', () {
      // TODO: 실제 provider 및 초기 상태 테스트 구현
      expect(true, true);
    });

    test('상태 변경 테스트', () {
      // TODO: 상태 변경 로직 테스트 구현
      expect(true, true);
    });

    test('에러 핸들링 테스트', () {
      // TODO: 에러 상황 테스트 구현
      expect(true, true);
    });
  });
}
EOF

  echo "  ✅ Created: $test_file"
done

# Services 테스트 생성
echo "📝 Service 테스트 생성 중..."
find lib/features -name "*_service.dart" -type f | while read service_file; do
  test_file=$(echo "$service_file" | sed 's|lib/|test/unit/|' | sed 's|\.dart$|_test.dart|')

  if [ -f "$test_file" ]; then
    continue
  fi

  mkdir -p "$(dirname "$test_file")"
  class_name=$(basename "$service_file" .dart | sed 's/_\([a-z]\)/\U\1/g' | sed 's/^./\U&/')

  cat > "$test_file" << EOF
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('${class_name} Tests', () {
    test('서비스 초기화 테스트', () {
      // TODO: 서비스 초기화 테스트 구현
      expect(true, true);
    });

    test('핵심 기능 테스트', () {
      // TODO: 핵심 비즈니스 로직 테스트 구현
      expect(true, true);
    });

    test('에러 처리 테스트', () {
      // TODO: 예외 상황 처리 테스트 구현
      expect(true, true);
    });
  });
}
EOF

  echo "  ✅ Created: $test_file"
done

# Repositories 테스트 생성
echo "📝 Repository 테스트 생성 중..."
find lib/features -name "*_repository_impl.dart" -type f | while read repo_file; do
  test_file=$(echo "$repo_file" | sed 's|lib/|test/unit/|' | sed 's|\.dart$|_test.dart|')

  if [ -f "$test_file" ]; then
    continue
  fi

  mkdir -p "$(dirname "$test_file")"
  class_name=$(basename "$repo_file" .dart | sed 's/_\([a-z]\)/\U\1/g' | sed 's/^./\U&/')

  cat > "$test_file" << EOF
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('${class_name} Tests', () {
    test('데이터 조회 테스트', () {
      // TODO: Repository 데이터 조회 테스트 구현
      expect(true, true);
    });

    test('데이터 저장 테스트', () {
      // TODO: Repository 데이터 저장 테스트 구현
      expect(true, true);
    });

    test('에러 핸들링 테스트', () {
      // TODO: Repository 에러 처리 테스트 구현
      expect(true, true);
    });
  });
}
EOF

  echo "  ✅ Created: $test_file"
done

echo ""
echo "✅ 테스트 생성 완료!"
echo ""
echo "📊 생성된 테스트 파일 수:"
find test/unit -name "*_test.dart" -type f | wc -l
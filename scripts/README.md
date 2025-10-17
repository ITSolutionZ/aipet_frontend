# AI Pet Frontend - Scripts / AI Pet Frontend - スクリプト

언어 선택 / Language Selection:

- [한국어](#한국어-korean)
- [日本語](#日本語-japanese)

---

## 한국어 (Korean)

### 📋 개요

이 폴더는 AI Pet Frontend 프로젝트의 개발 및 테스트를 위한 자동화 스크립트들을 포함합니다.

### 🚀 핵심 스크립트

#### 1. **개발 환경 설정** (`dev_setup.sh`)

```bash
./scripts/dev_setup.sh
```

- Flutter 의존성 설치
- 코드 생성 (build_runner)
- 코드 포맷팅
- Flutter analyze 실행
- 테스트 실행
- 불필요한 import 정리

#### 2. **코드 생성** (`build_runner.sh`)

```bash
./scripts/build_runner.sh
```

- Mock 파일 생성 (Mockito)
- Riverpod Provider 코드 생성
- 기존 생성 파일 정리
- 코드 포맷팅

#### 3. **코드 포맷팅** (`format_code.sh`)

```bash
./scripts/format_code.sh
```

- Dart 코드 포맷팅
- Flutter analyze 실행
- 불필요한 import 정리

#### 4. **통합 에러 수정** (`fix_all_errors.sh`)

```bash
./scripts/fix_all_errors.sh
```

- Result 패턴 에러 수정
- const 생성자 추가
- deprecated API 수정
- 자동 코드 포맷팅

#### 5. **Mockito 테스트 실행** (`run_mockito_tests.sh`)

```bash
# 기본 테스트 실행
./scripts/run_mockito_tests.sh

# 커버리지 포함 테스트 실행
./scripts/run_mockito_tests.sh --coverage
```

### 🔧 특수 목적 스크립트

#### 6. **테스트 생성** (`generate_tests.sh`)

```bash
./scripts/generate_tests.sh
```

- 자동 테스트 파일 생성
- 테스트 템플릿 적용

#### 7. **성능 최적화** (`optimize_performance.sh`)

```bash
./scripts/optimize_performance.sh
```

- 코드 최적화
- 성능 개선 적용

#### 8. **const 생성자 추가** (`add_const_constructors.sh`)

```bash
./scripts/add_const_constructors.sh
```

- const 생성자 자동 추가
- 코드 품질 개선

### 🧪 Mockito 테스트 사용법

#### 기본 사용법

```bash
# 모든 AI Mockito 테스트 실행
./scripts/run_mockito_tests.sh

# 특정 테스트만 실행
flutter test test/unit/features/ai/simple_mockito_test.dart
```

#### 테스트 구조

```text
test/unit/features/ai/
├── simple_mockito_test.dart              # ✅ 간단한 Mockito 테스트 (작동 확인됨)
├── data/
│   ├── repositories/
│   │   └── ai_repository_impl_test.dart  # AI Repository 테스트
│   └── services/
│       ├── openai_service_test.dart      # OpenAI Service 테스트
│       ├── ai_mock_data_service_impl_test.dart  # Mock 데이터 서비스 테스트
│       └── pet_content_filter_service_test.dart # 콘텐츠 필터 테스트
└── presentation/
    └── controllers/
        └── ai_chat_controller_test.dart  # AI Controller 테스트
```

### 🔧 Clean Code & Clean Architecture 준수

#### Mockito 사용 패턴

```dart
// ✅ @GenerateMocks로 타입 안전한 Mock 생성
@GenerateMocks([AiRepository, OpenAIService])

// ✅ 명확한 Mock 동작 정의
when(mockRepository.getChatHistory())
    .thenAnswer((_) async => expectedMessages);

// ✅ 검증 가능한 테스트
verify(mockRepository.getChatHistory()).called(1);
```

#### 테스트 구조 (AAA 패턴)

```dart
test('should send message and return AI response', () async {
  // Arrange - 준비
  when(mockRepository.sendMessage(userMessage))
      .thenAnswer((_) async => expectedMessage);

  // Act - 실행
  final result = await repository.sendMessage(userMessage);

  // Assert - 검증
  expect(result, equals(expectedMessage));
  verify(mockRepository.sendMessage(userMessage)).called(1);
});
```

### 📊 스크립트 정리 현황

#### ✅ 현재 활성 스크립트 (17개)

- `dev_setup.sh` - 개발 환경 설정
- `build_runner.sh` - 코드 생성
- `format_code.sh` - 코드 포맷팅
- `fix_all_errors.sh` - 통합 에러 수정 ⭐ (개선됨)
- `remove_duplicates.sh` - const/Result 중복 제거 전용 🆕
- `prevent_bad_patterns.sh` - 잘못된 패턴 방지 🆕
- `run_mockito_tests.sh` - 테스트 실행
- `generate_tests.sh` - 테스트 생성
- `optimize_performance.sh` - 성능 최적화
- `add_const_constructors.sh` - const 생성자 추가
- `consolidate_pet_entities.sh` - Pet Entity 통합
- `fix_missing_pet_entity_imports.sh` - Pet Entity import 수정
- `fix_notification_imports.sh` - 알림 import 수정
- `standardize_result_pattern.sh` - Result 패턴 표준화
- `README.md` - 스크립트 문서

#### 🗑️ 정리된 스크립트 (18개 삭제)

- 01-10번 임포트 수정 스크립트 (10개)
- 중복 에러 수정 스크립트 (4개)
- 완료된 임시 스크립트 (4개)

### 🎯 사용 권장사항

1. **개발 시작 시**: `dev_setup.sh` 실행
2. **에러 발생 시**: `fix_all_errors.sh` 실행
3. **중복 제거만 필요시**: `remove_duplicates.sh` 실행 🆕
4. **잘못된 패턴 수정**: `prevent_bad_patterns.sh` 실행 🆕
5. **코드 변경 후**: `format_code.sh` 실행
6. **테스트 실행**: `run_mockito_tests.sh` 실행

### 🆕 새로운 스크립트 상세 설명

#### `remove_duplicates.sh` - 중복 제거 전용

```bash
./scripts/remove_duplicates.sh
```

- `const const const` → `const` 중복 제거
- `ResultResult` → `Result` 중복 제거
- 최대 10회 반복 실행으로 완전 제거 보장
- 실행 전후 중복 개수 리포트

#### `prevent_bad_patterns.sh` - 잘못된 패턴 방지

```bash
./scripts/prevent_bad_patterns.sh
```

- `pw.const` 패턴 제거 (PDF 라이브러리)
- 변수명 중간 const 삽입 수정 (`Timeoconst ut` → `Timeout`)
- Duration 매개변수 수정 (`minutes =` → `minutes:`)
- Result.Result 패턴 수정

### ⚠️ 주의사항

- 스크립트 실행 후 반드시 `dart format lib/` 실행 권장
- 중요한 변경 전에는 git commit으로 백업
- 스크립트가 const/Result를 중복으로 추가하는 문제 해결됨 ✅

---

## 日本語 (Japanese)

### 📋 概要

このフォルダには、AI Pet Frontend プロジェクトの開発とテストのための自動化スクリプトが含まれています。

### 🚀 コアスクリプト

#### 1. **開発環境設定** (`dev_setup.sh`)

```bash
./scripts/dev_setup.sh
```

- Flutter 依存関係のインストール
- コード生成 (build_runner)
- コードフォーマット
- Flutter analyze 実行
- テスト実行
- 不要な import の整理

#### 2. **コード生成** (`build_runner.sh`)

```bash
./scripts/build_runner.sh
```

- Mock ファイル生成 (Mockito)
- Riverpod Provider コード生成
- 既存生成ファイルの整理
- コードフォーマット

#### 3. **コードフォーマット** (`format_code.sh`)

```bash
./scripts/format_code.sh
```

- Dart コードフォーマット
- Flutter analyze 実行
- 不要な import の整理

#### 4. **統合エラー修正** (`fix_all_errors.sh`)

```bash
./scripts/fix_all_errors.sh
```

- Result パターンエラー修正
- const コンストラクタ追加
- deprecated API 修正
- 自動コードフォーマット

#### 5. **Mockito テスト実行** (`run_mockito_tests.sh`)

```bash
# 基本テスト実行
./scripts/run_mockito_tests.sh

# カバレッジ含むテスト実行
./scripts/run_mockito_tests.sh --coverage
```

### 🧪 Mockito テスト使用方法

#### 基本使用方法

```bash
# すべてのAI Mockitoテスト実行
./scripts/run_mockito_tests.sh

# 特定のテストのみ実行
flutter test test/unit/features/ai/simple_mockito_test.dart
```

#### テスト構造

```text
test/unit/features/ai/
├── simple_mockito_test.dart              # ✅ 簡単なMockitoテスト (動作確認済み)
├── data/
│   ├── repositories/
│   │   └── ai_repository_impl_test.dart  # AI Repositoryテスト
│   └── services/
│       ├── openai_service_test.dart      # OpenAI Serviceテスト
│       ├── ai_mock_data_service_impl_test.dart  # Mockデータサービステスト
│       └── pet_content_filter_service_test.dart # コンテンツフィルタテスト
└── presentation/
    └── controllers/
        └── ai_chat_controller_test.dart  # AI Controllerテスト
```

### 🔧 Clean Code & Clean Architecture 準拠

#### Mockito 使用パターン

```dart
// ✅ @GenerateMocksで型安全なMock生成
@GenerateMocks([AiRepository, OpenAIService])

// ✅ 明確なMock動作定義
when(mockRepository.getChatHistory())
    .thenAnswer((_) async => expectedMessages);

// ✅ 検証可能なテスト
verify(mockRepository.getChatHistory()).called(1);
```

#### テスト構造 (AAA パターン)

```dart
test('should send message and return AI response', () async {
  // Arrange - 準備
  when(mockRepository.sendMessage(userMessage))
      .thenAnswer((_) async => expectedMessage);

  // Act - 実行
  final result = await repository.sendMessage(userMessage);

  // Assert - 検証
  expect(result, equals(expectedMessage));
  verify(mockRepository.sendMessage(userMessage)).called(1);
});
```

### 📊 スクリプト整理状況

#### ✅ 現在のアクティブスクリプト (15 個)

統合および整理により、33 個から 17 個に。新規スクリプト 2 個追加。

#### 🎯 使用推奨事項

1. **開発開始時**: `dev_setup.sh` 実行
2. **エラー発生時**: `fix_all_errors.sh` 実行
3. **重複除去のみ必要**: `remove_duplicates.sh` 実行 🆕
4. **誤パターン修正**: `prevent_bad_patterns.sh` 実行 🆕
5. **コード変更後**: `format_code.sh` 実行
6. **テスト実行**: `run_mockito_tests.sh` 実行

### 🆕 新スクリプト詳細

#### `remove_duplicates.sh` - 重複除去専用

- `const const const` → `const` 重複除去
- `ResultResult` → `Result` 重複除去
- 最大 10 回反復実行で完全除去保証

#### `prevent_bad_patterns.sh` - 誤パターン防止

- `pw.const` パターン除去 (PDF ライブラリ)
- 変数名中の const 挿入修正
- Duration パラメータ修正

### ⚠️ 注意事項

- スクリプト実行後は `dart format lib/` 実行推奨
- const/Result 重複追加問題が解決されました ✅

---

## 📚 参考資料 / 参考資料

- [Mockito for Dart](https://pub.dev/packages/mockito)
- [Flutter Testing](https://docs.flutter.dev/testing)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Testing](https://riverpod.dev/docs/cookbooks/testing)

---

© 2025 AI Pet. AI 기능테스트스크립트 / AI Feature Test Scripts

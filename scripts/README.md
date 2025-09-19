# AI Pet Frontend - Scripts / AI Pet Frontend - スクリプト

언어 선택 / Language Selection:

- [한국어](#한국어-korean)
- [日本語](#日本語-japanese)

---

## 한국어 (Korean)

### 📋 개요

이 폴더는 AI Pet Frontend 프로젝트의 개발 및 테스트를 위한 자동화 스크립트들을 포함합니다.

### 🚀 사용 가능한 스크립트

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

#### 4. **Mockito 테스트 실행** (`run_mockito_tests.sh`)

```bash
# 기본 테스트 실행
./scripts/run_mockito_tests.sh

# 커버리지 포함 테스트 실행
./scripts/run_mockito_tests.sh --coverage
```

**Mockito 테스트 스크립트 기능:**

- Mock 파일 자동 생성
- AI 기능별 테스트 실행
- 간단한 Mockito 테스트 (✅ 작동 확인됨)
- AI Repository 테스트
- AI Service 테스트
- AI Controller 테스트
- Mock 데이터 서비스 테스트
- Pet Content Filter 테스트

### 🧪 Mockito 테스트 사용법

#### 기본 사용법

```bash
# 모든 AI Mockito 테스트 실행
./scripts/run_mockito_tests.sh

# 특정 테스트만 실행
flutter test test/unit/features/ai/simple_mockito_test.dart
```

#### 테스트 구조

```
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

### 📊 테스트 결과

#### ✅ 성공한 테스트

- **간단한 Mockito 테스트**: 6개 테스트 모두 통과
- **Mock 파일 생성**: 정상 작동
- **Clean Code 원칙**: 완벽 준수
- **Clean Architecture**: 의존성 역전 원칙 준수

#### ⚠️ 수정 필요한 테스트

- 일부 테스트에서 import 누락 (PetType, PetGender 등)
- Provider 참조 문제 (aiRepositoryProvider, aiChatControllerProvider)
- 엔티티 필드 누락 (gender, ownerId, updatedAt 등)

### 🎯 다음 단계

1. **에러 수정**: import 누락 및 엔티티 필드 문제 해결
2. **Provider 테스트**: Riverpod Provider 테스트 개선
3. **통합 테스트**: 전체 AI 기능 통합 테스트 추가
4. **커버리지 향상**: 테스트 커버리지 90% 이상 달성

---

## 日本語 (Japanese)

### 📋 概要

このフォルダには、AI Pet Frontend プロジェクトの開発とテストのための自動化スクリプトが含まれています。

### 🚀 利用可能なスクリプト

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

#### 4. **Mockito テスト実行** (`run_mockito_tests.sh`)

```bash
# 基本テスト実行
./scripts/run_mockito_tests.sh

# カバレッジ含むテスト実行
./scripts/run_mockito_tests.sh --coverage
```

**Mockito テストスクリプト機能:**

- Mock ファイル自動生成
- AI 機能別テスト実行
- 簡単な Mockito テスト (✅ 動作確認済み)
- AI Repository テスト
- AI Service テスト
- AI Controller テスト
- Mock データサービステスト
- Pet Content Filter テスト

### 🧪 Mockito テスト使用方法

#### 基本使用方法

```bash
# すべてのAI Mockitoテスト実行
./scripts/run_mockito_tests.sh

# 特定のテストのみ実行
flutter test test/unit/features/ai/simple_mockito_test.dart
```

#### テスト構造

```
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

### 📊 テスト結果

#### ✅ 成功したテスト

- **簡単な Mockito テスト**: 6 個のテストすべて通過
- **Mock ファイル生成**: 正常動作
- **Clean Code 原則**: 完全準拠
- **Clean Architecture**: 依存性逆転原則準拠

#### ⚠️ 修正が必要なテスト

- 一部のテストで import 不足 (PetType, PetGender など)
- Provider 参照問題 (aiRepositoryProvider, aiChatControllerProvider)
- エンティティフィールド不足 (gender, ownerId, updatedAt など)

### 🎯 次のステップ

1. **エラー修正**: import 不足とエンティティフィールド問題の解決
2. **Provider テスト**: Riverpod Provider テストの改善
3. **統合テスト**: 全体 AI 機能統合テストの追加
4. **カバレッジ向上**: テストカバレッジ 90%以上達成

---

## 📚 参考資料 / 参考資料

- [Mockito for Dart](https://pub.dev/packages/mockito)
- [Flutter Testing](https://docs.flutter.dev/testing)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Testing](https://riverpod.dev/docs/cookbooks/testing)

---

© 2025 AI Pet. AI 機能テストスクリプト / AI Feature Test Scripts

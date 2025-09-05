# 🏗️ AIPet Frontend - Architecture Guide

<div align="center">
  <h3>🌏 Language Selection</h3>
  <a href="#english-version">English</a> | <a href="#korean-version">한국어</a> | <a href="#japanese-version">日本語</a>
</div>

---

## English Version

### 📋 Overview

This document provides a comprehensive guide to the AIPet Flutter application architecture. The project follows **Clean Architecture** principles with a **Feature-First** organization approach, ensuring scalability, maintainability, and testability.

### 🏛️ Architecture Principles

#### Clean Architecture Layers

```txt
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Screens   │  │ Controllers │  │      Widgets        │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Entities   │  │  Use Cases  │  │   Repositories      │  │
│  │             │  │             │  │   (Interfaces)      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Models    │  │   Services  │  │   Repositories      │  │
│  │             │  │             │  │ (Implementations)   │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 🗂️ Project Structure

```txt
lib/
├── app/                        # 🎯 Application Core
│   ├── config/                 # App configuration
│   ├── controllers/            # Base controllers
│   ├── providers/              # Global state management
│   └── router/                 # Navigation system
│
├── features/                   # 🎨 Feature Modules
│   ├── ai/                     # AI Chat Assistant
│   │   ├── data/              # Data layer
│   │   ├── domain/            # Business logic
│   │   └── presentation/      # UI layer
│   │
│   ├── auth/                   # Authentication
│   ├── home/                   # Home Dashboard
│   ├── pet_profile/            # Pet Management
│   ├── pet_health/             # Health Tracking
│   ├── pet_feeding/            # Feeding Management
│   ├── walk/                   # Activity Tracking
│   ├── facility/               # Facility Finder
│   ├── notification/           # Notifications
│   ├── scheduling/             # Appointments
│   └── settings/               # User Settings
│
└── shared/                     # 🔧 Shared Resources
    ├── config/                 # Global configuration
    ├── constants/              # App constants
    ├── design/                 # Design system
    ├── services/               # Core services
    ├── utils/                  # Utilities
    └── widgets/                # Reusable components
```

### 🎯 Feature Architecture

Each feature follows the same architectural pattern:

#### Data Layer (`/data`)
- **Models**: Data transfer objects and serialization
- **Repositories**: Implementation of domain interfaces
- **Services**: External API communication
- **Providers**: Riverpod state management

#### Domain Layer (`/domain`)
- **Entities**: Core business objects
- **Repositories**: Abstract interfaces
- **Use Cases**: Business logic operations

#### Presentation Layer (`/presentation`)
- **Screens**: UI screens and pages
- **Widgets**: Feature-specific components
- **Controllers**: UI state management

### 🏠 Core Modules

#### 1. App Module ([/app](app/))
- **Purpose**: Application initialization and core infrastructure
- **Components**:
  - Configuration management
  - Base controllers with resource management
  - Global providers
  - Navigation router

#### 2. AI Module ([/features/ai](features/ai/))
- **Purpose**: AI-powered pet consultation system
- **Features**:
  - OpenAI GPT integration
  - Real-time chat interface
  - Pet-specific content filtering
  - Favorites and categorization

#### 3. Home Module ([/features/home](features/home/))
- **Purpose**: Main dashboard and overview
- **Features**:
  - Pet profile management
  - Weather integration
  - Activity summaries
  - Quick actions

#### 4. Authentication Module ([/features/auth](features/auth/))
- **Purpose**: User authentication and security
- **Features**:
  - Firebase Authentication
  - Google Sign-In
  - Token management
  - Security validation

#### 5. Pet Management ([/features/pet_profile](features/pet_profile/))
- **Purpose**: Pet information management
- **Features**:
  - Multi-pet support
  - Profile creation/editing
  - Photo management
  - Medical records

### 🛠️ Technology Stack

#### Core Technologies
- **Flutter**: 3.8.1+ (Cross-platform framework)
- **Dart**: 3.8.1+ (Programming language)
- **Firebase**: Backend-as-a-Service
- **Riverpod**: State management
- **Go Router**: Navigation

#### Key Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.5.1      # State management
  riverpod_annotation: ^2.3.5   # Code generation
  go_router: ^14.6.2            # Navigation
  firebase_core: ^3.15.2        # Firebase core
  firebase_auth: ^5.1.4         # Authentication
  google_sign_in: ^6.2.1        # Google auth
  dio: ^5.4.3+1                 # HTTP client
  geolocator: ^13.0.1           # Location services
  google_maps_flutter: ^2.8.0   # Maps integration
```

### 📱 Development Guidelines

#### Code Organization
1. **Feature-First**: Organize by business capabilities
2. **Layer Separation**: Clear boundaries between layers
3. **Dependency Rule**: Dependencies point inward only
4. **Single Responsibility**: Each class has one reason to change

#### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`

#### State Management
```dart
// Riverpod Provider Example
@riverpod
class HomeController extends _$HomeController {
  @override
  HomeState build() => const HomeState.initial();
  
  Future<void> loadPetData() async {
    // Business logic implementation
  }
}
```

### 🧪 Testing Strategy

#### Test Types
- **Unit Tests**: Business logic and utilities
- **Widget Tests**: UI components and screens
- **Integration Tests**: Feature workflows

#### Test Structure
```txt
test/
├── unit/                       # Unit tests
│   ├── features/              # Feature-specific tests
│   └── shared/                # Shared component tests
├── widget/                     # Widget tests
└── integration/                # Integration tests
```

### 🚀 Build and Deployment

#### Development Commands
```bash
# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build

# Run tests
flutter test

# Run app
flutter run
```

#### Environment Configuration
```bash
# Development
flutter run --flavor development

# Staging
flutter run --flavor staging

# Production
flutter run --flavor production
```

---

## Korean Version

### 📋 개요

이 문서는 AIPet Flutter 애플리케이션 아키텍처에 대한 포괄적인 가이드를 제공합니다. 이 프로젝트는 확장성, 유지보수성, 테스트 가능성을 보장하는 **기능 우선** 조직 접근 방식과 함께 **클린 아키텍처** 원칙을 따릅니다.

### 🏛️ 아키텍처 원칙

#### 클린 아키텍처 레이어

```txt
┌─────────────────────────────────────────────────────────────┐
│                   프레젠테이션 레이어                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │    화면     │  │  컨트롤러    │  │       위젯         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     도메인 레이어                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   엔티티    │  │ 유즈케이스   │  │    리포지토리       │  │
│  │             │  │             │  │   (인터페이스)      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     데이터 레이어                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │    모델     │  │   서비스    │  │    리포지토리       │  │
│  │             │  │             │  │      (구현)        │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 🗂️ 프로젝트 구조

```txt
lib/
├── app/                        # 🎯 애플리케이션 핵심
│   ├── config/                 # 앱 구성
│   ├── controllers/            # 기본 컨트롤러
│   ├── providers/              # 전역 상태 관리
│   └── router/                 # 내비게이션 시스템
│
├── features/                   # 🎨 기능 모듈
│   ├── ai/                     # AI 채팅 어시스턴트
│   │   ├── data/              # 데이터 레이어
│   │   ├── domain/            # 비즈니스 로직
│   │   └── presentation/      # UI 레이어
│   │
│   ├── auth/                   # 인증
│   ├── home/                   # 홈 대시보드
│   ├── pet_profile/            # 펫 관리
│   ├── pet_health/             # 건강 추적
│   ├── pet_feeding/            # 급식 관리
│   ├── walk/                   # 활동 추적
│   ├── facility/               # 시설 찾기
│   ├── notification/           # 알림
│   ├── scheduling/             # 예약
│   └── settings/               # 사용자 설정
│
└── shared/                     # 🔧 공유 리소스
    ├── config/                 # 전역 구성
    ├── constants/              # 앱 상수
    ├── design/                 # 디자인 시스템
    ├── services/               # 핵심 서비스
    ├── utils/                  # 유틸리티
    └── widgets/                # 재사용 가능한 컴포넌트
```

### 🎯 기능 아키텍처

각 기능은 동일한 아키텍처 패턴을 따릅니다:

#### 데이터 레이어 (`/data`)
- **모델**: 데이터 전송 객체 및 직렬화
- **리포지토리**: 도메인 인터페이스 구현
- **서비스**: 외부 API 통신
- **프로바이더**: Riverpod 상태 관리

#### 도메인 레이어 (`/domain`)
- **엔티티**: 핵심 비즈니스 객체
- **리포지토리**: 추상 인터페이스
- **유즈케이스**: 비즈니스 로직 작업

#### 프레젠테이션 레이어 (`/presentation`)
- **화면**: UI 화면 및 페이지
- **위젯**: 기능별 컴포넌트
- **컨트롤러**: UI 상태 관리

### 🏠 핵심 모듈

#### 1. 앱 모듈 ([/app](app/))
- **목적**: 애플리케이션 초기화 및 핵심 인프라
- **구성 요소**:
  - 구성 관리
  - 리소스 관리가 포함된 기본 컨트롤러
  - 전역 프로바이더
  - 내비게이션 라우터

#### 2. AI 모듈 ([/features/ai](features/ai/))
- **목적**: AI 기반 펫 상담 시스템
- **기능**:
  - OpenAI GPT 통합
  - 실시간 채팅 인터페이스
  - 펫 전용 콘텐츠 필터링
  - 즐겨찾기 및 분류

---

## Japanese Version

### 📋 概要

この文書は、AIPet Flutter アプリケーションアーキテクチャの包括的なガイドを提供します。このプロジェクトは、拡張性、保守性、テスト可能性を確保する**機能優先**組織アプローチと共に**クリーンアーキテクチャ**原則に従います。

### 🏛️ アーキテクチャ原則

#### クリーンアーキテクチャレイヤー

```txt
┌─────────────────────────────────────────────────────────────┐
│                プレゼンテーション層                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   画面      │  │コントローラー│  │     ウィジェット     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    ドメイン層                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ エンティティ │  │ユースケース │  │   リポジトリ        │  │
│  │             │  │             │  │ (インターフェース)  │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     データ層                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   モデル    │  │  サービス   │  │   リポジトリ        │  │
│  │             │  │             │  │     (実装)         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 🗂️ プロジェクト構造

```txt
lib/
├── app/                        # 🎯 アプリケーションコア
│   ├── config/                 # アプリ設定
│   ├── controllers/            # ベースコントローラー
│   ├── providers/              # グローバル状態管理
│   └── router/                 # ナビゲーションシステム
│
├── features/                   # 🎨 機能モジュール
│   ├── ai/                     # AIチャットアシスタント
│   │   ├── data/              # データ層
│   │   ├── domain/            # ビジネスロジック
│   │   └── presentation/      # UI層
│   │
│   ├── auth/                   # 認証
│   ├── home/                   # ホームダッシュボード
│   ├── pet_profile/            # ペット管理
│   ├── pet_health/             # 健康追跡
│   ├── pet_feeding/            # 給餌管理
│   ├── walk/                   # 活動追跡
│   ├── facility/               # 施設検索
│   ├── notification/           # 通知
│   ├── scheduling/             # 予約
│   └── settings/               # ユーザー設定
│
└── shared/                     # 🔧 共有リソース
    ├── config/                 # グローバル設定
    ├── constants/              # アプリ定数
    ├── design/                 # デザインシステム
    ├── services/               # コアサービス
    ├── utils/                  # ユーティリティ
    └── widgets/                # 再利用可能なコンポーネント
```

### 🎯 機能アーキテクチャ

各機能は同じアーキテクチャパターンに従います：

#### データ層 (`/data`)
- **モデル**: データ転送オブジェクトとシリアライゼーション
- **リポジトリ**: ドメインインターフェースの実装
- **サービス**: 外部API通信
- **プロバイダー**: Riverpod状態管理

#### ドメイン層 (`/domain`)
- **エンティティ**: コアビジネスオブジェクト
- **リポジトリ**: 抽象インターフェース
- **ユースケース**: ビジネスロジック操作

#### プレゼンテーション層 (`/presentation`)
- **画面**: UI画面とページ
- **ウィジェット**: 機能固有のコンポーネント
- **コントローラー**: UI状態管理

---

<div align="center">
  <p>📚 For detailed information about each module, see the individual README files in each directory.</p>
  <p>각 모듈에 대한 자세한 정보는 각 디렉토리의 개별 README 파일을 참조하세요.</p>
  <p>各モジュールの詳細情報については、各ディレクトリの個別README ファイルを参照してください。</p>
</div>
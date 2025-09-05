# 🐾 AIPet Frontend

## 🎯 프로젝트 개요

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://riverpod.dev)

## 🌏 언어 / Languages

[English](#english-version) | [한국어](#한국어-버전) | [日本語](#日本語版)

---

## English Version

### 📱 About AIPet

AIPet is an intelligent pet management application built with Flutter that helps
pet owners track, manage, and care for their pets using AI-powered features. The
app provides comprehensive pet care solutions including health monitoring,
activity tracking, feeding management, and AI-powered veterinary assistance.

### 🚀 Features

#### Core Features

- **🐕 Pet Profile Management**: Comprehensive pet profiles with photos, breed
  info, and medical history
- **🏥 Health Monitoring**: Track vaccinations, medications, and health records
- **🚶 Activity Tracking**: Monitor walks, exercise, and daily activities with
  GPS integration
- **🍽️ Feeding Management**: Track meals, feeding schedules, and nutrition
- **📅 Smart Scheduling**: Automated reminders for meals, medications, and
  appointments
- **🤖 AI Veterinary Assistant**: Get instant answers about pet health and
  behavior
- **📍 Location Services**: Find nearby veterinary clinics and pet services
- **📊 Analytics & Reports**: Comprehensive health and activity reports

#### Advanced Features

- **🔔 Smart Notifications**: Context-aware reminders and alerts
- **📱 Cross-platform Sync**: Seamless data synchronization across devices
- **🏪 Facility Finder**: Locate pet-friendly facilities and services
- **📈 Health Insights**: AI-powered health trend analysis
- **🎯 Goal Setting**: Set and track pet care goals
- **📋 Medical Records**: Digital health passport for your pet

### 🏗️ Architecture

The application follows **Clean Architecture** principles with **Feature-First**
organization:

```txt
lib/
├── app/                        # Application layer
│   ├── config/                 # App configuration
│   ├── controllers/            # Base controllers
│   ├── providers/              # Global providers
│   └── router/                 # Navigation routing
├── features/                   # Feature modules
│   ├── auth/                   # Authentication
│   ├── home/                   # Home dashboard
│   ├── pet_profile/            # Pet management
│   ├── pet_health/             # Health tracking
│   ├── walk/                   # Activity tracking
│   ├── ai/                     # AI assistant
│   └── ...                     # Other features
└── shared/                     # Shared resources
    ├── design/                 # Design tokens
    ├── services/               # Core services
    ├── widgets/                # Reusable widgets
    └── utils/                  # Utilities
```

### 🛠️ Technology Stack

- **Framework**: Flutter 3.8.1+
- **Language**: Dart
- **State Management**: Riverpod 2.5+
- **Navigation**: Go Router 14.6+
- **Backend**: Firebase (Auth, Firestore, Cloud Functions)
- **Maps**: Google Maps Flutter
- **Charts**: FL Chart
- **Animations**: Lottie
- **HTTP Client**: Dio
- **Local Storage**: Shared Preferences, Secure Storage

### 🚦 Getting Started

#### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code
- Firebase account
- Google Maps API key

#### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-org/aipet_frontend.git
   cd aipet_frontend
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Create a Firebase project
   - Add Android/iOS apps to your Firebase project
   - Download and add `google-services.json` (Android) and
     `GoogleService-Info.plist` (iOS)

4. **Set up environment variables**

   ```bash
   cp .env.example .env
   # Edit .env with your API keys
   ```

5. **Generate code**

   ```bash
   flutter pub run build_runner build
   ```

6. **Run the app**

   ```bash
   flutter run
   ```

### 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- 🔄 Web (In development)

### 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run widget tests only
flutter test test/widget/

# Run unit tests only
flutter test test/unit/
```

### 📚 Documentation

- [Architecture Guide](lib/README.md)
- [API Documentation](docs/API.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

### 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md)
for details.

### 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file
for details.

---

## 한국어 버전

### 📱 AIPet 소개

AIPet은 Flutter로 구축된 지능형 반려동물 관리 애플리케이션으로, AI 기반 기능을
통해 반려동물 소유자가 반려동물을 추적, 관리, 돌볼 수 있도록 도와줍니다. 건강
모니터링, 활동 추적, 급식 관리, AI 기반 수의학 지원을 포함한 종합적인 반려동물
케어 솔루션을 제공합니다.

### 🚀 주요 기능

#### 핵심 기능

- **🐕 반려동물 프로필 관리**: 사진, 품종 정보, 의료 기록이 포함된 종합적인
  반려동물 프로필
- **🏥 건강 모니터링**: 예방접종, 약물, 건강 기록 추적
- **🚶 활동 추적**: GPS 통합을 통한 산책, 운동, 일일 활동 모니터링
- **🍽️ 급식 관리**: 식사, 급식 일정, 영양 추적
- **📅 스마트 스케줄링**: 식사, 약물, 약속에 대한 자동 알림
- **🤖 AI 수의학 도우미**: 반려동물 건강 및 행동에 대한 즉각적인 답변 제공
- **📍 위치 서비스**: 인근 수의과 및 반려동물 서비스 찾기
- **📊 분석 및 보고서**: 종합적인 건강 및 활동 보고서

#### 고급 기능

- **🔔 스마트 알림**: 상황 인식 기반 알림 및 경고
- **📱 크로스 플랫폼 동기화**: 기기 간 원활한 데이터 동기화
- **🏪 시설 찾기**: 반려동물 친화적인 시설 및 서비스 위치 찾기
- **📈 건강 인사이트**: AI 기반 건강 트렌드 분석
- **🎯 목표 설정**: 반려동물 관리 목표 설정 및 추적
- **📋 의료 기록**: 반려동물을 위한 디지털 건강 패스포트

### 🏗️ 아키텍처

애플리케이션은 **기능 우선** 조직과 함께 **클린 아키텍처** 원칙을 따릅니다:

```txt
lib/
├── app/                        # 애플리케이션 레이어
│   ├── config/                 # 앱 구성
│   ├── controllers/            # 기본 컨트롤러
│   ├── providers/              # 글로벌 프로바이더
│   └── router/                 # 네비게이션 라우팅
├── features/                   # 기능 모듈
│   ├── auth/                   # 인증
│   ├── home/                   # 홈 대시보드
│   ├── pet_profile/            # 반려동물 관리
│   ├── pet_health/             # 건강 추적
│   ├── walk/                   # 활동 추적
│   ├── ai/                     # AI 어시스턴트
│   └── ...                     # 기타 기능
└── shared/                     # 공유 리소스
    ├── design/                 # 디자인 토큰
    ├── services/               # 핵심 서비스
    ├── widgets/                # 재사용 가능한 위젯
    └── utils/                  # 유틸리티
```

### 🛠️ 기술 스택

- **프레임워크**: Flutter 3.8.1+
- **언어**: Dart
- **상태 관리**: Riverpod 2.5+
- **네비게이션**: Go Router 14.6+
- **백엔드**: Firebase (Auth, Firestore, Cloud Functions)
- **지도**: Google Maps Flutter
- **차트**: FL Chart
- **애니메이션**: Lottie
- **HTTP 클라이언트**: Dio
- **로컬 저장소**: Shared Preferences, Secure Storage

### 🚦 시작하기

#### 필수 조건

- Flutter SDK 3.8.1 이상
- Dart SDK 3.8.1 이상
- Android Studio / VS Code
- Firebase 계정
- Google Maps API 키

#### 설치

1. **저장소 복제**

   ```bash
   git clone https://github.com/your-org/aipet_frontend.git
   cd aipet_frontend
   ```

2. **의존성 설치**

   ```bash
   flutter pub get
   ```

3. **Firebase 구성**

   - Firebase 프로젝트 생성
   - Firebase 프로젝트에 Android/iOS 앱 추가
   - `google-services.json` (Android)과 `GoogleService-Info.plist` (iOS)
     다운로드 및 추가

4. **환경 변수 설정**

   ```bash
   cp .env.example .env
   # API 키로 .env 편집
   ```

5. **코드 생성**

   ```bash
   flutter pub run build_runner build
   ```

6. **앱 실행**

   ```bash
   flutter run
   ```

### 📱 지원 플랫폼

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- 🔄 Web (개발 중)

---

## 日本語版

### 📱 AIPet について

AIPet は、Flutter で構築されたインテリジェントなペット管理アプリケーションで、
AI 駆動機能を使用してペットオーナーがペットを追跡、管理、世話することを
支援します。健康モニタリング、活動追跡、給餌管理、AI 搭載獣医アシスタンスを
含む包括的なペットケアソリューションを提供します。

### 🚀 主な機能

#### コア機能

- **🐕 ペットプロフィール管理**: 写真、品種情報、医療履歴を含む包括的な
  ペットプロフィール
- **🏥 健康モニタリング**: ワクチン接種、薬物、健康記録の追跡
- **🚶 活動追跡**: GPS 統合による散歩、運動、日常活動のモニタリング
- **🍽️ 給餌管理**: 食事、給餌スケジュール、栄養の追跡
- **📅 スマートスケジューリング**: 食事、薬物、予定の自動リマインダー
- **🤖 AI 獣医アシスタント**: ペットの健康と行動について即座に回答
- **📍 ロケーションサービス**: 近くの獣医クリニックとペットサービスの検索
- **📊 分析とレポート**: 包括的な健康と活動レポート

#### 高度な機能

- **🔔 スマート通知**: コンテキスト認識リマインダーとアラート
- **📱 クロスプラットフォーム同期**: デバイス間のシームレスなデータ同期
- **🏪 施設検索**: ペットフレンドリーな施設とサービスの位置検索
- **📈 健康インサイト**: AI 搭載健康トレンド分析
- **🎯 目標設定**: ペットケア目標の設定と追跡
- **📋 医療記録**: ペット用デジタルヘルスパスポート

### 🏗️ アーキテクチャ

アプリケーションは**フィーチャーファースト**組織で**クリーンアーキテクチャ**
原則に従います：

```txt
lib/
├── app/                        # アプリケーション層
│   ├── config/                 # アプリ設定
│   ├── controllers/            # ベースコントローラー
│   ├── providers/              # グローバルプロバイダー
│   └── router/                 # ナビゲーションルーティング
├── features/                   # フィーチャーモジュール
│   ├── auth/                   # 認証
│   ├── home/                   # ホームダッシュボード
│   ├── pet_profile/            # ペット管理
│   ├── pet_health/             # 健康追跡
│   ├── walk/                   # 活動追跡
│   ├── ai/                     # AIアシスタント
│   └── ...                     # その他の機能
└── shared/                     # 共有リソース
    ├── design/                 # デザイントークン
    ├── services/               # コアサービス
    ├── widgets/                # 再利用可能なウィジェット
    └── utils/                  # ユーティリティ
```

### 🛠️ 技術スタック

- **フレームワーク**: Flutter 3.8.1+
- **言語**: Dart
- **状態管理**: Riverpod 2.5+
- **ナビゲーション**: Go Router 14.6+
- **バックエンド**: Firebase (Auth, Firestore, Cloud Functions)
- **地図**: Google Maps Flutter
- **チャート**: FL Chart
- **アニメーション**: Lottie
- **HTTP クライアント**: Dio
- **ローカルストレージ**: Shared Preferences, Secure Storage

### 🚦 はじめに

#### 必要条件

- Flutter SDK 3.8.1 以上
- Dart SDK 3.8.1 以上
- Android Studio / VS Code
- Firebase アカウント
- Google Maps API キー

#### インストール

1. **リポジトリのクローン**

   ```bash
   git clone https://github.com/your-org/aipet_frontend.git
   cd aipet_frontend
   ```

2. **依存関係のインストール**

   ```bash
   flutter pub get
   ```

3. **Firebase の設定**

   - Firebase プロジェクトの作成
   - Firebase プロジェクトに Android/iOS アプリを追加
   - `google-services.json`（Android）と`GoogleService-Info.plist`
     （iOS）をダウンロードして追加

4. **環境変数の設定**

   ```bash
   cp .env.example .env
   # APIキーで.envを編集
   ```

5. **コード生成**

   ```bash
   flutter pub run build_runner build
   ```

6. **アプリの実行**

   ```bash
   flutter run
   ```

### 📱 サポートプラットフォーム

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- 🔄 Web (開発中)

### 🧪 テスト

```bash
# 全テスト実行
flutter test

# カバレッジ付きテスト実行
flutter test --coverage

# ウィジェットテストのみ実行
flutter test test/widget/

# ユニットテストのみ実行
flutter test test/unit/
```

### 📚 ドキュメント

- [アーキテクチャガイド](lib/README.md)
- [API 文書](docs/API.md)
- [貢献ガイドライン](CONTRIBUTING.md)
- [デプロイメントガイド](docs/DEPLOYMENT.md)

### 🤝 貢献

貢献を歓迎します！詳細については[貢献ガイドライン](CONTRIBUTING.md)をご覧
ください。

### 📄 ライセンス

このプロジェクトは MIT ライセンスの下でライセンスされています - 詳細について
は[LICENSE](LICENSE)ファイルをご覧ください。

---

## ❤️ Made with love by the AIPet Team

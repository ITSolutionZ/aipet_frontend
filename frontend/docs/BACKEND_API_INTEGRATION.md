# バックエンドAPI 連携ガイド

AIPet Frontend と Backend の API 連携に関する完全ガイド

## 📋 目次

1. [概要](#概要)
2. [API サービス構成](#apiサービス構成)
3. [使用方法](#使用方法)
4. [テスト方法](#テスト方法)
5. [トラブルシューティング](#トラブルシューティング)

## 概要

### 完成した API サービス

| 機能 | サービスファイル | 状態 | Repository 連携 |
|------|----------------|------|----------------|
| **認証** | `api_auth_service.dart` | ✅ 更新完了 | - |
| **ペット** | `backend_pet_api_service.dart` | ✅ 実装済み | ✅ 完了 |
| **散歩** | `backend_walk_api_service.dart` | ✅ 実装済み | ✅ 完了 |
| **散歩 (Wrapper)** | `walk_api_service_backend.dart` | ✅ 実装済み | ✅ 完了 |
| **健康** | `backend_health_api_service.dart` | ✅ 実装済み | ✅ 完了 |
| **給餌** | `backend_feeding_api_service.dart` | ✅ 実装済み | ✅ 完了 |
| **通知** | `backend_notification_api_service.dart` | ✅ 実装済み | ✅ 完了 |
| **スケジュール** | `backend_schedule_api_service.dart` | ✅ 実装済み | ✅ 完了 |

### Repository 層連携状態 (2025-11-12 更新)

すべての主要機能で Backend API への移行が完了しました:

- ✅ **Pet Health Repository** - Backend API 完全連携
  - 予防接種記録 CRUD
  - 体重履歴 (取得/作成のみ、更新/削除は Backend 未対応)
- ✅ **Pet Feeding Repository** - Backend API 完全連携
- ✅ **Notification Repository** - Backend API 完全連携 (キャッシュサービス統合)
- ✅ **Walk Repository** - Backend API 完全連携
- ✅ **Schedule Repository** - Backend API 完全連携

### バックエンド API エンドポイント

```
Base URL: http://localhost:3000/api
```

#### 認証
- `POST /firebase-auth/login` - Firebase ID Token 交換

#### ペット
- `GET /pets` - ペット一覧取得
- `GET /pets/:id` - ペット詳細取得
- `POST /pets` - ペット作成
- `PUT /pets/:id` - ペット更新
- `DELETE /pets/:id` - ペット削除

#### 散歩
- `GET /walks` - ユーザーの散歩記録一覧
- `GET /walks/:id` - 散歩記録詳細
- `GET /pets/:petId/walks` - ペット別散歩記録
- `GET /pets/:petId/walks/statistics` - ペット別統計
- `GET /walks/statistics/user` - ユーザー全体統計
- `POST /walks` - 散歩記録作成
- `PUT /walks/:id` - 散歩記録更新
- `DELETE /walks/:id` - 散歩記録削除

#### 健康記録

**予防接種 (Vaccinations)**:

- `GET /pets/:petId/vaccinations` - ペットの予防接種記録一覧
- `GET /pets/:petId/vaccinations/:vaccinationId` - 予防接種記録詳細
- `POST /pets/:petId/vaccinations` - 予防接種記録作成
- `PUT /pets/:petId/vaccinations/:vaccinationId` - 予防接種記録更新
- `DELETE /pets/:petId/vaccinations/:vaccinationId` - 予防接種記録削除

**体重履歴 (Weight History)**:

- `GET /pets/:petId/weight-history` - ペットの体重履歴
- `POST /pets/:petId/weight-history` - 体重記録作成
- ⚠️ 体重記録の更新・削除エンドポイントは未対応

**医療記録 (Medical Records)**:

- `GET /pets/:petId/medical-records` - ペットの医療記録一覧
- `GET /pets/:petId/medical-records/:recordId` - 医療記録詳細
- `POST /pets/:petId/medical-records` - 医療記録作成
- `PUT /pets/:petId/medical-records/:recordId` - 医療記録更新
- `DELETE /pets/:petId/medical-records/:recordId` - 医療記録削除

#### スケジュール

- `GET /schedules` - ユーザーのスケジュール一覧
- `GET /schedules/:id` - スケジュール詳細
- `GET /pets/:petId/schedules` - ペット別スケジュール
- `GET /schedules/upcoming/list` - 予定されているスケジュール
- `GET /schedules/completed/list` - 完了したスケジュール
- `POST /schedules` - スケジュール作成
- `PUT /schedules/:id` - スケジュール更新
- `PATCH /schedules/:id/complete` - スケジュール完了
- `DELETE /schedules/:id` - スケジュール削除

#### 給餌 (Feeding)

- `GET /pets/:petId/feeding-records` - ペットの給餌記録一覧
- `GET /pets/:petId/feeding-records/:recordId` - 給餌記録詳細
- `GET /pets/:petId/feeding-records/stats` - 給餌統計
- `POST /pets/:petId/feeding-records` - 給餌記録作成
- `PUT /pets/:petId/feeding-records/:recordId` - 給餌記録更新
- `DELETE /pets/:petId/feeding-records/:recordId` - 給餌記録削除

#### 通知 (Notifications)

- `GET /notifications` - ユーザーの通知一覧
- `GET /notifications/unread/count` - 未読通知数
- `PATCH /notifications/:notificationId/read` - 通知を既読にする
- `DELETE /notifications/:notificationId` - 通知削除

## API サービス構成

### 認証フロー

```dart
// Firebase ID Token 取得
final user = FirebaseAuth.instance.currentUser;
final idToken = await user?.getIdToken();

// BackendApiClient が自動的に Authorization ヘッダーに追加
// すべてのAPIリクエストに Firebase ID Token が含まれます
```

### ペット API 使用例

```dart
import 'package:aipet_frontend/features/pet_profile/data/services/backend_pet_api_service.dart';

// ペット作成
final result = await BackendPetApiService.createPet(
  PetProfileEntity(
    id: '',
    name: 'ポチ',
    type: 'dog',
    breed: '柴犬',
    birthDate: DateTime(2020, 1, 1),
    gender: 'male',
    weight: 10.5,
    ownerId: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
);

if (result.isSuccess) {
  print('ペット作成成功: ${result.data!.name}');
} else {
  print('エラー: ${result.message}');
}

// ペット一覧取得
final listResult = await BackendPetApiService.getAllPets();
if (listResult.isSuccess) {
  for (final pet in listResult.data!) {
    print('${pet.name} (${pet.type})');
  }
}
```

### 散歩 API 使用例

```dart
import 'package:aipet_frontend/features/walk/data/services/backend_walk_api_service.dart';

// 散歩記録作成
final result = await BackendWalkApiService.createWalk(
  petId: 'pet-id-123',
  startTime: DateTime.now(), // DateTime型
  durationMinutes: 30, // 30分
  distanceMeters: 2500, // 2.5km = 2500m
  notes: '公園を散歩',
);

if (result.isSuccess) {
  print('散歩記録作成成功: ${result.data!['id']}');
}

// 散歩記録更新
final updateResult = await BackendWalkApiService.updateWalk(
  petId: 'pet-id-123',
  walkId: 'walk-id-456',
  endTime: DateTime.now(),
  distanceMeters: 3000, // 3km
  notes: '公園と川沿いを散歩',
);

// ペットの散歩統計取得
final statsResult = await BackendWalkApiService.getWalkStats(petId: 'pet-id-123');
if (statsResult.isSuccess) {
  final stats = statsResult.data!;
  print('総散歩回数: ${stats['total_walks']}');
  print('総距離: ${stats['total_distance']} km');
  print('平均時間: ${stats['average_duration']} 秒');
}
```

### 健康記録 API 使用例

```dart
import 'package:aipet_frontend/features/pet_health/data/services/backend_health_api_service.dart';

// 予防接種記録作成
final result = await BackendHealthApiService.createVaccination(
  petId: 'pet-id-123',
  vaccineName: '狂犬病ワクチン',
  vaccinationDate: DateTime.now(),
  nextDueDate: DateTime.now().add(const Duration(days: 365)),
  veterinarianName: 'ペットクリニック ABC',
  notes: '年次予防接種',
);

if (result.isSuccess) {
  print('予防接種記録作成成功: ${result.data!['id']}');
}

// ペットの予防接種記録一覧取得
final vaccinationsResult = await BackendHealthApiService.getVaccinations(petId: 'pet-id-123');
if (vaccinationsResult.isSuccess) {
  for (final vaccination in vaccinationsResult.data!) {
    print('${vaccination['vaccineName']}: ${vaccination['vaccinationDate']}');
  }
}

// 体重記録作成
final weightResult = await BackendHealthApiService.createWeightRecord(
  petId: 'pet-id-123',
  weight: 12.5,
  measuredAt: DateTime.now(),
  notes: '定期検診',
);

if (weightResult.isSuccess) {
  print('体重記録作成成功: ${weightResult.data!['weight']} kg');
}

// 体重履歴取得
final historyResult = await BackendHealthApiService.getWeightHistory(petId: 'pet-id-123');
if (historyResult.isSuccess) {
  for (final record in historyResult.data!) {
    print('${record['measuredAt']}: ${record['weight']} kg');
  }
}
```

### スケジュール API 使用例

```dart
import 'package:aipet_frontend/features/scheduling/data/services/backend_schedule_api_service.dart';

// スケジュール作成
final result = await BackendScheduleApiService.createSchedule(
  petId: 'pet-id-123',
  title: '朝のごはん',
  scheduleType: 'feeding',
  scheduledTime: DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
  notes: 'ドッグフード 200g',
);

if (result.isSuccess) {
  print('スケジュール作成成功: ${result.data!['id']}');
}

// 予定されているスケジュール取得
final upcomingResult = await BackendScheduleApiService.getUpcomingSchedules(daysAhead: 7);
if (upcomingResult.isSuccess) {
  for (final schedule in upcomingResult.data!) {
    print('${schedule['title']}: ${schedule['scheduled_time']}');
  }
}

// スケジュール完了
final completeResult = await BackendScheduleApiService.completeSchedule('schedule-id-123');
if (completeResult.isSuccess) {
  print('スケジュール完了');
}
```

## 使用方法

### 1. バックエンドサーバー起動

```bash
cd /path/to/aipet_backend
npm run dev
```

サーバーが `http://localhost:3000` で起動します。

### 2. Flutter アプリ実行

```bash
cd /path/to/aipet_frontend
flutter run
```

### 3. API テスト画面でテスト

アプリ内で:
1. 設定画面を開く
2. "開発者ツール" セクションを見つける (デバッグモードのみ)
3. "バックエンドAPI テスト" をタップ
4. "全テスト実行" または個別のテストボタンをタップ

## テスト方法

### オプション 1: API テスト画面 (推奨)

```dart
// 設定画面から API テスト画面に移動
context.push(RouteConstants.apiTestRoute);
```

テスト画面では以下をテストできます:
- Firebase 認証状態確認
- ペット CRUD 操作
- 散歩記録作成・統計
- 健康記録管理
- スケジュール管理

### オプション 2: 統合テスト

```bash
flutter test test/integration/backend_api_integration_test.dart
```

### オプション 3: ターミナルから基本テスト

```bash
./scripts/test_backend_api.sh
```

## トラブルシューティング

### 1. バックエンドサーバーに接続できない

**症状**: `ネットワーク接続を確認してください` エラー

**解決方法**:
```bash
# バックエンドサーバーが起動しているか確認
curl http://localhost:3000/health

# サーバーが起動していない場合
cd /path/to/aipet_backend
npm run dev
```

### 2. 認証エラー (401)

**症状**: `認証に失敗しました` エラー

**解決方法**:
- Firebase でログインしているか確認
- Firebase ID Token が期限切れの可能性 → 再ログイン
- バックエンドの Firebase 設定を確認

```dart
// Firebase ログイン状態確認
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  // ログインが必要
}
```

### 3. API レスポンスが空

**症状**: データが返ってこない

**解決方法**:
```bash
# バックエンドログを確認
cd /path/to/aipet_backend
# サーバーログでエラーをチェック

# データベース確認
mysql -u root -p aipet
SELECT * FROM pets;
SELECT * FROM walk_records;
```

### 4. CORS エラー

**症状**: ブラウザで CORS エラー

**解決方法**:
バックエンドの `.env` ファイルを確認:
```env
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

## エラーハンドリング

すべての API サービスは統一されたエラーハンドリングを実装:

```dart
final result = await BackendPetApiService.getAllPets();

if (result.isSuccess) {
  // 成功
  final pets = result.data!;
  print('ペット数: ${pets.length}');
} else {
  // 失敗
  print('エラー: ${result.message}');

  // ユーザーにエラーメッセージ表示
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result.message)),
  );
}
```

## 既知の制限事項 (2025-11-12 更新)

### Backend API 未対応機能

1. **体重記録の更新・削除**
   - `PUT /pets/:petId/weight-history/:weightId` - 未実装
   - `DELETE /pets/:petId/weight-history/:weightId` - 未実装
   - 現在: 取得と作成のみ対応

2. **通知設定管理**
   - 通知設定の取得・更新エンドポイントなし
   - 現在: ローカルキャッシュのみ使用

3. **通知統計**
   - 総通知数、既読数などの統計エンドポイントなし
   - 現在: 未読数のみ取得可能

### Frontend 側の対応

```dart
// 体重記録更新 - Backend 未対応のため一時的に元の値を返す
@override
Future<WeightRecordEntity> updateWeightRecord(WeightRecordEntity record) async {
  LoggerService.warning('⚠️ 体重記録更新は Backend API で未対応');
  return record; // 一時的な対応
}

// 体重記録削除 - Backend 未対応のため例外スロー
@override
Future<void> deleteWeightRecord(String petId, String recordId) async {
  throw UnimplementedError('体重記録削除機能は未実装です');
}
```

## 次のステップ

1. **✅ Repository 層の統合** - 完了 (2025-11-12)
   - すべての主要機能で Backend API Service を使用

2. **Backend API 機能拡張**
   - 体重記録の更新・削除エンドポイント追加
   - 通知設定管理エンドポイント追加
   - 通知統計エンドポイント追加

3. **オフライン対応**
   - ローカルキャッシュとの同期
   - オフライン時の動作改善
   - 同期キューの実装

4. **エラーハンドリング強化**
   - ネットワークエラーの詳細処理
   - リトライロジック実装
   - タイムアウト設定の最適化

5. **パフォーマンス最適化**
   - API レスポンスキャッシュ
   - バッチリクエスト実装
   - ページネーション対応

## 参考リンク

- [バックエンド README](/path/to/aipet_backend/README.md)
- [Flutter アプリ CLAUDE.md](../CLAUDE.md)
- [API テスト画面](lib/features/dev_tools/screens/api_test_screen.dart)

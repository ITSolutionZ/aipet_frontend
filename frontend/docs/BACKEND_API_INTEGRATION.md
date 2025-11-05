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

| 機能 | サービスファイル | 状態 |
|------|----------------|------|
| **認証** | `api_auth_service.dart` | ✅ 更新完了 |
| **ペット** | `backend_pet_api_service.dart` | ✅ 実装済み |
| **散歩** | `backend_walk_api_service.dart` | ✅ 新規作成 |
| **散歩 (Wrapper)** | `walk_api_service_backend.dart` | ✅ 新規作成 |
| **健康** | `backend_health_api_service.dart` | ✅ 新規作成 |
| **スケジュール** | `backend_schedule_api_service.dart` | ✅ 新規作成 |

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
- `GET /health/:recordId` - 健康記録詳細
- `GET /pets/:petId/health` - ペットの健康記録一覧
- `GET /pets/:petId/health/:recordType` - タイプ別健康記録
- `GET /health/schedules/upcoming` - 予定されている健康スケジュール
- `POST /health` - 健康記録作成
- `PUT /health/:recordId` - 健康記録更新
- `DELETE /health/:recordId` - 健康記録削除

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
  startTime: DateTime.now().toIso8601String(),
  duration: 1800, // 30分 (秒)
  distance: 2.5, // 2.5km
  notes: '公園を散歩',
);

if (result.isSuccess) {
  print('散歩記録作成成功: ${result.data!['id']}');
}

// ペットの散歩統計取得
final statsResult = await BackendWalkApiService.getPetWalkStatistics('pet-id-123');
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

// 健康記録作成 (ワクチン接種)
final result = await BackendHealthApiService.createHealthRecord(
  petId: 'pet-id-123',
  recordType: 'vaccination',
  recordDate: DateTime.now().toIso8601String().split('T')[0],
  vetName: 'ペットクリニック ABC',
  notes: '狂犬病ワクチン接種',
  nextScheduledDate: DateTime.now()
      .add(const Duration(days: 365))
      .toIso8601String()
      .split('T')[0],
);

if (result.isSuccess) {
  print('健康記録作成成功: ${result.data!['id']}');
}

// ペットの健康記録一覧取得
final recordsResult = await BackendHealthApiService.getPetHealthRecords('pet-id-123');
if (recordsResult.isSuccess) {
  for (final record in recordsResult.data!) {
    print('${record['record_type']}: ${record['record_date']}');
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

## 次のステップ

1. **Repository 層の統合**
   - 各機能の Repository で Backend API Service を使用

2. **オフライン対応**
   - ローカルキャッシュとの同期
   - オフライン時の動作改善

3. **エラーハンドリング強化**
   - ネットワークエラーの詳細処理
   - リトライロジック実装

4. **パフォーマンス最適化**
   - API レスポンスキャッシュ
   - バッチリクエスト実装

## 参考リンク

- [バックエンド README](/path/to/aipet_backend/README.md)
- [Flutter アプリ CLAUDE.md](../CLAUDE.md)
- [API テスト画面](lib/features/dev_tools/screens/api_test_screen.dart)

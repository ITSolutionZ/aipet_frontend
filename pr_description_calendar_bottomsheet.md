# feat(calendar): カレンダーUI改善とボトムシート方式の実装

## 📋 変更概要

散歩履歴と予定管理画面のカレンダーUIを大幅に改善し、ボトムシート方式を導入してユーザビリティを向上させました。また、データ品質管理機能と位置追跡機能も実装しました。

## 🎯 主な変更内容

### 1. **カレンダー表示の標準化**

#### 日本標準のカレンダー形式に準拠
- ✅ 日曜日始まり (StartingDayOfWeek.sunday)
- ✅ 土曜日: 青色 (AppColors.pointBlue)
- ✅ 日曜日: 赤色 (AppColors.pointRed)
- ✅ 平日: 黒色 (AppColors.pointDark)

#### フォントサイズ最適化
- ✅ 全ての日付: fontSize 13に統一
- ✅ 2行表示問題を解決
- ✅ レイアウト安定性向上

#### 対象画面
- 散歩履歴 (`walk_calendar_screen.dart`)
- 予定管理 (`scheduling_screen.dart`)

---

### 2. **ボトムシート方式の導入**

#### Before (従来方式)
```
┌──────────────────┐
│  カレンダー      │ (固定)
├──────────────────┤
│                  │
│  イベントリスト  │ (固定、スクロール)
│  - イベント1     │
│  - イベント2     │
│                  │
└──────────────────┘
```

#### After (ボトムシート方式)
```
┌──────────────────┐
│  1ヶ月カレンダー │ (常に見える)
├──────────────────┤
│  今日の予定 ⬆️   │ (タップ可能)
└──────────────────┘
        ↓ タップ
┌──────────────────┐
│  2週カレンダー   │ (自動縮小)
├──────────────────┤
│  ━━━  (ハンドル) │
│  予定リスト  ✕  │ (ドラッグ可能)
└──────────────────┘
        ↓ 閉じる
┌──────────────────┐
│  1ヶ月カレンダー │ (自動復元)
├──────────────────┤
│  今日の予定 ⬆️   │
└──────────────────┘
```

#### カレンダーフォーマット連動
| 状態 | カレンダー | 説明 |
|------|----------|------|
| 初期表示 | month (1ヶ月) | 全体把握 |
| ボトムシート開く | twoWeeks (2週間) | リスト表示領域確保 |
| ボトムシート閉じる | month (1ヶ月) | 全体に戻る |

#### DraggableScrollableSheet設定
- initialChildSize: 0.6 (初期60%)
- minChildSize: 0.3 (最小30%)
- maxChildSize: 0.9 (最大90%)
- snap: true (スナップポイント)

---

### 3. **散歩位置追跡機能の実装**

#### 問題
- 散歩記録にrouteデータが保存されない
- 詳細画面で「ルート情報がありません」表示
- 距離計算ができない

#### 解決策

**walk_list_screen.dart**:
```dart
void _startLocationTracking() {
  _locationTimer = Timer.periodic(
    Duration(seconds: 10), // 10秒ごと
    (timer) async {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // 5m以上移動時のみ
        ),
      );
      
      final location = WalkLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        accuracy: position.accuracy,
      );
      
      // routeに追加
      _controller.addLocationToCurrentWalk(location);
    },
  );
}
```

**walk_repository_impl.dart**:
```dart
endWalk() {
  final updatedRecord = currentRecord.copyWith(
    endTime: endTime,
    duration: duration,
    distance: distance,
    route: currentRecord.route, // ✅ route明示的に保持
  );
}
```

#### 位置追跡仕様
| 設定 | 値 | 目的 |
|------|---|------|
| 追跡周期 | 10秒 | バッテリー効率 |
| 精度 | high | 正確な経路 |
| distanceFilter | 5m | 不要な更新防止 |
| タイムアウト | 5秒 | 応答待機 |

---

### 4. **データ品質管理機能**

#### 散歩履歴クリーンアップ (PopupMenu)

**1️⃣ 進行中記録を削除**
- `WalkStatus.inProgress`のまま放置された記録を削除
- currentWalkもクリア
- 散歩は一度に1つのみ実行を保証

**2️⃣ ルートなし記録を削除**
- `route.isEmpty`の記録を削除
- 位置追跡なしで保存された古い記録を整理
- 実データのみ保持

**3️⃣ 古い記録を削除** (既存機能)
- 6ヶ月以上前の記録を削除

---

### 5. **ペットフィルタリング機能 (予定管理)**

#### 実装内容
```dart
List<CalendarEventEntity> _getEventsForDay(DateTime day) {
  final allEvents = _events[day] ?? [];
  
  if (_selectedPetId == null) {
    return allEvents; // 全てのペット
  } else {
    return allEvents.where(
      (event) => event.petId == _selectedPetId
    ).toList(); // 選択されたペットのみ
  }
}
```

#### ペットタブ
- 🐾 **1番目 (paw icon)**: petId == null → 全てのペット
- 🌸 **2番目以降 (pet image)**: petId == pet.id → 各ペットのイベントのみ

#### データソース
- ✅ `petProfilesProvider`: 実際のペット情報 (SQLite)
- ✅ `CalendarEventService`: 実際のイベント情報 (SQLite)
- ✅ ペット画像: `ImageStorageService`経由でロード
- ✅ フィルタリング: `event.petId`で判別

---

### 6. **Widget Lifecycle エラー修正**

#### 修正したエラー

**1️⃣ 非活性化Widgetエラー**
```
Looking up a deactivated widget's ancestor is unsafe.
```

**解決策**:
```dart
Future<void> _saveEvent() async {
  // 非同期処理前にcontext参照を保存
  if (!mounted) return;
  final navigator = Navigator.of(context);
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  
  // ... 非同期処理 ...
  
  if (mounted) {
    navigator.pop(event); // 安全
    scaffoldMessenger.showSnackBar(...); // 安全
  }
}
```

**2️⃣ AnimationController衝突**
```
AnimationController#745a0 for SnackBar
```

**解決策**:
```dart
// 先に画面を閉じる
navigator.pop(event);

// 次のフレームでSnackBar表示 (親画面で)
Future.microtask(() {
  if (mounted) {
    scaffoldMessenger.showSnackBar(...);
  }
});
```

**3️⃣ addPostFrameCallback エラー**
```
build()内でaddPostFrameCallbackを毎回呼び出し
```

**解決策**:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (mounted) { // ✅ mountedチェック追加
    _autoSelectPetIfOnlyOne(data);
  }
});
```

---

## 📁 変更ファイル一覧

### 主要変更
```
lib/features/scheduling/presentation/screens/
  scheduling_screen.dart (+196行, カレンダー+ボトムシート+フィルタリング)
  new_event_setup_screen.dart (+37行, エラー修正)

lib/features/walk/presentation/screens/
  walk_calendar_screen.dart (+143行, ボトムシート+削除機能)
  walk_list_screen.dart (+61行, 位置追跡)

lib/features/walk/data/repositories/
  walk_repository_impl.dart (+8行, route保持)

lib/features/walk/presentation/widgets/
  walk_detail_map_widget.dart (+22行, 地図表示改善)
```

### コミット数
**12件** (ae9a9a68 ~ dd37e1c4)

---

## ✅ テスト項目

### カレンダー表示
- [x] 日曜日始まりで表示される
- [x] 土曜日が青色、日曜日が赤色
- [x] 日付が1行で表示される
- [x] 散歩履歴と予定管理で統一されたUI

### ボトムシート機能
- [x] タップで開く/閉じる
- [x] ドラッグでサイズ調整可能
- [x] 開く時に2週表示に自動切替
- [x] 閉じる時に1ヶ月表示に自動復元

### 散歩位置追跡
- [x] 10秒ごとに位置を記録
- [x] routeデータが正しく保存される
- [x] 散歩終了後もrouteが保持される
- [x] 詳細画面で経路が表示される

### データ管理
- [x] 進行中記録を削除できる
- [x] ルートなし記録を削除できる
- [x] 古い記録を削除できる
- [x] 削除後に正しくUI更新される

### ペットフィルタリング
- [x] 「全て」タブで全ペットの予定表示
- [x] 各ペットタブで該当ペットのみ表示
- [x] フィルタ切替がリアルタイムで反映
- [x] ペット画像が正しく表示される

### エラー修正
- [x] イベント保存時にクラッシュしない
- [x] SnackBarとナビゲーションの競合なし
- [x] addPostFrameCallbackエラーなし
- [x] 全ての非同期処理でmountedチェック

---

## 🐛 修正したバグ

### 1. Widgetライフサイクルエラー
- dispose後のcontext使用 → 事前参照保存で解決
- SnackBar衝突 → 実行順序変更で解決
- build内コールバック → mountedチェックで解決

### 2. データ整合性問題
- routeデータ消失 → copyWith明示的指定で解決
- 進行中記録の重複 → 削除機能で解決
- Mock/テストデータ混在 → 実データのみ使用

### 3. UI/UX問題
- カレンダーが常にスクロール → ボトムシート化
- 日付が2行表示 → フォントサイズ13px
- ペットフィルタリング不可 → petId連動実装

---

## 🎉 期待される効果

### 1. **ユーザビリティ大幅向上**
- カレンダーが常に見える
- 必要な時だけ詳細を確認
- ドラッグで自由にサイズ調整

### 2. **日本標準UI準拠**
- 日曜始まりで混乱なし
- 土日の色分けが直感的
- 一般的なカレンダーアプリと同じ操作性

### 3. **データ品質向上**
- 実際のGPS位置データのみ保存
- 不完全な記録を簡単に削除
- ペットごとの予定管理が明確

### 4. **安定性向上**
- Widgetライフサイクルエラーを完全解決
- 全ての非同期処理が安全
- メモリリーク防止

### 5. **実データ活用**
- petProfilesProvider (SQLite)
- CalendarEventService (SQLite)
- ImageStorageService (ローカルファイル)
- Mockデータ不使用

---

## 📊 統計

**総変更量**:
- 変更ファイル: 6+
- 追加行: 700+
- 削除行: 150+

**コミット数**: 12件

**ブランチ**: fix/reservation

---

## 🔧 技術的詳細

### カレンダーフォーマット切替
```dart
// ボトムシート開く前
if (_calendarFormat != CalendarFormat.twoWeeks) {
  setState(() { _calendarFormat = CalendarFormat.twoWeeks; });
}

// ボトムシート閉じた後
showModalBottomSheet(...).then((_) {
  if (mounted && _calendarFormat != CalendarFormat.month) {
    setState(() { _calendarFormat = CalendarFormat.month; });
  }
});
```

### 位置追跡タイマー
```dart
_locationTimer = Timer.periodic(
  Duration(seconds: 10),
  (timer) async {
    if (!mounted || _isPaused) return;
    
    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).timeout(Duration(seconds: 5));
    
    _controller.addLocationToCurrentWalk(location);
  },
);
```

### ペットフィルタリング
```dart
List<CalendarEventEntity> _getEventsForDay(DateTime day) {
  final allEvents = _events[day] ?? [];
  
  if (_selectedPetId == null) {
    return allEvents; // 全て
  } else {
    return allEvents.where(
      (event) => event.petId == _selectedPetId
    ).toList(); // 選択されたペットのみ
  }
}
```

---

## 🎊 今後の拡張

- [ ] ペットタブの並び順カスタマイズ
- [ ] 位置追跡精度の自動調整
- [ ] バックグラウンド位置追跡
- [ ] カレンダーイベントの一括編集
- [ ] データエクスポート機能

---

**レビュアー確認事項**:
- [ ] カレンダーが日曜始まりで表示されるか
- [ ] ボトムシートが正常に開閉するか
- [ ] ペットフィルタリングが正しく動作するか
- [ ] 散歩位置追跡が動作するか
- [ ] データ削除機能が正常に動作するか
- [ ] 全てのエラーが修正されたか


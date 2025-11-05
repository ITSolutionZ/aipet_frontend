import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drawer_state_provider.g.dart';

/// ドロワー状態管理プロバイダー
@riverpod
class DrawerState extends _$DrawerState {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void open() => state = true;
  void close() => state = false;
}

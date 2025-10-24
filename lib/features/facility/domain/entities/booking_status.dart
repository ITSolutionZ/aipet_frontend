import 'package:flutter/material.dart';

/// 予約状態列挙型
/// Domain layer entity for booking status
enum BookingStatus {
  /// 予約可能
  available('◎', Colors.green, '予約可能'),

  /// 相談が必要
  consultation('◉', Colors.orange, '相談'),

  /// 予約不可
  unavailable('×', Colors.grey, '予約不可');

  const BookingStatus(this.symbol, this.color, this.label);

  /// シンボル表示
  final String symbol;

  /// 状態カラー
  final Color color;

  /// 状態ラベル
  final String label;
}

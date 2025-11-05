import 'dart:convert';

import 'package:crypto/crypto.dart';


/// 共同養育者招待QRコードサービス
class CoOwnerQrService {
  /// QRコードデータを生成
  ///
  /// [petId] ペットID
  /// [ownerId] オーナーID
  /// [ownerName] オーナー名
  /// [petName] ペット名
  static String generateQrData({
    required String petId,
    required String ownerId,
    required String ownerName,
    required String petName,
  }) {
    // タイムスタンプを追加（1時間有効）
    final expiresAt =
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;

    final data = {
      'type': 'co_owner_invite',
      'version': '1.0',
      'petId': petId,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'petName': petName,
      'expiresAt': expiresAt,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // JSONエンコード
    return jsonEncode(data);
  }

  /// QRコードデータを検証・解析
  ///
  /// [qrData] QRコードから読み取ったデータ
  /// Returns: 解析済みデータ、無効な場合はnull
  static Map<String, dynamic>? parseQrData(String qrData) {
    try {
      final data = jsonDecode(qrData) as Map<String, dynamic>;

      // タイプチェック
      if (data['type'] != 'co_owner_invite') {
        return null;
      }

      // バージョンチェック
      if (data['version'] != '1.0') {
        return null;
      }

      // 有効期限チェック
      final expiresAt = data['expiresAt'] as int?;
      if (expiresAt != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > expiresAt) {
          return null; // 期限切れ
        }
      }

      // 必須フィールドチェック
      if (data['petId'] == null ||
          data['ownerId'] == null ||
          data['ownerName'] == null ||
          data['petName'] == null) {
        return null;
      }

      return data;
    } catch (e) {
      return null;
    }
  }

  /// 招待トークンを生成
  ///
  /// セキュアな招待リンクを生成するためのトークン
  static String generateInviteToken({
    required String petId,
    required String ownerId,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$petId:$ownerId:$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 招待データから表示用テキストを生成
  static String getInviteDisplayText({
    required String ownerName,
    required String petName,
  }) {
    return '$ownerNameさんから\n「$petName」の共同養育者に招待されました';
  }

  /// QRコードデータの有効性をチェック
  static bool isQrDataValid(String qrData) {
    final parsed = parseQrData(qrData);
    return parsed != null;
  }

  /// 有効期限までの残り時間を取得（分単位）
  static int? getRemainingMinutes(Map<String, dynamic> qrData) {
    final expiresAt = qrData['expiresAt'] as int?;
    if (expiresAt == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = expiresAt - now;

    if (remaining <= 0) return 0;

    return (remaining / (1000 * 60)).ceil();
  }
}

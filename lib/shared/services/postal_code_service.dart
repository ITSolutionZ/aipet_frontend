import 'dart:convert';

import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 住所情報モデル
class AddressInfo {
  final String postalCode;
  final String prefecture; // 都道府県
  final String city; // 市区町村
  final String town; // 町域
  final String fullAddress;

  const AddressInfo({
    required this.postalCode,
    required this.prefecture,
    required this.city,
    required this.town,
    required this.fullAddress,
  });
}

/// 郵便番号検索サービス
/// zipcloud APIを使用して郵便番号から住所を検索
class PostalCodeService {
  static const String _baseUrl = 'https://zipcloud.ibsnet.co.jp/api/search';

  /// 郵便番号から住所を検索
  ///
  /// [postalCode]: 郵便番号（ハイフンあり・なし両方対応）
  /// 戻り値: Result<AddressInfo>
  static Future<Result<AddressInfo>> searchByPostalCode(
    String postalCode,
  ) async {
    try {
      // バリデーション
      if (postalCode.trim().isEmpty) {
        return Result.failure('郵便番号を入力してください');
      }

      // ハイフンを削除
      final cleanedCode = postalCode.replaceAll('-', '');

      // 数字のみかチェック
      if (!RegExp(r'^\d+$').hasMatch(cleanedCode)) {
        return Result.failure('郵便番号は数字で入力してください');
      }

      // 7桁かチェック
      if (cleanedCode.length != 7) {
        return Result.failure('郵便番号は7桁で入力してください');
      }

      // APIリクエスト
      final response = await http
          .get(Uri.parse('$_baseUrl?zipcode=$cleanedCode'))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('タイムアウトが発生しました'),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // results が null または空の場合
        if (data['results'] == null || (data['results'] as List).isEmpty) {
          return Result.failure('郵便番号が見つかりませんでした');
        }

        // 最初の結果を返す
        final result = data['results'][0] as Map<String, dynamic>;
        final addressInfo = AddressInfo(
          postalCode: postalCode,
          prefecture: result['address1'] as String,
          city: result['address2'] as String,
          town: result['address3'] as String,
          fullAddress:
              '${result['address1']}${result['address2']}${result['address3']}',
        );

        return Result.success('住所を取得しました', addressInfo);
      } else if (response.statusCode == 404) {
        return Result.failure('郵便番号が見つかりませんでした');
      } else if (response.statusCode >= 500) {
        return Result.failure('サーバーエラーが発生しました');
      } else {
        return Result.failure('郵便番号の検索に失敗しました (${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      debugPrint('郵便番号検索エラー (Network): $e');
      return Result.failure(
        'ネットワークエラーが発生しました',
        Exception('ClientException: $e'),
      );
    } catch (e) {
      debugPrint('郵便番号検索エラー: $e');
      return Result.failure(
        '郵便番号の検索中にエラーが発生しました',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}

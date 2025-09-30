import 'dart:convert';

import 'package:http/http.dart' as http;

/// 郵便番号検索サービス
/// zipcloud APIを使用して郵便番号から住所を検索
class PostalCodeService {
  static const String _baseUrl = 'https://zipcloud.ibsnet.co.jp/api/search';

  /// 郵便番号から住所を検索
  ///
  /// [postalCode]: 郵便番号（ハイフンあり・なし両方対応）
  /// 戻り値: 住所情報のマップ、エラーの場合はnull
  static Future<Map<String, dynamic>?> searchByPostalCode(
    String postalCode,
  ) async {
    try {
      // ハイフンを削除
      final cleanedCode = postalCode.replaceAll('-', '');

      // APIリクエスト
      final response = await http.get(
        Uri.parse('$_baseUrl?zipcode=$cleanedCode'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // results が null または空の場合
        if (data['results'] == null || data['results'].isEmpty) {
          return null;
        }

        // 最初の結果を返す
        final result = data['results'][0] as Map<String, dynamic>;
        return {
          'postalCode': postalCode,
          'prefecture': result['address1'] as String, // 都道府県
          'city': result['address2'] as String, // 市区町村
          'town': result['address3'] as String, // 町域
          'fullAddress':
              '${result['address1']}${result['address2']}${result['address3']}',
        };
      }

      return null;
    } catch (e) {
      print('郵便番号検索エラー: $e');
      return null;
    }
  }
}

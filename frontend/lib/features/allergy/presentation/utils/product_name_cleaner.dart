/// 商品名クリーニングユーティリティ
///
/// 楽天APIから取得した商品名を整理してブランドと製品名を抽出
class ProductNameCleaner {
  /// 商品名をクリーンアップ (広告文句と不要な情報を削除)
  ///
  /// [originalName] 元の商品名
  /// 戻り値: クリーンアップされた商品名
  static String cleanProductName(String originalName) {
    String cleaned = originalName;

    // 広告文句を削除
    cleaned = _removeAdTexts(cleaned);

    // サイズ・重量情報を削除
    cleaned = _removeSizeInfo(cleaned);

    // 年齢・ライフステージ情報を削除
    cleaned = _removeAgeInfo(cleaned);

    // 追加の単位と数量情報を削除
    cleaned = _removeAdditionalUnits(cleaned);

    // 不要な空白と特殊文字を整理
    cleaned = _cleanupWhitespace(cleaned);

    // 空文字列なら元の名前を返す
    return cleaned.isEmpty ? originalName : cleaned;
  }

  /// 商品名からメーカー(ブランド)を抽出
  ///
  /// [productName] 商品名
  /// 戻り値: メーカー名
  static String extractMaker(String productName) {
    // 主要ペットフードメーカーリスト
    for (final maker in _majorMakers) {
      if (productName.contains(maker)) {
        return maker;
      }
    }

    // メーカーが見つからない場合、商品名の最初の単語をメーカーとして使用
    final cleanedName = productName.trim();
    if (cleanedName.isNotEmpty) {
      final words = cleanedName.split(RegExp(r'[\s　\-・_]+'));
      if (words.isNotEmpty && words.first.isNotEmpty) {
        return words.first;
      }
    }

    // すべて失敗した場合のデフォルト値
    return 'メーカー不明';
  }

  // ===== 内部ヘルパーメソッド =====

  /// 広告文句を削除
  static String _removeAdTexts(String text) {
    const adPatterns = [
      r'【.*?】', // 【】で囲まれた広告文句
      r'\[.*?\]', // []で囲まれた広告文句
      r'★.*?★', // ★で囲まれた広告文句
      r'楽天.*?位', // 楽天連続1位など
      r'限定.*?OFF', // 限定OFF関連
      r'SNS.*?話題', // SNS話題関連
      r'獣医師.*?奨', // 獣医師推奨関連
      r'No\.\d+', // No.1, No.2など
      r'\d+%', // 90%, 5%など
      r'高級品',
      r'話題',
      r'人気',
      r'おすすめ',
      r'お得',
      r'送料無料',
      r'レビュー.*?\d+',
      r'※.*?出荷',
      r'<.*?>',
      r'\(.*?\)',
    ];

    String result = text;
    for (final pattern in adPatterns) {
      result = result.replaceAll(RegExp(pattern), '');
    }
    return result;
  }

  /// サイズ・重量情報を削除
  static String _removeSizeInfo(String text) {
    const sizePatterns = [
      r'\d+\.?\d*[kg|g|KG|G]', // 3.5kg, 500gなど
      r'\d+[ml|ML|l|L]', // 500ml, 1Lなど
      r'\d+[個|枚|本|袋|缶|パック]', // 12個, 5枚など
      r'\d+x\d+', // 3x5など
      r'\d+\.\d+[kg|g|KG|G]', // 1.2kgなど
      r'\d+/\d+', // 12/24など
      r'\(.*?[kg|g|キロ|グラム].*?\)', // (3キロ...), (500g)など
      r'\(.*?[g|G]×\d+\)', // (g×2)など
      r'\(.*?\d+[kg|g|キロ|グラム].*?\)', // (3kg), (500g)など
      r'g\s*\(.*?\)', // g (3キロ...)など
      r'g\s*×\d+', // g×2など
      r'[g|G]\s*\d*', // g, G, g500など
    ];

    String result = text;
    for (final pattern in sizePatterns) {
      result = result.replaceAll(RegExp(pattern), '');
    }
    return result;
  }

  /// 年齢・ライフステージ情報を削除
  static String _removeAgeInfo(String text) {
    const agePatterns = [
      r'仔犬', // 子犬
      r'子猫', // 子猫
      r'成犬', // 成犬
      r'成猫', // 成猫
      r'高齢犬', // 高齢犬
      r'高齢猫', // 高齢猫
      r'シニア', // シニア
      r'パピー', // パピー
      r'キトン', // キトン
      r'ジュニア', // ジュニア
      r'\d+ヶ月', // 3か月など
      r'\d+歳', // 1歳など
    ];

    String result = text;
    for (final pattern in agePatterns) {
      result = result.replaceAll(RegExp(pattern), '');
    }
    return result;
  }

  /// 追加単位と数量情報を削除
  static String _removeAdditionalUnits(String text) {
    const additionalPatterns = [
      r'\d+[g|G]\s*\(', // 500g (など
      r'\(.*?\d+[g|G].*?\)', // (500g), (3kg)など
      r'\(.*?×.*?\)', // (×2), (×3)など
      r'×\d+', // ×2, ×3など
      r'\d+\s*×\s*\d+', // 500 × 2など
      r'\(.*?\)', // 残りの括弧内容
      r'g\s*$', // 末尾のg
      r'G\s*$', // 末尾のG
      r'\s+g\s+', // 前後に空白があるg
      r'\s+G\s+', // 前後に空白があるG
    ];

    String result = text;
    for (final pattern in additionalPatterns) {
      result = result.replaceAll(RegExp(pattern), '');
    }
    return result;
  }

  /// 空白と特殊文字を整理
  static String _cleanupWhitespace(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ') // 連続した空白を1つに
        .replaceAll(RegExp(r'[　]'), ' ') // 全角空白を半角に
        .replaceAll(RegExp(r'[,、]'), ' ') // カンマを空白に
        .trim(); // 前後の空白を削除
  }

  /// 主要ペットフードメーカーリスト
  static const List<String> _majorMakers = [
    'ロイヤルカナン',
    'ヒルズ',
    'オリジン',
    'アカナ',
    'カルナ4',
    'ベストブリード',
    'ガッツィ',
    'ベルカンド',
    'プラチナム',
    'サイエンスダイエット',
    'プロプラン',
    'アイムス',
    'ユーカヌバ',
    'ウェルネス',
    'ナチュラルバランス',
    'アーテミス',
    'ブルーバッファロー',
    'メリアル',
    'ネスレ',
    'ペディグリー',
    'フィリックス',
    'シーバ',
    'フォルツァ',
    'モンプチ',
    'アーロン',
    'グランデル',
    'ロータス',
    'オーシャン',
    'シンプリー',
    'ファーストチョイス',
    'アニモンダ',
    'カナガン',
    'ウルフオブウォールストリート',
    'ファーマイナ',
    'プロテイン',
    'ハピドッグ',
    'ハピキャット',
    'ネイチャーズプロテクション',
    'プリスクリプション',
    'ハルマ',
    'サクラ',
    'マルカン',
    'ドギーマン',
    'イースター',
    'サンクス',
    'ビッツ',
    'ポッピン',
    'トップブリード',
    'マルキョー',
    'サンライズ',
    'ファインペッツ',
    'ハートランド',
    'ビクトリア',
    'ドクターズ',
    'ベスト',
    'ナチュラル',
    'オーガニック',
    'プレミアム',
  ];
}

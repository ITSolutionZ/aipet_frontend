/// QRコード関連の定数とユーティリティ
class QRCodeConstants {
  // QR コードタイプ
  static const String typePetRegistration = 'pet_registration';
  static const String typeReservation = 'reservation';

  // QR コードプレフィックス
  static const String prefixPetProfile = 'pet_profile:';
  static const String prefixReservation = 'reservation:';
  static const String prefixLegacyPet = 'AIPET:';
  static const String prefixLegacyReservation = 'RESERVATION:';

  // QR コードサイズ
  static const double qrCodeSize = 200.0;
  static const double qrCodeImageSize = 180.0;
  static const double embeddedLogoSize = 40.0;

  // アイコンサイズ
  static const double scanIconSize = 100.0;
  static const double scanIconInnerSize = 50.0;

  /// ペットタイプを日本語に変換
  static String getJapaneseTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
        return '犬';
      case 'cat':
        return '猫';
      case 'bird':
        return '鳥';
      case 'hamster':
        return 'ハムスター';
      case 'rabbit':
        return 'うさぎ';
      case 'turtle':
        return '亀';
      default:
        return type;
    }
  }

  /// ペット登録用QRデータを生成
  static String generatePetQRData({
    required String petId,
    required String petName,
    required String petType,
    required double petWeight,
  }) {
    return '$prefixPetProfile$petId|$petName|$petType|${petWeight}kg|https://aipet.app/pet/$petId';
  }

  /// 予約用QRデータを生成
  static String generateReservationQRData({
    required String petId,
    required String petName,
    required String petType,
    required double petWeight,
  }) {
    return '$prefixReservation$petId|$petName|$petType|${petWeight}kg|https://aipet.app/reservation/$petId';
  }

  /// QRデータをパース
  static Map<String, String>? parsePetQRData(String qrData) {
    // 新形式: pet_profile:{ペットID}|{名前}|{タイプ}|{体重}kg|URL
    if (qrData.startsWith(prefixPetProfile)) {
      final dataWithoutPrefix = qrData.substring(prefixPetProfile.length);
      final parts = dataWithoutPrefix.split('|');
      if (parts.isNotEmpty) {
        return {
          'petId': parts[0],
          'petName': parts.length > 1 ? parts[1] : '不明',
          'petType': parts.length > 2 ? parts[2] : '',
          'petWeight': parts.length > 3 ? parts[3] : '',
        };
      }
    }
    // レガシー形式: AIPET:{ペットID}:{名前}
    else if (qrData.startsWith(prefixLegacyPet)) {
      final parts = qrData.split(':');
      if (parts.length >= 3) {
        return {
          'petId': parts[1],
          'petName': parts[2],
          'petType': '',
          'petWeight': '',
        };
      }
    }
    return null;
  }

  /// 予約QRデータをパース
  static Map<String, String>? parseReservationQRData(String qrData) {
    // 新形式: reservation:{ペットID}|{名前}|{タイプ}|{体重}kg|URL
    if (qrData.startsWith(prefixReservation)) {
      final dataWithoutPrefix = qrData.substring(prefixReservation.length);
      final parts = dataWithoutPrefix.split('|');
      if (parts.isNotEmpty) {
        return {
          'petId': parts[0],
          'petName': parts.length > 1 ? parts[1] : '不明',
          'petType': parts.length > 2 ? parts[2] : '',
          'petWeight': parts.length > 3 ? parts[3] : '',
        };
      }
    }
    // レガシー形式: RESERVATION:{予約ID}
    else if (qrData.startsWith(prefixLegacyReservation)) {
      final parts = qrData.split(':');
      if (parts.length >= 2) {
        return {
          'petId': parts[1],
          'petName': '',
          'petType': '',
          'petWeight': '',
        };
      }
    }
    return null;
  }
}


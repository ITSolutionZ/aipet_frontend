/// 펫의 상태를 나타내는 열거형
enum PetStatus {
  /// 활성 상태 - 현재 관리 중인 펫
  active,

  /// 사망 - 사망한 펫
  deceased,

  /// 숨김 - 숨김 처리된 펫 (별도 탭에서만 보임)
  hidden,

  /// 실종 - 실종된 펫
  missing,
}

extension PetStatusX on PetStatus {
  /// 상태의 한글명
  String get label {
    switch (this) {
      case PetStatus.active:
        return '활성';
      case PetStatus.deceased:
        return '사망';
      case PetStatus.hidden:
        return '숨김';
      case PetStatus.missing:
        return '실종';
    }
  }

  /// 상태의 일본어명
  String get labelJa {
    switch (this) {
      case PetStatus.active:
        return 'アクティブ';
      case PetStatus.deceased:
        return '亡くなった';
      case PetStatus.hidden:
        return '非表示';
      case PetStatus.missing:
        return '行方不明';
    }
  }

  /// 상태의 문자열 표현 (DB 저장용)
  String get value {
    switch (this) {
      case PetStatus.active:
        return 'active';
      case PetStatus.deceased:
        return 'deceased';
      case PetStatus.hidden:
        return 'hidden';
      case PetStatus.missing:
        return 'missing';
    }
  }

  /// 문자열에서 상태로 변환
  static PetStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return PetStatus.active;
      case 'deceased':
        return PetStatus.deceased;
      case 'hidden':
        return PetStatus.hidden;
      case 'missing':
        return PetStatus.missing;
      default:
        return PetStatus.active; // 기본값
    }
  }
}

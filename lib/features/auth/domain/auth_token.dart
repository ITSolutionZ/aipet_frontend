/// 인증 토큰 정보를 관리하는 클래스
/// 실제 API 연동 시 사용할 토큰 기반 인증 모델
class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final String tokenType;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  /// 토큰이 만료되었는지 확인
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 토큰이 곧 만료되는지 확인 (5분 전)
  bool get isExpiringSoon {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? tokenType,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  /// JSON으로 변환 (저장소 저장용)
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'tokenType': tokenType,
    };
  }

  /// JSON에서 생성
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthToken &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresAt == expiresAt &&
        other.tokenType == tokenType;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        refreshToken.hashCode ^
        expiresAt.hashCode ^
        tokenType.hashCode;
  }
}
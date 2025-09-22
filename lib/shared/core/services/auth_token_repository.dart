import 'package:meta/meta.dart';

/// 앱 전반에서 사용할 인증 토큰 데이터
@immutable
class AuthTokenBundle {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final DateTime? expiresAt;

  const AuthTokenBundle({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  AuthTokenBundle copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    DateTime? expiresAt,
  }) {
    return AuthTokenBundle(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

/// 인증 토큰을 관리하는 추상 저장소
abstract class AuthTokenRepository {
  Future<AuthTokenBundle?> getToken();
  Future<void> clearToken();
  Future<AuthTokenBundle?> refreshToken(String refreshToken);
}

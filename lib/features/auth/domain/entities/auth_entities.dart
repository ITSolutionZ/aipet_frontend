/// 인증된 사용자 정보
class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;
  final DateTime? lastSignInTime;
  final DateTime creationTime;
  final Map<String, dynamic>? customData; // 백엔드 토큰 등 추가 정보

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isEmailVerified = false,
    this.lastSignInTime,
    required this.creationTime,
    this.customData,
  });

  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isEmailVerified,
    DateTime? lastSignInTime,
    DateTime? creationTime,
    Map<String, dynamic>? customData,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      creationTime: creationTime ?? this.creationTime,
      customData: customData ?? this.customData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'AuthUser(uid: $uid, email: $email, displayName: $displayName)';
  }
}

/// 인증 세션 정보
class AuthSession {
  final String sessionId;
  final String userId;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String deviceId;
  final String? deviceName;
  final Map<String, dynamic>? metadata;

  const AuthSession({
    required this.sessionId,
    required this.userId,
    required this.createdAt,
    this.expiresAt,
    required this.deviceId,
    this.deviceName,
    this.metadata,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isValid => !isExpired;
}

/// 인증 토큰 정보
class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String tokenType;
  final List<String> scopes;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.issuedAt,
    required this.expiresAt,
    this.tokenType = 'Bearer',
    this.scopes = const [],
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isValid => !isExpired;

  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());

  bool get willExpireSoon {
    const warningThreshold = Duration(minutes: 5);
    return timeUntilExpiry <= warningThreshold;
  }

  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? issuedAt,
    DateTime? expiresAt,
    String? tokenType,
    List<String>? scopes,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
      scopes: scopes ?? this.scopes,
    );
  }
}

/// 소셜 로그인 제공자
enum SocialProvider {
  google,
  apple,
  line,
  facebook,
  twitter;

  String get displayName {
    switch (this) {
      case SocialProvider.google:
        return 'Google';
      case SocialProvider.apple:
        return 'Apple';
      case SocialProvider.line:
        return 'LINE';
      case SocialProvider.facebook:
        return 'Facebook';
      case SocialProvider.twitter:
        return 'Twitter';
    }
  }
}

/// 인증 상태
enum AuthenticationStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading;

  bool get isAuthenticated => this == AuthenticationStatus.authenticated;
  bool get isUnauthenticated => this == AuthenticationStatus.unauthenticated;
  bool get isLoading => this == AuthenticationStatus.loading;
  bool get isUnknown => this == AuthenticationStatus.unknown;
}

/// 로그인 방법
enum LoginMethod {
  emailPassword,
  google,
  apple,
  line,
  facebook,
  twitter,
  anonymous;

  bool get isSocial => [
    LoginMethod.google,
    LoginMethod.apple,
    LoginMethod.line,
    LoginMethod.facebook,
    LoginMethod.twitter,
  ].contains(this);

  bool get isEmailPassword => this == LoginMethod.emailPassword;
  bool get isAnonymous => this == LoginMethod.anonymous;
}

/// 사용자 프로필 정보
class UserProfile {
  final String userId;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? photoURL;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? bio;
  final Map<String, dynamic>? preferences;
  final DateTime? lastUpdated;

  const UserProfile({
    required this.userId,
    this.displayName,
    this.firstName,
    this.lastName,
    this.photoURL,
    this.phoneNumber,
    this.birthDate,
    this.bio,
    this.preferences,
    this.lastUpdated,
  });

  String? get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName;
  }

  UserProfile copyWith({
    String? userId,
    String? displayName,
    String? firstName,
    String? lastName,
    String? photoURL,
    String? phoneNumber,
    DateTime? birthDate,
    String? bio,
    Map<String, dynamic>? preferences,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

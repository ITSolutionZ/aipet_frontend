import '../../domain/repositories/auth_repository.dart';

class AuthUserModel {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;
  final DateTime? lastSignInTime;
  final DateTime creationTime;
  final Map<String, dynamic>? customData;

  const AuthUserModel({
    required this.id,
    this.email,
    this.displayName,
    this.photoURL,
    this.isEmailVerified = false,
    this.lastSignInTime,
    required this.creationTime,
    this.customData,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] ?? json['uid'] ?? '',
      email: json['email'],
      displayName: json['display_name'] ?? json['displayName'],
      photoURL: json['photo_url'] ?? json['photoURL'],
      isEmailVerified: json['email_verified'] ?? json['isEmailVerified'] ?? false,
      lastSignInTime: json['last_sign_in_time'] != null
          ? DateTime.parse(json['last_sign_in_time'])
          : json['lastSignInTime'] != null
              ? DateTime.parse(json['lastSignInTime'])
              : null,
      creationTime: json['creation_time'] != null
          ? DateTime.parse(json['creation_time'])
          : json['creationTime'] != null
              ? DateTime.parse(json['creationTime'])
              : DateTime.now(),
      customData: json['custom_data'] ?? json['customData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoURL,
      'email_verified': isEmailVerified,
      'last_sign_in_time': lastSignInTime?.toIso8601String(),
      'creation_time': creationTime.toIso8601String(),
      'custom_data': customData,
    };
  }

  AuthUser toDomain() {
    return AuthUser(
      uid: id,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      isEmailVerified: isEmailVerified,
      lastSignInTime: lastSignInTime,
      creationTime: creationTime,
      customData: customData,
    );
  }

  factory AuthUserModel.fromDomain(AuthUser authUser) {
    return AuthUserModel(
      id: authUser.uid,
      email: authUser.email,
      displayName: authUser.displayName,
      photoURL: authUser.photoURL,
      isEmailVerified: authUser.isEmailVerified,
      lastSignInTime: authUser.lastSignInTime,
      creationTime: authUser.creationTime,
      customData: authUser.customData,
    );
  }

  AuthUserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isEmailVerified,
    DateTime? lastSignInTime,
    DateTime? creationTime,
    Map<String, dynamic>? customData,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      creationTime: creationTime ?? this.creationTime,
      customData: customData ?? this.customData,
    );
  }
}

class AuthTokenModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String? scope;

  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
    required this.issuedAt,
    required this.expiresAt,
    this.scope,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    final issuedAt = json['issued_at'] != null
        ? DateTime.parse(json['issued_at'])
        : DateTime.now();

    final expiresIn = json['expires_in'] ?? 3600;
    final expiresAt = json['expires_at'] != null
        ? DateTime.parse(json['expires_at'])
        : issuedAt.add(Duration(seconds: expiresIn));

    return AuthTokenModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: expiresIn,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
      scope: json['scope'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'issued_at': issuedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'scope': scope,
    };
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  bool get isExpiringSoon {
    final timeUntilExpiry = expiresAt.difference(DateTime.now());
    return timeUntilExpiry.inMinutes < 5;
  }

  Duration get timeUntilExpiry {
    return expiresAt.difference(DateTime.now());
  }

  AuthTokenModel copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
    DateTime? issuedAt,
    DateTime? expiresAt,
    String? scope,
  }) {
    return AuthTokenModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      scope: scope ?? this.scope,
    );
  }
}

class AuthCredentialsModel {
  final String email;
  final String password;

  const AuthCredentialsModel({
    required this.email,
    required this.password,
  });

  factory AuthCredentialsModel.fromJson(Map<String, dynamic> json) {
    return AuthCredentialsModel(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class SocialAuthModel {
  final String provider;
  final String accessToken;
  final String? idToken;
  final Map<String, dynamic>? additionalData;

  const SocialAuthModel({
    required this.provider,
    required this.accessToken,
    this.idToken,
    this.additionalData,
  });

  factory SocialAuthModel.fromJson(Map<String, dynamic> json) {
    return SocialAuthModel(
      provider: json['provider'] ?? '',
      accessToken: json['access_token'] ?? '',
      idToken: json['id_token'],
      additionalData: json['additional_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'access_token': accessToken,
      'id_token': idToken,
      'additional_data': additionalData,
    };
  }
}
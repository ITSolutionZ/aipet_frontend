import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// 🎯 LINE OAuth 서비스
///
/// LINE OAuth 2.0을 통한 실제 로그인 구현
class LineOAuthService {
  // LINE OAuth 설정
  static const String _lineAuthUrl =
      'https://access.line.me/oauth2/v2.1/authorize';
  static const String _lineTokenUrl = 'https://api.line.me/oauth2/v2.1/token';
  static const String _lineProfileUrl = 'https://api.line.me/v2/profile';

  // 환경변수에서 가져올 설정들
  String get _clientId => AppConfig.current.lineClientId;
  String get _clientSecret => AppConfig.current.lineClientSecret;
  String get _redirectUri => AppConfig.current.lineRedirectUri;

  // AppLinks 인스턴스 (URL Scheme 콜백 처리)
  final AppLinks _appLinks = AppLinks();

  /// LINE OAuth 로그인 시작
  ///
  /// LINE OAuth 2.0 플로우를 통해 사용자 인증을 진행합니다.
  ///
  /// Returns: 인증 성공 시 LineUserInfo, 실패 시 에러 메시지
  Future<Result<LineUserInfo>> loginWithLine() async {
    try {
      // 1. State 파라미터 생성 (CSRF 보호)
      final state = _generateState();

      // 2. LINE OAuth URL 생성
      final authUrl = _buildAuthUrl(state);

      // 3. 웹뷰로 OAuth 인증 진행
      final result = await _launchOAuthUrl(authUrl);

      // 4. 콜백 URL에서 인증 코드 추출
      final authCode = _extractAuthCode(result);
      if (authCode == null) {
        return Result.failure('LINE ログインがキャンセルされました');
      }

      // 5. 액세스 토큰 요청
      final tokenResult = await _requestAccessToken(authCode, state);
      if (!tokenResult.isSuccess) {
        return Result.failure(
          tokenResult.error?.toString() ?? 'LINE ログインに失敗しました',
        );
      }

      // 6. 사용자 프로필 정보 요청
      final profileResult = await _requestUserProfile(tokenResult.dataOrNull!);
      if (!profileResult.isSuccess) {
        return Result.failure(
          profileResult.error?.toString() ?? 'LINE プロフィールの取得に失敗しました',
        );
      }

      return Result.success('LINEログインが完了しました', profileResult.dataOrNull!);
    } catch (e) {
      return Result.failure('LINE ログインに失敗しました: ${e.toString()}');
    }
  }

  /// State 파라미터 생성 (CSRF 보호)
  String _generateState() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// LINE OAuth URL 생성
  String _buildAuthUrl(String state) {
    final params = {
      'response_type': 'code',
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'state': state,
      'scope': 'profile openid email',
    };

    final uri = Uri.parse(_lineAuthUrl).replace(queryParameters: params);
    return uri.toString();
  }

  /// OAuth URL 실행
  ///
  /// url_launcher와 app_links를 사용하여 LINE OAuth 인증을 진행합니다.
  Future<String> _launchOAuthUrl(String authUrl) async {
    try {
      // URL Scheme 콜백을 위한 스트림 리스너 설정
      final completer = Completer<String>();
      StreamSubscription<Uri>? linkSubscription;

      // URL Scheme 콜백 리스너 설정
      linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          if (kDebugMode) {
            LoggerService.debug('📱 LINE OAuth 콜백 수신: $uri');
          }

          // LINE OAuth 콜백 URL 확인 (aipet://로 시작)
          if (uri.scheme == 'aipet') {
            linkSubscription?.cancel();
            if (!completer.isCompleted) {
              completer.complete(uri.toString());
            }
          }
        },
        onError: (error) {
          if (kDebugMode) {
            LoggerService.debug('❌ LINE OAuth 콜백 에러: $error');
          }
          linkSubscription?.cancel();
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
      );

      // 타임아웃 설정 (60초)
      Timer(const Duration(seconds: 60), () {
        if (!completer.isCompleted) {
          linkSubscription?.cancel();
          completer.completeError(
            TimeoutException('LINE OAuthタイムアウト', const Duration(seconds: 60)),
          );
        }
      });

      // OAuth URL을 브라우저에서 열기
      final uri = Uri.parse(authUrl);
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        linkSubscription.cancel();
        throw Exception('LINE OAuth URLを開けませんでした');
      }

      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // 외부 브라우저에서 열기
      );

      if (kDebugMode) {
        LoggerService.debug('🌐 LINE OAuth URL 열림: $authUrl');
      }

      // 콜백 URL 대기
      final callbackUrl = await completer.future;
      return callbackUrl;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ LINE OAuth URL 실행 에러: $e');
      }
      rethrow;
    }
  }

  /// 콜백 URL에서 인증 코드 추출
  String? _extractAuthCode(String callbackUrl) {
    try {
      final uri = Uri.parse(callbackUrl);
      return uri.queryParameters['code'];
    } catch (e) {
      return null;
    }
  }

  /// 액세스 토큰 요청
  Future<Result<LineTokenInfo>> _requestAccessToken(
    String authCode,
    String state,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_lineTokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': authCode,
          'redirect_uri': _redirectUri,
          'client_id': _clientId,
          'client_secret': _clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tokenInfo = LineTokenInfo.fromJson(data);
        return Result.success('토큰 획득 성공', tokenInfo);
      } else {
        return Result.failure('LINE トークンの取得に失敗しました');
      }
    } catch (e) {
      return Result.failure('LINE トークンの取得に失敗しました: ${e.toString()}');
    }
  }

  /// 사용자 프로필 정보 요청
  Future<Result<LineUserInfo>> _requestUserProfile(
    LineTokenInfo tokenInfo,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(_lineProfileUrl),
        headers: {'Authorization': 'Bearer ${tokenInfo.accessToken}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userInfo = LineUserInfo.fromJson(data);
        return Result.success('프로필 정보 획득 성공', userInfo);
      } else {
        return Result.failure('LINE プロフィールの取得に失敗しました');
      }
    } catch (e) {
      return Result.failure('LINE プロフィールの取得に失敗しました: ${e.toString()}');
    }
  }
}

/// LINE 토큰 정보
class LineTokenInfo {
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
  final String? idToken;
  final String scope;
  final String tokenType;

  const LineTokenInfo({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
    this.idToken,
    required this.scope,
    required this.tokenType,
  });

  factory LineTokenInfo.fromJson(Map<String, dynamic> json) {
    return LineTokenInfo(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'] ?? 0,
      idToken: json['id_token'],
      scope: json['scope'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
    );
  }
}

/// LINE 사용자 정보
class LineUserInfo {
  final String userId;
  final String displayName;
  final String? pictureUrl;
  final String? statusMessage;

  const LineUserInfo({
    required this.userId,
    required this.displayName,
    this.pictureUrl,
    this.statusMessage,
  });

  factory LineUserInfo.fromJson(Map<String, dynamic> json) {
    return LineUserInfo(
      userId: json['userId'] ?? '',
      displayName: json['displayName'] ?? '',
      pictureUrl: json['pictureUrl'],
      statusMessage: json['statusMessage'],
    );
  }
}

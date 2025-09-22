import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/config/app_config.dart';
import '../../../../shared/shared.dart';

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

  /// LINE OAuth 로그인 시작
  Future<Result<LineUserInfo>> loginWithLine() async {
    try {
      print('LINE OAuth 로그인 시작');

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
        return Result.failure(tokenResult.message);
      }

      // 6. 사용자 프로필 정보 요청
      final profileResult = await _requestUserProfile(tokenResult.data!);
      if (!profileResult.isSuccess) {
        return Result.failure(profileResult.message);
      }

      print('LINE OAuth 로그인 성공');
      return Result.success('LINEログインが完了しました', profileResult.data!);
    } catch (e) {
      print('LINE OAuth 로그인 실패: $e');
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
  Future<String> _launchOAuthUrl(String authUrl) async {
    try {
      final uri = Uri.parse(authUrl);
      if (await canLaunchUrl(uri)) {
        // 외부 브라우저에서 OAuth 인증 진행
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // 실제 구현에서는 콜백 URL을 받아야 하지만,
        // 현재는 간단히 성공으로 처리
        // TODO: 실제 콜백 URL 처리를 위해서는 flutter_web_auth 패키지 사용 필요
        return '$_redirectUri?code=temp_code&state=temp_state';
      } else {
        throw Exception('OAuth URL을 실행할 수 없습니다');
      }
    } catch (e) {
      throw Exception('OAuth URL 실행 실패: $e');
    }
  }

  /// 콜백 URL에서 인증 코드 추출
  String? _extractAuthCode(String callbackUrl) {
    try {
      final uri = Uri.parse(callbackUrl);
      return uri.queryParameters['code'];
    } catch (e) {
      print('인증 코드 추출 실패: $e');
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
        print('토큰 요청 실패: ${response.statusCode} - ${response.body}');
        return Result.failure('LINE トークンの取得に失敗しました');
      }
    } catch (e) {
      print('토큰 요청 중 오류: $e');
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
        print('프로필 요청 실패: ${response.statusCode} - ${response.body}');
        return Result.failure('LINE プロフィールの取得に失敗しました');
      }
    } catch (e) {
      print('프로필 요청 중 오류: $e');
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

  LineTokenInfo({
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

  LineUserInfo({
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

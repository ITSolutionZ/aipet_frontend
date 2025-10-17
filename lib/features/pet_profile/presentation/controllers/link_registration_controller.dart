import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'link_registration_controller.freezed.dart';
part 'link_registration_controller.g.dart';

/// 링크 등록 상태 관리
@riverpod
class LinkRegistrationController extends _$LinkRegistrationController {
  @override
  LinkRegistrationState build() {
    return const LinkRegistrationState();
  }

  /// 링크 업데이트
  void updateLink(String link) {
    state = state.copyWith(link: link);
  }

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// 링크 검증
  String? validateLink(String? value) {
    if (value == null || value.isEmpty) {
      return 'リンクを入力してください';
    }

    // URL 형식 검증
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      return '正しいリンク形式ではありません';
    }

    // aipet.app 도메인 검증 - Mock implementation since service is missing
    if (!value.contains('aipet.app') && !value.contains('example.com')) {
      return 'AI Petアプリの共有リンクではありません';
    }

    return null;
  }

  /// 링크 등록 처리
  Future<Map<String, dynamic>> registerLink(String link) async {
    setLoading(true);

    try {
      // Mock implementation since LinkRegistrationService is not available
      await Future.delayed(const Duration(seconds: 1));

      // Simulate success
      return {
        'success': true,
        'petData': {'name': 'Test Pet', 'type': 'dog'},
      };
    } catch (error) {
      return {'success': false, 'error': error.toString()};
    } finally {
      setLoading(false);
    }
  }
}

/// 링크 등록 상태
@freezed
class LinkRegistrationState with _$LinkRegistrationState {
  const factory LinkRegistrationState({
    @Default('') String link,
    @Default(false) bool isLoading,
  }) = _LinkRegistrationState;

  const LinkRegistrationState._();
}

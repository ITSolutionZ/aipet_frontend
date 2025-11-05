import '../../shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/application/auth_controller.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../shared/core/domain/result.dart';

/// 현재 사용자 정보를 관리하는 서비스
class CurrentUserService {
  final AuthRepository _authRepository;

  const CurrentUserService(this._authRepository);

  /// 현재 사용자 ID 가져오기
  Future<Result<String>> getCurrentUserId() async {
    try {
      // Firebase 사용자 확인
      final user = await _authRepository.getCurrentUser();

      if (user != null && user.uid.isNotEmpty) {
        return Result.success('사용자 ID를 성공적으로 가져왔습니다', user.uid);
      } else {
        return Result.failure('로그인된 사용자를 찾을 수 없습니다');
      }
    } catch (error) {
      debugPrint('getCurrentUserId error: $error');
      return Result.failure('사용자 ID 조회에 실패했습니다: ${error.toString()}');
    }
  }

  /// 현재 사용자가 로그인되어 있는지 확인
  Future<bool> isUserLoggedIn() async {
    try {
      final user = await _authRepository.getCurrentUser();
      return user != null && user.uid.isNotEmpty;
    } catch (error) {
      debugPrint('isUserLoggedIn error: $error');
      return false;
    }
  }

  /// 현재 사용자 이메일 가져오기
  Future<Result<String>> getCurrentUserEmail() async {
    try {
      final user = await _authRepository.getCurrentUser();

      if (user != null && user.email != null && user.email!.isNotEmpty) {
        return Result.success('사용자 이메일을 성공적으로 가져왔습니다', user.email!);
      } else {
        return Result.failure('사용자 이메일을 찾을 수 없습니다');
      }
    } catch (error) {
      debugPrint('getCurrentUserEmail error: $error');
      return Result.failure('사용자 이메일 조회에 실패했습니다: ${error.toString()}');
    }
  }

  /// 현재 사용자 표시 이름 가져오기
  Future<Result<String>> getCurrentUserDisplayName() async {
    try {
      final user = await _authRepository.getCurrentUser();

      if (user != null &&
          user.displayName != null &&
          user.displayName!.isNotEmpty) {
        return Result.success('사용자 이름을 성공적으로 가져왔습니다', user.displayName!);
      } else {
        // 이메일에서 이름 부분 추출 시도
        if (user?.email != null) {
          final emailName = user!.email!.split('@').first;
          return Result.success('사용자 이름을 이메일에서 추출했습니다', emailName);
        }
        return Result.failure('사용자 이름을 찾을 수 없습니다');
      }
    } catch (error) {
      debugPrint('getCurrentUserDisplayName error: $error');
      return Result.failure('사용자 이름 조회에 실패했습니다: ${error.toString()}');
    }
  }

  /// 사용자 로그아웃
  Future<Result<void>> signOut() async {
    try {
      await _authRepository.signOut();
      return Result.success('로그아웃이 성공적으로 완료되었습니다', null);
    } catch (error) {
      debugPrint('signOut error: $error');
      return Result.failure('로그아웃에 실패했습니다: ${error.toString()}');
    }
  }
}

/// CurrentUserService Provider
final currentUserServiceProvider = Provider<CurrentUserService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return CurrentUserService(authRepository);
});

/// 현재 사용자 ID Provider (캐시됨)
final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final userService = ref.watch(currentUserServiceProvider);
  final result = await userService.getCurrentUserId();

  if (result.isSuccess) {
    return result.dataOrNull;
  } else {
    // 에러가 발생한 경우 null 반환 (로그인 화면으로 리다이렉트 필요)
    return null;
  }
});

/// 현재 사용자 정보 Provider
final currentUserInfoProvider = FutureProvider<Map<String, String?>>((
  ref,
) async {
  final userService = ref.watch(currentUserServiceProvider);

  final userIdResult = await userService.getCurrentUserId();
  final emailResult = await userService.getCurrentUserEmail();
  final displayNameResult = await userService.getCurrentUserDisplayName();

  return {
    'userId': userIdResult.isSuccess ? userIdResult.dataOrNull : null,
    'email': emailResult.isSuccess ? emailResult.dataOrNull : null,
    'displayName': displayNameResult.isSuccess
        ? displayNameResult.dataOrNull
        : null,
  };
});

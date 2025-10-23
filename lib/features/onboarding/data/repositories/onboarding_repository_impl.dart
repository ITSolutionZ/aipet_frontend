import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/domain.dart';

/// 온보딩 관리 리포지토리 구현체
///
/// OnboardingRepository 인터페이스의 구체적인 구현을 제공합니다.
/// SharedPreferences를 사용하여 온보딩 상태를 영구 저장합니다.
class OnboardingRepositoryImpl implements OnboardingRepository {
  // SharedPreferences 키 상수
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyOnboardingCurrentPage = 'onboarding_current_page';

  // 캐시용 메모리 변수 (필요한 것만 유지)
  OnboardingState? _currentState;

  @override
  Future<Result<List<OnboardingPage>>> loadOnboardingData() async {
    try {
      // 로컬 정적 데이터 반환
      return Result.success('온보딩 데이터 로드 성공', OnboardingData.pages);
    } catch (e) {
      LoggerService.debug('❌ 온보딩 데이터 로드 실패: $e');
      return Result.failure('온보딩 데이터 로드에 실패했습니다');
    }
  }

  @override
  Future<Result<void>> saveOnboardingState(OnboardingState state) async {
    try {
      _currentState = state;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyOnboardingCurrentPage, state.currentPage);
      await prefs.setBool(_keyOnboardingCompleted, state.isCompleted);
      return Result.success('온보딩 상태 저장 성공', null);
    } catch (e) {
      LoggerService.debug('❌ 온보딩 상태 저장 실패: $e');
      // 메모리 캐시는 유지
      _currentState = state;
      return Result.failure('온보딩 상태 저장에 실패했습니다');
    }
  }

  @override
  Future<Result<OnboardingState>> loadOnboardingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPage = prefs.getInt(_keyOnboardingCurrentPage) ?? 0;
      final isCompleted = prefs.getBool(_keyOnboardingCompleted) ?? false;

      _currentState = OnboardingState(
        currentPage: currentPage,
        isCompleted: isCompleted,
      );

      return Result.success('온보딩 상태 로드 성공', _currentState!);
    } catch (e) {
      LoggerService.debug('❌ 온보딩 상태 로드 실패: $e');
      return Result.failure('온보딩 상태 로드에 실패했습니다');
    }
  }

  @override
  Future<Result<void>> completeOnboarding() async {
    try {
      _currentState = const OnboardingState(isCompleted: true);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOnboardingCompleted, true);
      await prefs.setInt(_keyOnboardingCurrentPage, 0); // 완료시 페이지 리셋
      return Result.success('온보딩 완료 성공', null);
    } catch (e) {
      LoggerService.debug('❌ 온보딩 완료 실패: $e');
      return Result.failure('온보딩 완료에 실패했습니다');
    }
  }

  @override
  Future<Result<bool>> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isCompleted = prefs.getBool(_keyOnboardingCompleted) ?? false;
      return Result.success('온보딩 완료 상태 확인 성공', isCompleted);
    } catch (e) {
      LoggerService.debug('❌ 온보딩 완료 상태 확인 실패: $e');
      return Result.failure('온보딩 완료 상태 확인에 실패했습니다');
    }
  }

  @override
  Future<Result<void>> restartOnboarding() async {
    try {
      _currentState = const OnboardingState();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOnboardingCompleted, false);
      await prefs.setInt(_keyOnboardingCurrentPage, 0);
      return Result.success('온보딩 재시작 성공', null);
    } catch (e) {
      LoggerService.debug('❌ 온보딩 재시작 실패: $e');
      return Result.failure('온보딩 재시작에 실패했습니다');
    }
  }

  @override
  Future<Result<void>> saveOnboardingProgress(int currentPage) async {
    try {
      // saveOnboardingState를 호출하여 중복 로직 제거
      final newState = OnboardingState(currentPage: currentPage);
      return await saveOnboardingState(newState);
    } catch (e) {
      LoggerService.debug('❌ 온보딩 진행률 저장 실패: $e');
      return Result.failure('온보딩 진행률 저장에 실패했습니다');
    }
  }

  @override
  Future<Result<int>> loadOnboardingProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progress = prefs.getInt(_keyOnboardingCurrentPage) ?? 0;
      return Result.success('온보딩 진행률 로드 성공', progress);
    } catch (e) {
      LoggerService.debug('❌ 온보딩 진행률 로드 실패: $e');
      return Result.failure('온보딩 진행률 로드에 실패했습니다');
    }
  }
}

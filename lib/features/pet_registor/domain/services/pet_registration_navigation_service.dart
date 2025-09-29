import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_registration_data_entity.dart';
import 'package:go_router/go_router.dart';

/// 펫 등록 네비게이션 서비스
/// 등록 상태에 따른 적절한 화면 전환을 담당
class PetRegistrationNavigationService {
  /// 다음 단계로 이동
  static void navigateToNext(GoRouter router, PetRegistrationDataEntity state) {
    final nextRoute = _getNextRoute(state);
    if (nextRoute != null) {
      router.go(nextRoute);
    }
  }

  /// 이전 단계로 이동
  static void navigateBack(GoRouter router, PetRegistrationDataEntity state) {
    final previousRoute = _getPreviousRoute(state);
    if (previousRoute != null) {
      router.go(previousRoute);
    }
  }

  /// 현재 상태에서 다음 단계 라우트 결정
  static String? _getNextRoute(PetRegistrationDataEntity state) {
    // 1. 펫 타입 선택되지 않았으면 타입 선택으로
    if (state.selectedPetType == null) {
      return RouteConstants.petTypeSelectionRoute;
    }

    // 2. 품종 선택되지 않았으면 품종 선택으로
    if (state.currentBreed == null) {
      return state.selectedPetType == 'dog'
          ? RouteConstants.dogBreedSelectionRoute
          : RouteConstants.catBreedSelectionRoute;
    }

    // 3. 이름이나 성별이 입력되지 않았으면 이름 입력으로
    if (state.petName == null ||
        state.petName!.trim().isEmpty ||
        state.petGender == null) {
      return RouteConstants.petNameInputRoute;
    }

    // 4. 크기나 체중이 입력되지 않았으면 크기/체중 입력으로
    if (state.petSize == null || state.petWeight == null) {
      return RouteConstants.petSizeWeightRoute;
    }

    // 5. 기념일이 선택되지 않았으면 기념일 선택으로
    if (state.petAnniversary == null) {
      return RouteConstants.petAnniversaryRoute;
    }

    // 6. 모든 정보가 입력되었으면 요약 페이지로
    return RouteConstants.petAnniversarySummaryRoute;
  }

  /// 현재 상태에서 이전 단계 라우트 결정
  static String? _getPreviousRoute(PetRegistrationDataEntity state) {
    // 현재 어느 단계인지 추론하여 이전 단계로 이동
    if (state.petAnniversary != null) {
      // 기념일까지 입력했으면 크기/체중으로
      return RouteConstants.petSizeWeightRoute;
    }

    if (state.petSize != null || state.petWeight != null) {
      // 크기/체중까지 입력했으면 이름 입력으로
      return RouteConstants.petNameInputRoute;
    }

    if (state.petName != null && state.petName!.trim().isNotEmpty) {
      // 이름까지 입력했으면 품종 선택으로
      return state.selectedPetType == 'dog'
          ? RouteConstants.dogBreedSelectionRoute
          : RouteConstants.catBreedSelectionRoute;
    }

    if (state.currentBreed != null) {
      // 품종까지 선택했으면 타입 선택으로
      return RouteConstants.petTypeSelectionRoute;
    }

    // 기본적으로 타입 선택으로
    return RouteConstants.petTypeSelectionRoute;
  }

  /// 등록 완료 후 다음 화면으로 이동
  static void navigateAfterRegistration(GoRouter router) {
    router.go(RouteConstants.petRegistrationCompleteRoute);
  }

  /// 특정 단계로 직접 이동 (편집 모드 등)
  static void navigateToStep(GoRouter router, PetRegistrationStep step) {
    final route = _getRouteForStep(step);
    if (route != null) {
      router.go(route);
    }
  }

  /// 단계별 라우트 매핑
  static String? _getRouteForStep(PetRegistrationStep step) {
    switch (step) {
      case PetRegistrationStep.petType:
        return RouteConstants.petTypeSelectionRoute;
      case PetRegistrationStep.dogBreed:
        return RouteConstants.dogBreedSelectionRoute;
      case PetRegistrationStep.catBreed:
        return RouteConstants.catBreedSelectionRoute;
      case PetRegistrationStep.petInfo:
        return RouteConstants.petNameInputRoute;
      case PetRegistrationStep.sizeWeight:
        return RouteConstants.petSizeWeightRoute;
      case PetRegistrationStep.anniversary:
        return RouteConstants.petAnniversaryRoute;
      case PetRegistrationStep.summary:
        return RouteConstants.petAnniversarySummaryRoute;
      case PetRegistrationStep.complete:
        return RouteConstants.petRegistrationCompleteRoute;
    }
  }
}

/// 펫 등록 단계 열거형
enum PetRegistrationStep {
  petType,
  dogBreed,
  catBreed,
  petInfo,
  sizeWeight,
  anniversary,
  summary,
  complete,
}

import 'package:go_router/go_router.dart';

import '../../../features/pet_activities/presentation/screens/learn_trick_screen.dart';
import '../../../features/pet_feeding/presentation/screens/screens.dart';
import '../../../features/pet_profile/presentation/screens/vaccine_screen.dart';
import '../../../features/pet_registor/presentation/screens/screens.dart';
import 'route_constants.dart';

/// 펫 관련 라우트 설정
///
/// 펫 등록 플로우, 펫 프로필, 백신 등 펫과 관련된 모든 라우트를 포함합니다.
/// 이 라우트들은 Shell 밖에서 독립적으로 실행되며, 펫 관리 기능을 담당합니다.
class PetRoutes {
  static List<RouteBase> get routes => [
    // ===== PET REGISTRATION FLOW =====
    GoRoute(
      path: RouteConstants.petTypeSelectionRoute,
      name: 'pet-type-selection',
      builder: (context, state) => const PetTypeSelectionScreen(),
    ),
    GoRoute(
      path: RouteConstants.dogBreedSelectionRoute,
      name: 'dog-breed-selection',
      builder: (context, state) => const DogBreedSelectionScreen(),
    ),
    GoRoute(
      path: RouteConstants.petNameInputRoute,
      name: 'pet-name-input',
      builder: (context, state) => const PetNameInputScreen(),
    ),
    GoRoute(
      path: RouteConstants.petSizeWeightRoute,
      name: 'pet-size-weight',
      builder: (context, state) => const PetSizeWeightScreen(),
    ),
    GoRoute(
      path: RouteConstants.petAnniversaryRoute,
      name: 'pet-anniversary',
      builder: (context, state) => const PetAnniversaryScreen(),
    ),
    GoRoute(
      path: RouteConstants.petAnniversarySummaryRoute,
      name: 'pet-anniversary-summary',
      builder: (context, state) => const PetAnniversarySummaryScreen(),
    ),
    GoRoute(
      path: RouteConstants.petRegistrationCompleteRoute,
      name: 'pet-registration-complete',
      builder: (context, state) => const PetRegistrationCompleteScreen(),
    ),

    // ===== PET PROFILE & HEALTH =====
    GoRoute(
      path: RouteConstants.vaccinesRoute,
      name: 'vaccines',
      builder: (context, state) {
        final petId = state.uri.queryParameters['petId'] ?? 'default';
        return VaccineScreen(petId: petId);
      },
    ),

    // ===== PET FEEDING =====
    GoRoute(
      path: RouteConstants.feedingMainRoute,
      name: 'feeding-main',
      builder: (context, state) => const FeedingMainScreen(),
    ),
    GoRoute(
      path: RouteConstants.recipesRoute,
      name: 'recipes',
      builder: (context, state) {
        final petId = state.uri.queryParameters['petId'] ?? 'default';
        return RecipeScreen(petId: petId);
      },
    ),
    GoRoute(
      path: RouteConstants.addRecipeRoute,
      name: 'add-recipe',
      builder: (context, state) => const AddRecipeScreen(),
    ),

    // ===== PET ACTIVITIES =====
    GoRoute(
      path: RouteConstants.allTricksRoute,
      name: 'learn-trick',
      builder: (context, state) => const LearnTrickScreen(),
    ),
  ];
}

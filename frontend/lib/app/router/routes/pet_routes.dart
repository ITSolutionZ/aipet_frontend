// import 'package:aipet_frontend/features/pet_activities/presentation/screens/learn_trick_screen.dart';
import 'package:aipet_frontend/features/pet_feeding/presentation/screens/pet_feeding_screens.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/screens/vaccine_screen.dart';
import 'package:go_router/go_router.dart';

import 'route_constants.dart';

/// 펫 관련 라우트 설정
///
/// 펫 등록 플로우, 펫 프로필, 백신 등 펫과 관련된 모든 라우트를 포함합니다.
/// 이 라우트들은 Shell 밖에서 독립적으로 실행되며, 펫 관리 기능을 담당합니다.
class PetRoutes {
  static List<RouteBase> get routes => [
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
      builder: (context, state) {
        final showBackButton =
            state.uri.queryParameters['showBackButton'] == 'true';
        return FeedingMainScreen(showBackButton: showBackButton);
      },
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
    // GoRoute(
    //   path: RouteConstants.allTricksRoute,
    //   name: 'learn-trick',
    //   builder: (context, state) => const LearnTrickScreen(),
    // ),
  ];
}

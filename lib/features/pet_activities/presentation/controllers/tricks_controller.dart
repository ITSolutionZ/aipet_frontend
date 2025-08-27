import 'package:flutter/material.dart';

import '../../../../app/controllers/base_controller.dart';
import '../../../../shared/shared.dart';
import '../../data/providers/pet_activities_providers.dart';
import '../../domain/entities/trick_entity.dart';

/// 펫 트릭 컨트롤러
///
/// 트릭 관련 비즈니스 로직을 처리합니다.
class TricksController extends BaseController {
  final BuildContext context;

  TricksController(super.ref, this.context);

  /// 모든 트릭을 로드합니다.
  Future<void> loadTricks() async {
    try {
      await ref.read(petActivitiesRepositoryProvider).getAllTricks();
    } catch (error) {
      handleError(error);
    }
  }

  /// 특정 펫의 트릭을 로드합니다.
  Future<void> loadTricksByPetId(String petId) async {
    try {
      await ref.read(petActivitiesRepositoryProvider).getTricksByPetId(petId);
    } catch (error) {
      handleError(error);
    }
  }

  /// 트릭 진행도를 업데이트합니다.
  Future<void> updateTrickProgress(TrickEntity trick, int progress) async {
    try {
      final updatedTrick = trick.updateProgress(progress);
      await ref.read(petActivitiesRepositoryProvider).updateTrick(updatedTrick);
      showSuccess('트릭 진행도가 업데이트되었습니다.');
    } catch (error) {
      handleError(error);
    }
  }

  /// 트릭을 완료 처리합니다.
  Future<void> completeTrick(TrickEntity trick) async {
    try {
      final completedTrick = trick.markAsCompleted();
      await ref
          .read(petActivitiesRepositoryProvider)
          .updateTrick(completedTrick);
      showSuccess('트릭을 완료했습니다!');
    } catch (error) {
      handleError(error);
    }
  }

  /// 새로운 트릭을 추가합니다.
  Future<void> addTrick(TrickEntity trick) async {
    try {
      await ref.read(petActivitiesRepositoryProvider).addTrick(trick);
      showSuccess('새로운 트릭이 추가되었습니다.');
    } catch (error) {
      handleError(error);
    }
  }

  /// 트릭을 삭제합니다.
  Future<void> deleteTrick(String trickId) async {
    try {
      await ref.read(petActivitiesRepositoryProvider).deleteTrick(trickId);
      showSuccess('트릭이 삭제되었습니다.');
    } catch (error) {
      handleError(error);
    }
  }

  /// 모든 트릭 진행도를 리셋합니다.
  Future<void> resetAllProgress() async {
    try {
      await ref.read(petActivitiesRepositoryProvider).resetAllTrickProgress();
      showSuccess('모든 트릭 진행도가 리셋되었습니다.');
    } catch (error) {
      handleError(error);
    }
  }

  /// 성공 메시지를 표시합니다.
  void showSuccess(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.pointGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 경고 메시지를 표시합니다.
  void showWarning(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.pointBrown,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 정보 메시지를 표시합니다.
  void showInfo(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.pointBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

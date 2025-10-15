import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/pet_registration_logic.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 펫 등록 폼 이벤트 핸들러
class RegistrationFormHandlers {
  final BuildContext context;
  final PetRegistrationController controller;
  final PetRegistrationLogic logic;
  final GlobalKey<FormState> formKey;

  const RegistrationFormHandlers({
    required this.context,
    required this.controller,
    required this.logic,
    required this.formKey,
  });

  /// 이미지 선택 핸들러
  Future<void> handleImageSelection(String? currentImagePath) async {
    try {
      debugPrint(
        '📸 Starting image selection, current path: $currentImagePath',
      );
      controller.setImageLoading(true);

      final result = await logic.selectPetImage(
        context: context,
        currentImagePath: currentImagePath,
      );

      debugPrint('📸 Image selection result: $result');

      if (result == null) {
        debugPrint('📸 Image selection cancelled');
        return;
      }

      if (result == 'REMOVE') {
        debugPrint('📸 Removing image');
        controller.updatePetImagePath(null);
      } else {
        debugPrint('📸 Setting new image path: $result');
        controller.updatePetImagePath(result);
      }
    } finally {
      controller.setImageLoading(false);
      debugPrint('📸 Image loading finished');
    }
  }

  /// 생년월일 선택 핸들러
  Future<void> handleBirthDateSelection(DateTime? currentDate) async {
    final picked = await logic.selectBirthDate(
      context: context,
      currentDate: currentDate,
    );

    if (picked != null) {
      controller.updateBirthDate(picked);
    }
  }

  /// 집에 온 날 선택 핸들러
  Future<void> handleAdoptionDateSelection(DateTime? currentDate) async {
    final picked = await logic.selectAdoptionDate(
      context: context,
      currentDate: currentDate,
    );

    if (picked != null) {
      controller.updateAdoptionDate(picked);
    }
  }

  /// 폼 제출 핸들러
  Future<void> handleSubmit(void Function(bool) setLoading) async {
    setLoading(true);

    try {
      // 펫 등록 및 등록된 펫 ID 받기
      final petId = await logic.submitPetRegistration(
        formKey: formKey,
        controller: controller,
      );

      if (context.mounted) {
        _showSuccessMessage(logic.getSuccessMessage());

        // 등록된 펫의 프로필 편집 화면으로 이동 (쿼리 파라미터 사용)
        context.go('/home/pet-profile?petId=$petId');
      }
    } catch (error) {
      if (context.mounted) {
        final errorMessage = logic.getErrorMessage(error);
        debugPrint('🚨 Registration error: $errorMessage');
        _showErrorMessage(errorMessage);
      }
    } finally {
      if (context.mounted) {
        setLoading(false);
      }
    }
  }

  /// 등록증 이미지 선택 및 OCR 처리
  Future<void> handleRegistrationImageSelection() async {
    try {
      await controller.selectAndProcessRegistrationImage();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('登録証情報を自動で入力しました。確認後修正してください。'),
            backgroundColor: AppColors.pointGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登録証処理中にエラーが発生しました: $e'),
            backgroundColor: AppColors.pointRed,
          ),
        );
      }
    }
  }

  /// 성공 메시지 표시
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.pointGreen),
    );
  }

  /// 에러 메시지 표시
  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: AppColors.pointRed),
            SizedBox(width: AppSpacing.sm),
            Text('登録エラー'),
          ],
        ),
        content: Text(message, style: AppFonts.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }
}

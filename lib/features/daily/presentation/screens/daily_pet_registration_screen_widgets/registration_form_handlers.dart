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
  Future<void> handleSubmit(
    void Function(bool) setLoading, {
    String? editPetId,
  }) async {
    setLoading(true);

    try {
      // 펫 등록/편집 및 등록된 펫 ID 받기
      final petId = await logic.submitPetRegistration(
        formKey: formKey,
        controller: controller,
        petId: editPetId, // 편집 모드용 petId 전달
      );

      if (context.mounted) {
        final isEditMode = editPetId != null && editPetId.isNotEmpty;
        _showSuccessMessage(logic.getSuccessMessage(isEditMode: isEditMode));

        // 잠시 대기 후 펫 프로필 화면으로 이동 (데이터 저장 완료 대기)
        await Future.delayed(const Duration(milliseconds: 500));

        // 등록된 펫의 프로필 화면으로 이동
        context.go('/home/pet-profile/$petId');
      }
    } catch (error) {
      if (context.mounted) {
        final errorMessage = logic.getErrorMessage(error);
        debugPrint('🚨 Registration error: $errorMessage');
        debugPrint('🚨 Error details: $error');
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
        SnackBarService.showSuccess(context, '登録証情報を自動で入力しました。確認後修正してください。');
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, '登録証処理中にエラーが発生しました: $e');
      }
    }
  }

  /// 성공 메시지 표시
  /// ✅ Shared SnackBarService 사용
  void _showSuccessMessage(String message) {
    SnackBarService.showSuccess(context, message);
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

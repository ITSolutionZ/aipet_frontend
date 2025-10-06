import 'package:aipet_frontend/features/pet_profile/presentation/constants/pet_profile_constants.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// Pet 편집 다이얼로그들
///
/// 펫 정보 편집을 위한 재사용 가능한 다이얼로그들을 제공합니다.
class PetEditDialogs {
  // Private constructor to prevent instantiation
  PetEditDialogs._();

  /// 이름 편집 다이얼로그
  static void showEditNameDialog(
    BuildContext context,
    String currentName,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(PetProfileConstants.editNameDialogTitle),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: PetProfileConstants.nameLabel,
            hintText: PetProfileConstants.nameHint,
          ),
          maxLength: PetProfileConstants.maxNameLengthValidation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(PetProfileConstants.cancelLabel),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(context);
                onSave(newName);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(PetProfileConstants.nameRequiredMessage),
                    backgroundColor: AppColors.pointRed,
                  ),
                );
              }
            },
            child: const Text(PetProfileConstants.saveLabel),
          ),
        ],
      ),
    );
  }

  /// 성별 편집 다이얼로그
  static void showEditGenderDialog(
    BuildContext context,
    String currentGender,
    Function(String) onSave,
  ) {
    String selectedGender = currentGender;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(PetProfileConstants.editGenderDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('オス'),
                value: 'Male',
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('メス'),
                value: 'Female',
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(PetProfileConstants.cancelLabel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onSave(selectedGender);
              },
              child: const Text(PetProfileConstants.saveLabel),
            ),
          ],
        ),
      ),
    );
  }

  /// 몸무게 편집 다이얼로그
  static void showEditWeightDialog(
    BuildContext context,
    double currentWeight,
    Function(double) onSave,
  ) {
    final controller = TextEditingController(text: currentWeight.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(PetProfileConstants.editWeightDialogTitle),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: PetProfileConstants.weightLabel,
            hintText: PetProfileConstants.weightHint,
            suffixText: 'kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(PetProfileConstants.cancelLabel),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(controller.text);
              if (weight != null &&
                  weight >= PetProfileConstants.minWeight &&
                  weight <= PetProfileConstants.maxWeight) {
                Navigator.pop(context);
                onSave(weight);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(PetProfileConstants.weightInvalidMessage),
                    backgroundColor: AppColors.pointRed,
                  ),
                );
              }
            },
            child: const Text(PetProfileConstants.saveLabel),
          ),
        ],
      ),
    );
  }

  /// 외모 편집 다이얼로그
  static void showEditAppearanceDialog(
    BuildContext context,
    String currentAppearance,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentAppearance);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(PetProfileConstants.editAppearanceDialogTitle),
        content: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: PetProfileConstants.maxAppearanceLength,
          decoration: const InputDecoration(
            labelText: PetProfileConstants.appearanceLabel,
            hintText: PetProfileConstants.appearanceHint,
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(PetProfileConstants.cancelLabel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onSave(controller.text.trim());
            },
            child: const Text(PetProfileConstants.saveLabel),
          ),
        ],
      ),
    );
  }

  /// 마이크로칩 편집 다이얼로그
  static void showEditMicrochipDialog(
    BuildContext context,
    String currentMicrochip,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentMicrochip);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(PetProfileConstants.editMicrochipDialogTitle),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: PetProfileConstants.microchipLabel,
            hintText: PetProfileConstants.microchipHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(PetProfileConstants.cancelLabel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onSave(controller.text.trim());
            },
            child: const Text(PetProfileConstants.saveLabel),
          ),
        ],
      ),
    );
  }

  /// 품종 편집 다이얼로그
  static void showEditBreedDialog(
    BuildContext context,
    String currentBreed,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentBreed);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('品種編集'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: PetProfileConstants.breedLabel,
            hintText: '品種を入力してください',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(PetProfileConstants.cancelLabel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onSave(controller.text.trim());
            },
            child: const Text(PetProfileConstants.saveLabel),
          ),
        ],
      ),
    );
  }

  /// 중성화 여부 편집 다이얼로그
  static void showEditNeuteredDialog(
    BuildContext context,
    bool currentNeutered,
    Function(bool) onSave,
  ) {
    bool selectedNeutered = currentNeutered;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('去勢・避妊編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<bool>(
                title: const Text('去勢・避妊済み'),
                value: true,
                groupValue: selectedNeutered,
                onChanged: (value) {
                  setState(() {
                    selectedNeutered = value!;
                  });
                },
              ),
              RadioListTile<bool>(
                title: const Text('未手術'),
                value: false,
                groupValue: selectedNeutered,
                onChanged: (value) {
                  setState(() {
                    selectedNeutered = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(PetProfileConstants.cancelLabel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onSave(selectedNeutered);
              },
              child: const Text(PetProfileConstants.saveLabel),
            ),
          ],
        ),
      ),
    );
  }
}

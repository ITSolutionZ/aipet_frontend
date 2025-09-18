import 'package:flutter/material.dart';

import '../../../../pet_registor/domain/entities/pet_profile_entity.dart';

class ProfileEditController {
  final TextEditingController nameController;
  final TextEditingController appearanceController;
  final TextEditingController weightController;
  final TextEditingController microchipController;

  String? editingGender;
  String? editingSize;
  double? editingWeight;
  String? selectedImagePath;

  ProfileEditController({
    required this.nameController,
    required this.appearanceController,
    required this.weightController,
    required this.microchipController,
  });

  void initializeFromPet(PetProfileEntity pet) {
    nameController.text = pet.name;
    appearanceController.text = pet.additionalInfo?['appearance'] ?? '';
    editingGender = pet.additionalInfo?['gender'];
    editingSize = pet.additionalInfo?['size'];
    editingWeight = pet.additionalInfo?['weight']?.toDouble();
    weightController.text = editingWeight?.toStringAsFixed(1) ?? '';
    microchipController.text = pet.additionalInfo?['microchipId'] ?? '';
    selectedImagePath = null;
  }

  void clear() {
    nameController.clear();
    appearanceController.clear();
    weightController.clear();
    microchipController.clear();
    editingGender = null;
    editingSize = null;
    editingWeight = null;
    selectedImagePath = null;
  }

  void updateGender(String? gender) {
    editingGender = gender;
  }

  void updateSize(String? size) {
    editingSize = size;
  }

  void updateWeight(double? weight) {
    editingWeight = weight;
  }

  void updateSelectedImage(String? imagePath) {
    selectedImagePath = imagePath;
  }

  PetProfileEntity createUpdatedPet(PetProfileEntity originalPet) {
    return originalPet.copyWith(
      name: nameController.text.trim().isNotEmpty ? nameController.text.trim() : originalPet.name,
      imagePath: selectedImagePath ?? originalPet.imagePath,
      additionalInfo: {
        ...?originalPet.additionalInfo,
        if (appearanceController.text.trim().isNotEmpty)
          'appearance': appearanceController.text.trim(),
        if (editingGender != null) 'gender': editingGender,
        if (editingSize != null) 'size': editingSize,
        if (editingWeight != null) 'weight': editingWeight,
        if (microchipController.text.trim().isNotEmpty)
          'microchipId': microchipController.text.trim(),
      },
    );
  }

  void dispose() {
    nameController.dispose();
    appearanceController.dispose();
    weightController.dispose();
    microchipController.dispose();
  }
}
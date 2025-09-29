import 'dart:io';

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// ⚠️ DEPRECATED: 중복 펫 이미지 선택 위젯
///
/// 이 클래스는 통합된 ImagePickerWidget으로 대체되었습니다.
/// 새로운 코드에서는 ImagePickerWidget.petProfile()을 사용하세요.
///
/// 마이그레이션 예시:
/// ```dart
/// // Before (DEPRECATED)
/// PetImagePicker(onImageChanged: callback)
///
/// // After (RECOMMENDED)
/// ImagePickerWidget.petProfile(onImageChanged: callback)
/// ```
@Deprecated('Use ImagePickerWidget.petProfile() instead')
class PetImagePicker extends StatelessWidget {
  final String? selectedImagePath;
  final String? defaultImagePath;
  final Function(String?) onImageChanged;
  final Function(String)? onDefaultImageChanged;

  const PetImagePicker({
    super.key,
    this.selectedImagePath,
    this.defaultImagePath,
    required this.onImageChanged,
    this.onDefaultImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePickerOptions(context),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Stack(children: [_buildImageContent(), _buildUploadIcon()]),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (selectedImagePath != null) {
      return Image.file(
        File(selectedImagePath!),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    if (defaultImagePath != null) {
      return Image.asset(
        defaultImagePath!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }

    return _buildErrorPlaceholder();
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey.withValues(alpha: 0.2),
      child: const Icon(Icons.pets, size: 50, color: AppColors.pointPink),
    );
  }

  Widget _buildUploadIcon() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.cloud_upload_outlined,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.pets),
                title: const Text('기본 이미지 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _showDefaultImageSelection(context);
                },
              ),
              if (selectedImagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('이미지 삭제'),
                  onTap: () {
                    Navigator.pop(context);
                    onImageChanged(null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (image != null) {
        onImageChanged(image.path);
        if (context.mounted) {
          SnackBarService.showSuccess(context, '이미지가 선택되었습니다');
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showPermissionRequired(context, '갤러리 접근');
      }
    }
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (image != null) {
        onImageChanged(image.path);
        if (context.mounted) {
          SnackBarService.showSuccess(context, '사진이 촬영되었습니다');
        }
      }
    } catch (e) {
      if (context.mounted) {
        final isSimulator = e.toString().contains('simulator');
        if (isSimulator) {
          SnackBarService.showWarning(context, '시뮬레이터에서는 카메라를 사용할 수 없습니다');
        } else {
          SnackBarService.showPermissionRequired(context, '카메라 접근');
        }
      }
    }
  }

  void _showDefaultImageSelection(BuildContext context) {
    final List<String> defaultImages = [
      'assets/images/pet_selector/dog.png',
      'assets/images/pet_selector/cat.png',
      'assets/images/dogs/shiba.png',
      'assets/images/dogs/poodle.jpg',
      'assets/images/dogs/pomeranian.png',
      'assets/images/dogs/dachshund.png',
      'assets/images/dogs/chiwawa.png',
      'assets/images/dogs/mixed.png',
      'assets/images/pet_selector/rabbit.png',
      'assets/images/pet_selector/bird.png',
      'assets/images/pet_selector/hamster.png',
      'assets/images/pet_selector/turtle.png',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('기본 이미지 선택'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: defaultImages.length,
              itemBuilder: (context, index) {
                final imagePath = defaultImages[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    // Set the selected default image as custom user choice
                    // We'll simulate this by creating a custom path identifier
                    onImageChanged(null); // Clear any file selection
                    // Instead, we need to notify parent about default image change
                    _onDefaultImageSelected(imagePath);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.withValues(alpha: 0.2),
                            child: const Icon(Icons.pets, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void _onDefaultImageSelected(String imagePath) {
    if (onDefaultImageChanged != null) {
      onDefaultImageChanged!(imagePath);
    }
  }
}

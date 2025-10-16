import 'dart:io';

import 'package:aipet_frontend/features/settings/data/providers/settings_providers.dart';
import 'package:aipet_frontend/features/settings/presentation/controllers/user_profile_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 프로필 편집 폼 상태 관리
final profileEditFormProvider =
    StateNotifierProvider<ProfileEditFormController, ProfileEditFormState>(
      (ref) => ProfileEditFormController(ref),
    );

class ProfileEditFormController extends StateNotifier<ProfileEditFormState> {
  final Ref ref;

  ProfileEditFormController(this.ref) : super(const ProfileEditFormState());

  void initialize() {
    final formKey = GlobalKey<FormState>();
    final userNameController = TextEditingController();
    final emailController = TextEditingController();
    final nameKatakanaController = TextEditingController();
    final contactController = TextEditingController();

    // 실시간 필드 업데이트
    userNameController.addListener(() {
      ref
          .read(userProfileControllerProvider.notifier)
          .updateField('userName', userNameController.text);
    });
    emailController.addListener(() {
      ref
          .read(userProfileControllerProvider.notifier)
          .updateField('email', emailController.text);
    });
    nameKatakanaController.addListener(() {
      ref
          .read(userProfileControllerProvider.notifier)
          .updateField('nameKatakana', nameKatakanaController.text);
    });
    contactController.addListener(() {
      ref
          .read(userProfileControllerProvider.notifier)
          .updateField('contact', contactController.text);
    });

    // 프로필 데이터가 있으면 컨트롤러에 값 설정
    final profileState = ref.read(userProfileControllerProvider);
    if (profileState.profile != null) {
      final profile = profileState.profile!;
      userNameController.text = profile.userName;
      emailController.text = profile.email;
      nameKatakanaController.text = profile.nameKatakana ?? '';
      contactController.text = profile.contact ?? '';
      print('📝 초기화 시 프로필 데이터 설정: ${profile.userName}');
    }

    state = state.copyWith(
      formKey: formKey,
      userNameController: userNameController,
      emailController: emailController,
      nameKatakanaController: nameKatakanaController,
      contactController: contactController,
    );
  }

  /// 선택된 이미지 업데이트
  void updateImage(File image) {
    print('🖼️ ProfileEditFormController: 이미지 업데이트 시작 - ${image.path}');
    state = state.copyWith(selectedImage: image);
    print('🖼️ ProfileEditFormController: 이미지 상태 업데이트 완료');
  }

  @override
  void dispose() {
    state.userNameController?.dispose();
    state.emailController?.dispose();
    state.nameKatakanaController?.dispose();
    state.contactController?.dispose();
    super.dispose();
  }
}

class ProfileEditFormState {
  final GlobalKey<FormState>? formKey;
  final TextEditingController? userNameController;
  final TextEditingController? emailController;
  final TextEditingController? nameKatakanaController;
  final TextEditingController? contactController;
  final File? selectedImage;
  final String? imagePath;

  const ProfileEditFormState({
    this.formKey,
    this.userNameController,
    this.emailController,
    this.nameKatakanaController,
    this.contactController,
    this.selectedImage,
    this.imagePath,
  });

  ProfileEditFormState copyWith({
    GlobalKey<FormState>? formKey,
    TextEditingController? userNameController,
    TextEditingController? emailController,
    TextEditingController? nameKatakanaController,
    TextEditingController? contactController,
    File? selectedImage,
    String? imagePath,
  }) {
    return ProfileEditFormState(
      formKey: formKey ?? this.formKey,
      userNameController: userNameController ?? this.userNameController,
      emailController: emailController ?? this.emailController,
      nameKatakanaController:
          nameKatakanaController ?? this.nameKatakanaController,
      contactController: contactController ?? this.contactController,
      selectedImage: selectedImage ?? this.selectedImage,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();

  @override
  void initState() {
    super.initState();
    // 폼 컨트롤러 초기화 (프로필은 자동으로 로드됨)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileEditFormProvider.notifier).initialize();
    });
  }

  /// 이미지 선택 다이얼로그 표시
  Future<void> _showImagePicker() async {
    print('🖼️ 이미지 선택 다이얼로그 시작');
    final File? selectedImage = await _imagePickerService.showImageSourceDialog(
      context,
    );
    if (selectedImage != null) {
      print('🖼️ 이미지 선택됨: ${selectedImage.path}');
      // 선택된 이미지를 상태에 저장
      ref.read(profileEditFormProvider.notifier).updateImage(selectedImage);
      print('🖼️ 이미지 상태 업데이트 완료');
    } else {
      print('🖼️ 이미지 선택 취소됨');
    }
  }

  Future<void> _saveProfile() async {
    final formState = ref.read(profileEditFormProvider);
    if (formState.formKey?.currentState?.validate() ?? false) {
      final controller = ref.read(userProfileControllerProvider.notifier);

      String? imagePath;

      // 선택된 이미지가 있으면 저장
      if (formState.selectedImage != null) {
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imagePath = await _imagePickerService.saveImageToAppDirectory(
          formState.selectedImage!,
          fileName,
        );
      }

      final success = await controller.saveProfile(
        userName: formState.userNameController?.text ?? '',
        email: formState.emailController?.text ?? '',
        nameKatakana: formState.nameKatakanaController?.text,
        contact: formState.contactController?.text,
        profileImage: imagePath,
      );

      if (mounted) {
        if (success) {
          // 다른 화면에서 참조하는 userProfileNotifierProvider도 업데이트
          try {
            await ref.read(userProfileNotifierProvider.notifier).refresh();
          } catch (e) {
            print('⚠️ userProfileNotifierProvider refresh 실패: $e');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('プロフィールが保存されました'),
              backgroundColor: AppColors.pointBrown,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('保存に失敗しました'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileControllerProvider);
    final formState = ref.watch(profileEditFormProvider);

    // 프로필 데이터가 로드되면 컨트롤러에 값 설정
    ref.listen(userProfileControllerProvider, (previous, next) {
      if (next.profile != null && previous?.profile != next.profile) {
        final profile = next.profile!;
        print('📝 프로필 데이터 로드됨: ${profile.userName}');

        // 텍스트 컨트롤러에 값 설정 (기존 텍스트와 다를 때만)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (formState.userNameController?.text != profile.userName) {
            formState.userNameController?.text = profile.userName;
          }
          if (formState.emailController?.text != profile.email) {
            formState.emailController?.text = profile.email;
          }
          if (formState.nameKatakanaController?.text !=
              (profile.nameKatakana ?? '')) {
            formState.nameKatakanaController?.text = profile.nameKatakana ?? '';
          }
          if (formState.contactController?.text != (profile.contact ?? '')) {
            formState.contactController?.text = profile.contact ?? '';
          }
          print('📝 텍스트 필드에 값 설정 완료');
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientBackAppBar(title: ''),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: formState.formKey,
          child: Column(
            children: [
              if (profileState.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _buildProfileImageSection(),

              const SizedBox(height: AppSpacing.xl),

              // フォームフィールド
              FormFieldWidget(
                label: 'ユーザ名',
                controller:
                    formState.userNameController ??
                    TextEditingController(
                      text: profileState.profile?.userName ?? '',
                    ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ユーザ名を入力してください';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              FormFieldWidget(
                label: 'メールアドレス',
                controller:
                    formState.emailController ??
                    TextEditingController(
                      text: profileState.profile?.email ?? '',
                    ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'メールアドレスを入力してください';
                  }
                  if (!value.contains('@')) {
                    return '有効なメールアドレスを入力してください';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              FormFieldWidget(
                label: 'フリガナ',
                controller:
                    formState.nameKatakanaController ??
                    TextEditingController(
                      text: profileState.profile?.nameKatakana ?? '',
                    ),
                validator: (value) => null, // Optional field
              ),

              const SizedBox(height: AppSpacing.md),

              FormFieldWidget(
                label: '連絡先',
                controller:
                    formState.contactController ??
                    TextEditingController(
                      text: profileState.profile?.contact ?? '',
                    ),
                validator: (value) => null, // Optional field
              ),

              const SizedBox(height: AppSpacing.xl),

              // 保存ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: profileState.isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                  child: profileState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          '保存',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              // ユーザーID 표시 (읽기 전용)
              if (profileState.profile != null) ...[
                const SizedBox(height: AppSpacing.xl),
                _buildUserIdCard(profileState.profile!.id),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 프로필 이미지 섹션 위젯
  Widget _buildProfileImageSection() {
    final formState = ref.watch(profileEditFormProvider);
    final profileState = ref.watch(userProfileControllerProvider);

    return Column(
      children: [
        GestureDetector(
          onTap: _showImagePicker,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.pointBrown, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(child: _buildProfileImage(formState, profileState)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${profileState.profile?.userName ?? 'プロフィール編集'} さん',
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'タップして画像を変更',
          style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
        ),
      ],
    );
  }

  /// 프로필 이미지 위젯
  Widget _buildProfileImage(
    ProfileEditFormState formState,
    UserProfileState profileState,
  ) {
    print('🖼️ _buildProfileImage 호출됨');
    print('🖼️ formState.selectedImage: ${formState.selectedImage?.path}');
    print(
      '🖼️ profileState.profile?.profileImage: ${profileState.profile?.profileImage}',
    );

    // 선택된 이미지가 있으면 표시
    if (formState.selectedImage != null) {
      print('🖼️ 선택된 이미지 표시: ${formState.selectedImage!.path}');
      return Image.file(
        formState.selectedImage!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          print('🖼️ 이미지 로드 에러: $error');
          return _buildDefaultProfileImage();
        },
      );
    }

    // 기존 프로필 이미지가 있으면 표시
    if (profileState.profile?.profileImage != null &&
        profileState.profile!.profileImage!.isNotEmpty) {
      print('🖼️ 기존 프로필 이미지 표시: ${profileState.profile!.profileImage}');
      return _buildProfileImageWidget(profileState.profile!.profileImage!);
    }

    // 기본 이미지 표시
    print('🖼️ 기본 이미지 표시');
    return _buildDefaultProfileImage();
  }

  /// 프로필 이미지 위젯 빌드 (이미지 타입 감지)
  Widget _buildProfileImageWidget(String imagePath) {
    final imageType = ImageService.getImageType(imagePath);
    print('🖼️ 이미지 타입 감지: $imageType, 경로: $imagePath');

    switch (imageType) {
      case ImageType.file:
        return Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            print('🖼️ 파일 이미지 로드 에러: $error');
            return _buildDefaultProfileImage();
          },
        );
      case ImageType.network:
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            print('🖼️ 네트워크 이미지 로드 에러: $error');
            return _buildDefaultProfileImage();
          },
        );
      case ImageType.asset:
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            print('🖼️ 에셋 이미지 로드 에러: $error');
            return _buildDefaultProfileImage();
          },
        );
    }
  }

  /// 기본 프로필 이미지 위젯
  Widget _buildDefaultProfileImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.pointOffWhite,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.pointGray.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/logos/aipet_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.pointGray.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 4),
                Text(
                  'プロフィール',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 유저 ID 카드 (읽기 전용)
  Widget _buildUserIdCard(String userId) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pointOffWhite.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.pointGray.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.badge_outlined,
            color: AppColors.pointGray,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'ユーザID: ',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              userId,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointDark,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.lock_outline, color: AppColors.pointGray, size: 16),
        ],
      ),
    );
  }
}

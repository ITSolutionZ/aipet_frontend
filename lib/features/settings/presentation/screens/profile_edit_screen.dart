import 'dart:io';

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
    // 폼 컨트롤러 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileEditFormProvider.notifier).initialize();
      // 프로필 로드
      ref.read(userProfileControllerProvider.notifier).loadProfile();
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
        formState.userNameController?.text = profile.userName;
        formState.emailController?.text = profile.email;
        formState.nameKatakanaController?.text = profile.nameKatakana ?? '';
        formState.contactController?.text = profile.contact ?? '';
      }
    });

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      appBar: const SoftGradientDrawerAppBar(title: 'プロフィール編集'),
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
                    formState.userNameController ?? TextEditingController(),
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
                    formState.emailController ?? TextEditingController(),
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
                    formState.nameKatakanaController ?? TextEditingController(),
                validator: (value) => null, // Optional field
              ),

              const SizedBox(height: AppSpacing.md),

              FormFieldWidget(
                label: '連絡先',
                controller:
                    formState.contactController ?? TextEditingController(),
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
      return Image.file(
        File(profileState.profile!.profileImage!),
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          print('🖼️ 기존 이미지 로드 에러: $error');
          return _buildDefaultProfileImage();
        },
      );
    }

    // 기본 이미지 표시
    print('🖼️ 기본 이미지 표시');
    return _buildDefaultProfileImage();
  }

  /// 기본 프로필 이미지 위젯
  Widget _buildDefaultProfileImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: AppColors.pointOffWhite,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 60, color: AppColors.pointGray),
    );
  }
}

import 'package:aipet_frontend/features/settings/presentation/widgets/profile_header_widget.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/form_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 프로필 데이터 상태
class ProfileData {
  final String userName;
  final String email;
  final String nameKatakana;
  final String contact;
  final bool isLoading;

  const ProfileData({
    this.userName = '',
    this.email = '',
    this.nameKatakana = '',
    this.contact = '',
    this.isLoading = false,
  });

  ProfileData copyWith({
    String? userName,
    String? email,
    String? nameKatakana,
    String? contact,
    bool? isLoading,
  }) {
    return ProfileData(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      nameKatakana: nameKatakana ?? this.nameKatakana,
      contact: contact ?? this.contact,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 프로필 데이터 프로바이더
final profileDataProvider =
    StateNotifierProvider<ProfileDataNotifier, ProfileData>((ref) {
      return ProfileDataNotifier();
    });

class ProfileDataNotifier extends StateNotifier<ProfileData> {
  ProfileDataNotifier() : super(const ProfileData()) {
    loadProfileData();
  }

  static const String _keyUserName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyNameKatakana = 'user_name_katakana';
  static const String _keyContact = 'user_contact';

  Future<void> loadProfileData() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      state = state.copyWith(
        userName: prefs.getString(_keyUserName) ?? 'ユーザ',
        email: prefs.getString(_keyEmail) ?? 'test@test.com',
        nameKatakana: prefs.getString(_keyNameKatakana) ?? '',
        contact: prefs.getString(_keyContact) ?? '',
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        userName: 'ユーザ',
        email: 'test@test.com',
        nameKatakana: '',
        contact: '',
        isLoading: false,
      );
    }
  }

  void updateField(String field, String value) {
    switch (field) {
      case 'userName':
        state = state.copyWith(userName: value);
        break;
      case 'email':
        state = state.copyWith(email: value);
        break;
      case 'nameKatakana':
        state = state.copyWith(nameKatakana: value);
        break;
      case 'contact':
        state = state.copyWith(contact: value);
        break;
    }
  }

  Future<bool> saveProfile() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserName, state.userName);
      await prefs.setString(_keyEmail, state.email);
      await prefs.setString(_keyNameKatakana, state.nameKatakana);
      await prefs.setString(_keyContact, state.contact);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }
}

/// 프로필 편집 폼 상태 관리
final profileEditFormProvider =
    StateNotifierProvider<ProfileEditFormController, ProfileEditFormState>(
      (ref) => ProfileEditFormController(ref),
    );

class ProfileEditFormController extends StateNotifier<ProfileEditFormState> {
  final Ref ref;

  ProfileEditFormController(this.ref) : super(const ProfileEditFormState());

  void initialize(ProfileData profileData) {
    final formKey = GlobalKey<FormState>();
    final userNameController = TextEditingController(
      text: profileData.userName,
    );
    final emailController = TextEditingController(text: profileData.email);
    final nameKatakanaController = TextEditingController(
      text: profileData.nameKatakana,
    );
    final contactController = TextEditingController(text: profileData.contact);

    userNameController.addListener(() {
      ref
          .read(profileDataProvider.notifier)
          .updateField('userName', userNameController.text);
    });
    emailController.addListener(() {
      ref
          .read(profileDataProvider.notifier)
          .updateField('email', emailController.text);
    });
    nameKatakanaController.addListener(() {
      ref
          .read(profileDataProvider.notifier)
          .updateField('nameKatakana', nameKatakanaController.text);
    });
    contactController.addListener(() {
      ref
          .read(profileDataProvider.notifier)
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

  const ProfileEditFormState({
    this.formKey,
    this.userNameController,
    this.emailController,
    this.nameKatakanaController,
    this.contactController,
  });

  ProfileEditFormState copyWith({
    GlobalKey<FormState>? formKey,
    TextEditingController? userNameController,
    TextEditingController? emailController,
    TextEditingController? nameKatakanaController,
    TextEditingController? contactController,
  }) {
    return ProfileEditFormState(
      formKey: formKey ?? this.formKey,
      userNameController: userNameController ?? this.userNameController,
      emailController: emailController ?? this.emailController,
      nameKatakanaController:
          nameKatakanaController ?? this.nameKatakanaController,
      contactController: contactController ?? this.contactController,
    );
  }
}

class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key});

  Future<void> _saveProfile(WidgetRef ref, BuildContext context) async {
    final formState = ref.read(profileEditFormProvider);
    if (formState.formKey?.currentState?.validate() ?? false) {
      final profileNotifier = ref.read(profileDataProvider.notifier);
      final success = await profileNotifier.saveProfile();
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('프로필이 저장되었습니다')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('저장에 실패했습니다')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileData = ref.watch(profileDataProvider);
    final formState = ref.watch(profileEditFormProvider);

    // Update controllers when profile data changes from provider
    ref.listen(profileDataProvider, (previous, next) {
      if (previous != next && !next.isLoading) {
        formState.userNameController?.text = next.userName;
        formState.emailController?.text = next.email;
        formState.nameKatakanaController?.text = next.nameKatakana;
        formState.contactController?.text = next.contact;
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
              if (profileData.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                const ProfileHeaderWidget(
                  userName: 'プロフィール編集',
                  email: '',
                  isEditable: true,
                ),

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
                  onPressed: profileData.isLoading
                      ? null
                      : () => _saveProfile(ref, context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                  ),
                  child: profileData.isLoading
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
}

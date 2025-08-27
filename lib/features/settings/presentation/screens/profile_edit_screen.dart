import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/shared.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/form_field_widget.dart';
import '../widgets/profile_header_widget.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  // SharedPreferences 키 상수
  static const String _keyUserName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyNameKatakana = 'user_name_katakana';
  static const String _keyContact = 'user_contact';

  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameKatakanaController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// 저장된 프로필 데이터 로드
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // 저장된 데이터가 있으면 로드, 없으면 기본값 사용
      _userNameController.text = prefs.getString(_keyUserName) ?? 'ユーザ';
      _emailController.text = prefs.getString(_keyEmail) ?? 'test@test.com';
      _nameKatakanaController.text = prefs.getString(_keyNameKatakana) ?? '';
      _contactController.text = prefs.getString(_keyContact) ?? '';
    } catch (error) {
      // 로드 실패 시 기본값 사용
      _userNameController.text = 'ユーザ';
      _emailController.text = 'test@test.com';
      _nameKatakanaController.text = '';
      _contactController.text = '';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _nameKatakanaController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      appBar: const AppBarWidget(title: 'プロフィール編集'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ProfileHeaderWidget(
                      userName: _userNameController.text.isNotEmpty
                          ? _userNameController.text
                          : 'ユーザ',
                      email: _emailController.text.isNotEmpty
                          ? _emailController.text
                          : 'test@test.com',
                      isEditable: true,
                    ),

              // フォームフィールド
              FormFieldWidget(
                label: 'ユーザ名',
                controller: _userNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ユーザ名を入力してください';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              FormFieldWidget(
                label: 'メールアドレス',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'メールアドレスを入力してください';
                  }
                  if (!value.contains('@')) {
                    return '正しいメールアドレスを入力してください';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              FormFieldWidget(
                label: '名前（カタカナ）',
                subtitle: '予約に使用する際に提供します',
                controller: _nameKatakanaController,
                validator: (value) {
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              FormFieldWidget(
                label: '連絡先',
                subtitle: '予約に使用する際に提供します',
                controller: _contactController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.xl * 2),

              // 編集完了ボタン
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, size: 20),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '編集完了',
                        style: AppFonts.fredoka(
                          fontSize: AppFonts.lg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  /// プロフィール保存処理
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // 각 필드의 데이터를 SharedPreferences에 저장
      await prefs.setString(_keyUserName, _userNameController.text.trim());
      await prefs.setString(_keyEmail, _emailController.text.trim());
      await prefs.setString(
        _keyNameKatakana,
        _nameKatakanaController.text.trim(),
      );
      await prefs.setString(_keyContact, _contactController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プロフィールが更新されました'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // 프로필 업데이트 완료 후 이전 화면으로 돌아가기
        Navigator.of(context).pop(true); // true를 반환하여 변경사항이 있음을 알림
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('プロフィール更新に失敗しました: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

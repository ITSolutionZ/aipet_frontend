import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/shared.dart';

class PetNameInputScreen extends ConsumerStatefulWidget {
  const PetNameInputScreen({super.key});

  @override
  ConsumerState<PetNameInputScreen> createState() => _PetNameInputScreenState();
}

class _PetNameInputScreenState extends ConsumerState<PetNameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      _isValid =
          _nameController.text.trim().length >= 2 &&
          _nameController.text.trim().length <= 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Text(
          '名前を教えてくだい',
          style: AppFonts.titleMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  '名前を教えてくだい',
                  style: AppFonts.titleLarge.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // 이름 입력 필드
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'ペットの名前を入力してください',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.large),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.lg),
                      prefixIcon: const Icon(Icons.pets),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '名前を入力してください';
                      }
                      if (value.trim().length < 2) {
                        return '名前は2文字以上で入力してください';
                      }
                      if (value.trim().length > 20) {
                        return '名前は20文字以内で入力してください';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 다음 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isValid
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              // 다음 단계로 이동
                              context.go(RouteConstants.petSizeWeightRoute);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.large),
                      ),
                    ),
                    child: Text(
                      '다음',
                      style: AppFonts.fredoka(
                        fontSize: AppFonts.lg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

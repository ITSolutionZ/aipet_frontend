import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/pet_profile/presentation/controllers/link_registration_controller.dart';
import '../../../../../features/pet_profile/presentation/widgets/link_registration/link_registration_widgets.dart';

/// 링크 등록 화면
///
/// 사용자가 직접 링크를 입력하여 펫 프로필을 추가할 수 있는 화면입니다.
class LinkRegistrationScreen extends ConsumerStatefulWidget {
  const LinkRegistrationScreen({super.key});

  @override
  ConsumerState<LinkRegistrationScreen> createState() =>
      _LinkRegistrationScreenState();
}

class _LinkRegistrationScreenState
    extends ConsumerState<LinkRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _linkController.addListener(() {
      ref
          .read(linkRegistrationControllerProvider.notifier)
          .updateLink(_linkController.text);
    });
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  /// 링크 검증
  String? _validateLink(String? value) {
    return ref
        .read(linkRegistrationControllerProvider.notifier)
        .validateLink(value);
  }

  /// 링크 등록 처리
  Future<void> _registerLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final result = await ref
          .read(linkRegistrationControllerProvider.notifier)
          .registerLink(_linkController.text);

      if (mounted) {
        if (result['success'] == true) {
          _showSuccessDialog(result['petData']);
        } else {
          _showErrorDialog('リンクの処理に失敗しました');
        }
      }
    } catch (error) {
      if (mounted) {
        _showErrorDialog(error.toString());
      }
    }
  }

  /// 성공 다이얼로그 표시
  void _showSuccessDialog([Map<String, dynamic>? petData]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LinkRegistrationSuccessDialog(petData: petData),
    ).then((_) {
      if (mounted) {
        context.pop();
      }
    });
  }

  /// 에러 다이얼로그 표시
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => LinkRegistrationErrorDialog(error: error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientBackAppBar(title: 'リンクで登録'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LinkRegistrationInfoCard(),
              const SizedBox(height: AppSpacing.xl),
              LinkInputField(
                controller: _linkController,
                validator: _validateLink,
              ),
              const SizedBox(height: AppSpacing.xl),
              const ExampleLinksCard(),
              const SizedBox(height: AppSpacing.xl * 2),
              LinkRegistrationButton(onPressed: _registerLink),
            ],
          ),
        ),
      ),
    );
  }
}

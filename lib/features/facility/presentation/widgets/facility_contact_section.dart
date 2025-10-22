import 'package:aipet_frontend/shared/core/services/snackbar_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/domain.dart';

class FacilityContactSection extends StatelessWidget {
  final Facility facility;

  const FacilityContactSection({super.key, required this.facility});

  Future<void> _makePhoneCall(BuildContext context) async {
    final phoneUri = Uri.parse('tel:${facility.phone}');

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (context.mounted) {
          // ✅ Shared SnackBarService 사용
          SnackBarService.showError(context, '電話アプリを開けません。');
        }
      }
    } catch (e) {
      if (context.mounted) {
        // ✅ Shared SnackBarService 사용
        SnackBarService.showError(context, '電話をかけることができません: $e');
      }
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    final emailUri = Uri.parse(
      'mailto:${facility.email}?subject=${Uri.encodeComponent('${facility.name} 문의')}&body=${Uri.encodeComponent('안녕하세요. ${facility.name}에 대해 문의드립니다.\n\n')}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          // ✅ Shared SnackBarService 사용
          SnackBarService.showError(context, 'メールアプリを開けません。');
        }
      }
    } catch (e) {
      if (context.mounted) {
        // ✅ Shared SnackBarService 사용
        SnackBarService.showError(context, 'メールを送信できません: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '連絡先',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 전화번호
        Row(
          children: [
            Expanded(
              child: Text(
                facility.phone ?? '',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
              ),
            ),
            IconButton(
              onPressed: () => _makePhoneCall(context),
              icon: const Icon(Icons.phone, color: Colors.blue, size: 20),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // 이메일
        Row(
          children: [
            Expanded(
              child: Text(
                facility.email ?? '',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
              ),
            ),
            IconButton(
              onPressed: () => _sendEmail(context),
              icon: const Icon(Icons.send, color: Colors.blue, size: 20),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:aipet_frontend/features/daily/data/providers/hospital_registration_provider.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// 병원 관리 다이얼로그 헬퍼
class HospitalDialogs {
  /// 병원 추가 다이얼로그
  static void showAddHospitalDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('病院登録'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '病院名',
                hintText: '例: さくら動物病院',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: '住所',
                hintText: '例: 東京都渋谷区...',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: '電話番号',
                hintText: '例: 03-1234-5678',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  addressController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                final hospital = RegisteredHospital(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  address: addressController.text,
                  phoneNumber: phoneController.text,
                  registeredAt: DateTime.now(),
                );

                await ref
                    .read(registeredHospitalsProvider.notifier)
                    .addHospital(hospital);

                if (!context.mounted) return;
                Navigator.of(context).pop();
                // ✅ Shared SnackBarService 사용
                SnackBarService.showSuccess(context, '病院が登録されました');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointGreen,
            ),
            child: const Text('登録'),
          ),
        ],
      ),
    );
  }

  /// 병원 삭제 다이얼로그
  static void showRemoveHospitalDialog(
    BuildContext context,
    WidgetRef ref,
    RegisteredHospital hospital,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('病院削除'),
        content: Text('「${hospital.name}」を登録から削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(registeredHospitalsProvider.notifier)
                  .removeHospital(hospital.id);

              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('病院が削除されました'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  /// 긴급 연락처 다이얼로그
  static void showEmergencyContactsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('緊急連絡先'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.local_hospital, color: Colors.red),
              title: Text('動物救急センター'),
              subtitle: Text('24時間対応'),
              trailing: Text(
                '119',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(Icons.pets, color: Colors.green),
              title: Text('ペット救急ホットライン'),
              subtitle: Text('ペットの緊急相談'),
              trailing: Text('0120-XX-XXXX', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 전화 걸기
  static Future<void> makePhoneCall(
    BuildContext context,
    String phoneNumber,
  ) async {
    // 전화번호에서 하이픈 제거
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[-\s]'), '');
    final Uri telUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      final canLaunch = await canLaunchUrl(telUri);
      if (canLaunch) {
        await launchUrl(telUri);
      } else {
        if (!context.mounted) return;
        // ✅ Shared SnackBarService 사용
        SnackBarService.showWarning(context, '電話をかけることができません');
      }
    } catch (e) {
      if (!context.mounted) return;
      // ✅ Shared SnackBarService 사용
      SnackBarService.showError(context, 'エラーが発生しました: $e');
    }
  }
}

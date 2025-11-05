import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';


import '../../../../../shared/shared.dart';
import '../../../../../../features/pet_profile/data/providers/pet_profile_providers.dart';
import 'qr_code_constants.dart';



/// QRコードスキャン結果処理クラス
class QRCodeHandler {
  final WidgetRef ref;
  final BuildContext context;

  QRCodeHandler(this.ref, this.context);

  /// QRコードスキャン結果を処理
  void handleQRCodeScanned(String qrData, String scanType) {
    if (scanType == QRCodeConstants.typePetRegistration) {
      _handlePetRegistrationQR(qrData);
    } else if (scanType == QRCodeConstants.typeReservation) {
      _handleReservationQR(qrData);
    } else {
      _showErrorMessage('無効なQRコードです');
    }
  }

  /// ペット登録QRを処理
  void _handlePetRegistrationQR(String qrData) {
    final parsedData = QRCodeConstants.parsePetQRData(qrData);

    if (parsedData != null) {
      final petId = parsedData['petId']!;
      final petName = parsedData['petName']!;
      final petType = parsedData['petType']!;
      final petWeight = parsedData['petWeight']!;
      _showAddFamilyDialog(petId, petName, petType, petWeight);
    } else {
      _showErrorMessage('ペット登録用のQRコードではありません');
    }
  }

  /// 予約QRを処理
  void _handleReservationQR(String qrData) {
    final parsedData = QRCodeConstants.parseReservationQRData(qrData);

    if (parsedData != null) {
      final petId = parsedData['petId']!;
      final petName = parsedData['petName']!;
      final petType = parsedData['petType']!;
      final petWeight = parsedData['petWeight']!;
      _showReservationDialog(petId, petName, petType, petWeight);
    } else {
      _showErrorMessage('予約用のQRコードではありません');
    }
  }

  /// エラーメッセージ表示
  void _showErrorMessage(String message) {
    SnackBarService.showError(context, message);
  }

  /// 共同管理者追加ダイアログ
  void _showAddFamilyDialog(
    String petId,
    String petName,
    String petType,
    String petWeight,
  ) {
    final typeDisplay = petType.isNotEmpty
        ? QRCodeConstants.getJapaneseTypeName(petType)
        : '';
    final weightDisplay = petWeight.isNotEmpty ? petWeight : '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('共同管理者として追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$petName を共同管理者として追加しますか？',
              style: const TextStyle(fontSize: 16),
            ),
            if (typeDisplay.isNotEmpty || weightDisplay.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'ペット情報',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointBrown,
                ),
              ),
              const SizedBox(height: 8),
              if (typeDisplay.isNotEmpty)
                Text('種類: $typeDisplay', style: const TextStyle(fontSize: 14)),
              if (weightDisplay.isNotEmpty)
                Text(
                  '体重: $weightDisplay',
                  style: const TextStyle(fontSize: 14),
                ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              _addFamilyMember(dialogContext, petId, petName);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBrown,
              foregroundColor: Colors.white,
            ),
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  /// 予約ダイアログ表示
  void _showReservationDialog(
    String petId,
    String petName,
    String petType,
    String petWeight,
  ) {
    final typeDisplay = petType.isNotEmpty
        ? QRCodeConstants.getJapaneseTypeName(petType)
        : '';
    final weightDisplay = petWeight.isNotEmpty ? petWeight : '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('予約確認'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (petName.isNotEmpty) ...[
              Text(
                '$petName の予約を確認しますか？',
                style: const TextStyle(fontSize: 16),
              ),
              if (typeDisplay.isNotEmpty || weightDisplay.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'ペット情報',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointBrown,
                  ),
                ),
                const SizedBox(height: 8),
                if (typeDisplay.isNotEmpty)
                  Text(
                    '種類: $typeDisplay',
                    style: const TextStyle(fontSize: 14),
                  ),
                if (weightDisplay.isNotEmpty)
                  Text(
                    '体重: $weightDisplay',
                    style: const TextStyle(fontSize: 14),
                  ),
              ],
            ] else
              Text('予約ID: $petId\nこの予約を確認しますか？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              _processReservation(petId, petName);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBrown,
              foregroundColor: Colors.white,
            ),
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }

  /// 共同管理者を追加
  Future<void> _addFamilyMember(
    BuildContext dialogContext,
    String petId,
    String petName,
  ) async {
    // BuildContextを事前にキャプチャ
    final navigator = Navigator.of(dialogContext);
    final scaffoldMessenger = ScaffoldMessenger.of(dialogContext);
    final router = GoRouter.of(dialogContext);

    try {
      // ローディングダイアログ表示 (unawaitedで処理)
      unawaited(
        showDialog(
          context: dialogContext,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.pointBrown),
          ),
        ),
      );

      // ペット情報をロード
      final repository = ref.read(petProfileRepositoryProvider);
      final result = await repository.getPetById(petId);

      // ローディングダイアログを閉じる
      navigator.pop();

      if (result.isSuccess && result.dataOrNull != null) {
        final pet = result.dataOrNull!;

        // ペットをローカルデータベースに追加
        final notifier = ref.read(petProfilesProvider.notifier);
        await notifier.createPet(pet);

        // 成功メッセージ表示
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('$petName を共同管理ペットとして追加しました'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: '確認',
              textColor: Colors.white,
              onPressed: () {
                router.push('/pet-management');
              },
            ),
          ),
        );
      } else {
        // ペットが見つからない
        unawaited(
          showDialog(
            context: dialogContext,
            builder: (dialogCtx) => AlertDialog(
              title: const Text('ペットが見つかりません'),
              content: const Text(
                '共有されたペットの情報を読み込めませんでした。\n'
                'ペットの所有者に確認してください。',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('確認'),
                ),
              ],
            ),
          ),
        );
      }
    } catch (error) {
      // ローディングダイアログが開いていれば閉じる
      navigator.pop();

      // エラーメッセージ表示
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 予約を処理
  void _processReservation(String petId, String petName) {
    // TODO: 実際の予約処理ロジックを実装
    final displayName = petName.isNotEmpty ? petName : petId;
    SnackBarService.showSuccess(context, '$displayName の予約が確認されました');
  }
}

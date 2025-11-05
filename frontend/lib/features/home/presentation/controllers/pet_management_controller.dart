import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
import '../../../../app/controllers/base_controller.dart';
import '../../../../../features/pet_profile/data/providers/pet_profile_providers.dart';

/// ペット管理コントローラー
///
/// ペット削除、非表示、復元などのビジネスロジックを担当
class PetManagementController extends BaseController {
  PetManagementController(super.ref);

  /// ペットを削除
  Future<void> deletePet(BuildContext context, PetProfileEntity pet) async {
    final petName = pet.name;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // リポジトリを通じて削除
      final notifier = ref.read(petProfilesProvider.notifier);
      await notifier.deletePet(pet.id);

      // 成功メッセージ表示
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('$petNameが削除されました'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (error) {
      // エラーメッセージ表示
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('削除中にエラーが発生しました: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ペットを非表示
  Future<void> hidePet(
    BuildContext context,
    PetProfileEntity pet,
    VoidCallback onSuccess,
  ) async {
    final petName = pet.name;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // ペット状態を非表示に更新
      final hiddenPet = pet.copyWith(petStatus: PetStatus.hidden);

      // リポジトリを通じて更新
      final notifier = ref.read(petProfilesProvider.notifier);
      await notifier.updatePet(hiddenPet);

      // 成功時コールバック実行
      onSuccess();

      // 成功メッセージ表示
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('$petNameが非表示になりました'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (error) {
      // エラーメッセージ表示
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('非表示処理中にエラーが発生しました: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ペットを復元（非表示解除）
  Future<void> restorePet(
    BuildContext context,
    PetProfileEntity pet,
    VoidCallback onSuccess,
  ) async {
    final petName = pet.name;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // ペット状態をアクティブに更新
      final activePet = pet.copyWith(petStatus: PetStatus.active);

      // リポジトリを通じて更新
      final notifier = ref.read(petProfilesProvider.notifier);
      await notifier.updatePet(activePet);

      // 成功時コールバック実行
      onSuccess();

      // 成功メッセージ表示
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('$petNameが管理中に復元されました'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      // エラーメッセージ表示
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('復元中にエラーが発生しました: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// スワイプアクション確認ダイアログを表示
  Future<bool> showSwipeActionDialog(
    BuildContext context,
    PetProfileEntity pet,
    DismissDirection direction,
    bool isHiddenTab,
  ) async {
    final isDelete = direction == DismissDirection.startToEnd;
    final isRestore = !isDelete && isHiddenTab;

    final action = isDelete ? '削除' : (isRestore ? '復元' : '非表示');
    final message = isDelete
        ? '${pet.name}を完全に削除しますか？'
        : (isRestore ? '${pet.name}を管理中に戻しますか？' : '${pet.name}を非表示にしますか？');
    final actionColor = isDelete
        ? Colors.red
        : (isRestore ? Colors.green : Colors.orange);

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('ペット$action'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: actionColor),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }
}

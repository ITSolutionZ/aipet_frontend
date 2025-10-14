import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pet_basic_info_tab.dart';

/// Pet 정보 편집 다이얼로그 헬퍼
class PetInfoDialogHelper {
  /// 이름 편집 다이얼로그 표시
  static void showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('名前編集'),
        content: TextField(
          controller: ref.read(petBasicInfoTabProvider(tabId)).nameController,
          decoration: const InputDecoration(
            labelText: 'ペットの名前',
            hintText: '名前を入力してください',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 성별 편집 다이얼로그 표시
  static void showEditGenderDialog(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('性別編集'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('オス'),
              value: 'Male',
              groupValue: ref
                  .watch(petBasicInfoTabProvider(tabId))
                  .editingGender,
              onChanged: (value) {
                ref
                    .read(petBasicInfoTabProvider(tabId).notifier)
                    .updateGender(value);
              },
            ),
            RadioListTile<String>(
              title: const Text('メス'),
              value: 'Female',
              groupValue: ref
                  .watch(petBasicInfoTabProvider(tabId))
                  .editingGender,
              onChanged: (value) {
                ref
                    .read(petBasicInfoTabProvider(tabId).notifier)
                    .updateGender(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 체중 편집 다이얼로그 표시
  static void showEditWeightDialog(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    final tabState = ref.read(petBasicInfoTabProvider(tabId));
    final weightController = TextEditingController(
      text: tabState.editingWeight?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('体重編集'),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '体重 (kg)',
            hintText: '体重を入力してください',
            suffixText: 'kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0) {
                ref
                    .read(petBasicInfoTabProvider(tabId).notifier)
                    .updateWeight(weight);
                ref
                    .read(petBasicInfoTabProvider(tabId))
                    .weightController
                    ?.text = weight
                    .toString();
                Navigator.pop(context);
              } else {
                SnackBarService.showError(context, '有効な体重を入力してください');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 외모 편집 다이얼로그 표시
  static void showEditAppearanceDialog(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('外見編集'),
        content: TextField(
          controller: ref
              .read(petBasicInfoTabProvider(tabId))
              .appearanceController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: '外見の特徴',
            hintText: 'ペットの外見について説明してください',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 마이크로칩 편집 다이얼로그 표시
  static void showEditMicrochipDialog(
    BuildContext context,
    WidgetRef ref,
    String tabId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('マイクロチップ編集'),
        content: TextField(
          controller: ref
              .read(petBasicInfoTabProvider(tabId))
              .microchipController,
          decoration: const InputDecoration(
            labelText: 'マイクロチップID',
            hintText: 'マイクロチップIDを入力してください',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

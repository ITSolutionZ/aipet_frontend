import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 건강 관리 다이얼로그 헬퍼
class HealthDialogHelper {
  /// 체온 측정 다이얼로그
  static void showTemperatureDialog(BuildContext context) {
    _showInputDialog(
      context: context,
      title: '体温測定',
      label: '体温 (°C)',
      hint: '38.5',
      onSave: (value) {
        final temp = double.tryParse(value);
        if (temp != null && temp >= 35 && temp <= 42) {
          SnackBarService.showSuccess(context, '体温 $temp°C を記録しました');
        } else {
          SnackBarService.showWarning(context, '有効な体温を入力してください (35-42°C)');
        }
      },
    );
  }

  /// 심박수 체크 다이얼로그
  static void showHeartRateDialog(BuildContext context) {
    _showInputDialog(
      context: context,
      title: '心拍数チェック',
      label: '心拍数 (bpm)',
      hint: '90',
      onSave: (value) {
        final rate = int.tryParse(value);
        if (rate != null && rate >= 60 && rate <= 200) {
          SnackBarService.showSuccess(context, '心拍数 ${rate}bpm を記録しました');
        } else {
          SnackBarService.showWarning(context, '有効な心拍数を入力してください (60-200 bpm)');
        }
      },
    );
  }

  /// 수분 섭취량 다이얼로그
  static void showWaterIntakeDialog(BuildContext context) {
    _showInputDialog(
      context: context,
      title: '水分摂取量',
      label: '摂取量 (ml)',
      hint: '200',
      onSave: (value) {
        final amount = int.tryParse(value);
        if (amount != null && amount > 0) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('水分摂取量 ${amount}ml を記録しました')));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('有効な摂取量を入力してください')));
        }
      },
    );
  }

  /// 약 추가 다이얼로그
  static void showAddMedicationDialog(BuildContext context) {
    _showInputDialog(
      context: context,
      title: '薬を追加',
      label: '薬の名前',
      hint: 'フロントライン',
      onSave: (value) {
        if (value.trim().isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$value を追加しました')));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('薬の名前を入力してください')));
        }
      },
    );
  }

  /// 약물 스케줄 표시
  static void showMedicationSchedule(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('投薬スケジュール機能は開発中です')));
  }

  /// 건강 트렌드 표시
  static void showHealthTrends(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('健康トレンド分析機能は開発中です')));
  }

  /// 건강 리포트 표시
  static void showHealthReport(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('健康レポート機能は開発中です')));
  }

  /// 공통 입력 다이얼로그
  static void _showInputDialog({
    required BuildContext context,
    required String title,
    required String label,
    required String hint,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label, hintText: hint),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

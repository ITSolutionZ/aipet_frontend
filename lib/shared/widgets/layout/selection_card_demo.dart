import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'selection_card.dart';

part 'selection_card_demo.g.dart';

/// 🎯 Selection Card Demo State Provider
@riverpod
class SelectionCardDemoController extends _$SelectionCardDemoController {
  @override
  String? build() => null;

  void selectPayment(String? payment) {
    state = payment;
  }
}

/// 🎯 Payment Selection Example State Provider
@riverpod
class PaymentSelectionExampleController extends _$PaymentSelectionExampleController {
  @override
  String? build() => 'credit'; // 기본 선택

  void selectPayment(String? payment) {
    state = payment;
  }
}

/// 사용 예시를 보여주는 데모 위젯
class SelectionCardDemo extends ConsumerWidget {
  const SelectionCardDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPayment = ref.watch(selectionCardDemoControllerProvider);
    final controller = ref.read(selectionCardDemoControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Selection Card Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 受診記録一覧 예시
            const InfoCardList(
              title: '受診記録一覧',
              items: [
                InfoCardItem(title: '健康診断', subtitle: '2025年度', trailingText: '受診日：2025/04/30'),
                InfoCardItem(title: '健康診断', subtitle: '2024年度', trailingText: '受診日：2024/11/24'),
                InfoCardItem(title: '健康診断', subtitle: '2023年度', trailingText: '受診日：2023/10/13'),
              ],
            ),

            const SizedBox(height: 32),

            // 支払い方法選択 예시
            SelectionCardList<String>(
              title: '支払い方法選択',
              selectedValue: selectedPayment,
              onChanged: controller.selectPayment,
              items: const [
                SelectionItem(value: 'credit', title: 'クレジットカード払い', subtitle: 'VISA, Master、JCB対応'),
                SelectionItem(
                  value: 'bank',
                  title: '銀行振込',
                  subtitle: '入金確認後の商品発送となります。\n振り込み手数料はお客様負担となります。',
                ),
                SelectionItem(
                  value: 'convenience',
                  title: 'コンビニ決済',
                  subtitle: '入金確認後の商品発送となります。\n全国のコンビニで利用可能です。',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 실際 사용 시 간단한 예시
class PaymentSelectionExample extends ConsumerWidget {
  const PaymentSelectionExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPayment = ref.watch(paymentSelectionExampleControllerProvider);
    final controller = ref.read(paymentSelectionExampleControllerProvider.notifier);

    return Column(
      children: [
        SelectionCardList<String>(
          title: '支払い方法選択',
          selectedValue: selectedPayment,
          onChanged: controller.selectPayment,
          items: const [
            SelectionItem(value: 'credit', title: 'クレジットカード払い', subtitle: 'VISA, Master、JCB対応'),
            SelectionItem(
              value: 'bank',
              title: '銀行振込',
              subtitle: '入金確認後の商品発送となります。\n振り込み手数料はお客様負担となります。',
            ),
            SelectionItem(
              value: 'convenience',
              title: 'コンビニ決済',
              subtitle: '入金確認後の商品発送となります。\n全国のコンビニで利用可能です。',
            ),
          ],
        ),
      ],
    );
  }
}

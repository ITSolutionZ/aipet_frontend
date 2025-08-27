import 'package:flutter/material.dart';
import 'selection_card.dart';

/// 사용 예시를 보여주는 데모 위젯
class SelectionCardDemo extends StatefulWidget {
  const SelectionCardDemo({super.key});

  @override
  State<SelectionCardDemo> createState() => _SelectionCardDemoState();
}

class _SelectionCardDemoState extends State<SelectionCardDemo> {
  String? selectedPayment;

  @override
  Widget build(BuildContext context) {
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
                InfoCardItem(
                  title: '健康診断',
                  subtitle: '2025年度',
                  trailingText: '受診日：2025/04/30',
                ),
                InfoCardItem(
                  title: '健康診断',
                  subtitle: '2024年度',
                  trailingText: '受診日：2024/11/24',
                ),
                InfoCardItem(
                  title: '健康診断',
                  subtitle: '2023年度',
                  trailingText: '受診日：2023/10/13',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 支払い方法選択 예시
            SelectionCardList<String>(
              title: '支払い方法選択',
              selectedValue: selectedPayment,
              onChanged: (value) {
                setState(() {
                  selectedPayment = value;
                });
              },
              items: const [
                SelectionItem(
                  value: 'credit',
                  title: 'クレジットカード払い',
                  subtitle: 'VISA, Master、JCB対応',
                ),
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

/// 実際 사용 시 간단한 예시
class PaymentSelectionExample extends StatefulWidget {
  const PaymentSelectionExample({super.key});

  @override
  State<PaymentSelectionExample> createState() =>
      _PaymentSelectionExampleState();
}

class _PaymentSelectionExampleState extends State<PaymentSelectionExample> {
  String? selectedPayment = 'credit'; // 기본 선택

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectionCardList<String>(
          title: '支払い方法選択',
          selectedValue: selectedPayment,
          onChanged: (value) {
            setState(() {
              selectedPayment = value;
            });
          },
          items: const [
            SelectionItem(
              value: 'credit',
              title: 'クレジットカード払い',
              subtitle: 'VISA, Master、JCB対応',
            ),
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

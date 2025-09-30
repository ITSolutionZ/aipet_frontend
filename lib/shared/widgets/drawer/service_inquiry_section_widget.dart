import 'package:flutter/material.dart';

/// サービスお問い合わせセクションウィジェット
/// サービスお問い合わせ機能へのアクセスを提供
class ServiceInquirySectionWidget extends StatelessWidget {
  const ServiceInquirySectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 区切り線
          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          // サービスお問い合わせヘッダー
          const Row(
            children: [
              Icon(Icons.contact_support, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'サービスお問い合わせ',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

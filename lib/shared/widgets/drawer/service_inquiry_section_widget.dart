import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          // サービスお問い合わせヘッダー（クリック可能）
          InkWell(
            onTap: () => _navigateToContactForm(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.contact_support, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'サービスお問い合わせ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 説明テキスト
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              'ご質問やサポートが必要な場合はお気軽にお問い合わせください',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// お問い合わせフォーム画面へ遷移
  void _navigateToContactForm(BuildContext context) {
    context.push(RouteConstants.contactFormRoute);
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// サービスお問い合わせセクションウィジェット
/// サービスお問い合わせ機能へのアクセスを提供
class ServiceInquirySectionWidget extends StatelessWidget {
  const ServiceInquirySectionWidget({super.key});

  /// Google Form URL
  static const String _googleFormUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLScCCXFO2Uie5vNCye0UUpBnQtOCvXSiXpT97tzZisJjxmrS8w/viewform?usp=dialog';

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
            onTap: () => _openGoogleForm(context),
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
                      'お問い合わせ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
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

  /// Google Formを開く
  Future<void> _openGoogleForm(BuildContext context) async {
    final url = Uri.parse(_googleFormUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

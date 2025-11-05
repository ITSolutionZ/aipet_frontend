import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/shared.dart';

/// 404 페이지를 위한 커스텀 화면
class PageNotFoundScreen extends StatelessWidget {
  final String? errorMessage;
  final String? location;

  const PageNotFoundScreen({super.key, this.errorMessage, this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.pointBrown,
        foregroundColor: AppColors.pointOffWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Page Not Found',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointOffWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Container(
        color: AppColors.toneOffWhite,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 에러 메시지
                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: AppSpacing.xl),
                // 홈으로 가기 버튼
                GestureDetector(
                  onTap: () => context.go('/home'),
                  child: Text(
                    'Home',
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.lg,
                      color: AppColors.pointBrown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

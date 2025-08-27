import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/shared.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),

              // ロゴエリア
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    // 犬のシルエット
                    Positioned(
                      left: 10,
                      bottom: 15,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.pointBrown.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          Icons.pets,
                          size: 25,
                          color: AppColors.pointBrown.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    // 猫のシルエット
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        width: 60,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.pointBrown.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 猫の耳
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 8,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.pointBrown.withValues(
                                      alpha: 0.6,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      topRight: Radius.circular(5),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 8,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.pointBrown.withValues(
                                      alpha: 0.6,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      topRight: Radius.circular(5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Icon(
                              Icons.pets,
                              size: 20,
                              color: AppColors.pointBrown.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // aipet ロゴテキスト
              Text(
                'aipet',
                style: AppFonts.fredoka(
                  fontSize: 32,
                  color: AppColors.pointBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 区切り線
              Container(
                height: 1,
                width: double.infinity,
                color: AppColors.pointBrown.withValues(alpha: 0.3),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Welcome テキスト
              Text(
                'ようこそ',
                style: AppFonts.fredoka(
                  fontSize: 24,
                  color: AppColors.pointBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 완료메시지 카드
              Expanded(
                child: WhiteCard(
                  borderWidth: 2,
                  borderColor: AppColors.pointBrown.withValues(alpha: 0.3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '登録が完了しました！',
                        style: AppFonts.fredoka(
                          fontSize: 20,
                          color: AppColors.pointBrown,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      const Text(
                        'ホームに戻り、ログインしてください。',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.pointBrown,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        '詳しい情報登録、修正は設定画面で登録してください。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ペット登録へボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(
                    '${RouteConstants.petEmptyRoute}?afterRegistration=true',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                  ),
                  child: Text(
                    'ペット登録へ',
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.lg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 後で登録ボタン
              TextButton(
                onPressed: () => context.go(RouteConstants.homeRoute),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: Text(
                  '後で登録する',
                  style: AppFonts.base(
                    fontSize: AppFonts.baseSize,
                    color: AppColors.pointBrown.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

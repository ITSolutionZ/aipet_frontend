import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/shared/core/services/secure_storage_service.dart';
import 'package:aipet_frontend/shared/core/services/ui_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ドロワーのビジネスロジックを管理するコントローラー
///
/// ログアウト、ナビゲーションなどの機能を提供します。
class DrawerController extends BaseController {
  DrawerController(super.ref);

  /// ログアウト処理を実行
  ///
  /// [context] - UI操作用のBuildContext
  /// [return] - 成功した場合true、キャンセルまたは失敗の場合false
  Future<bool> logout(BuildContext context) async {
    final result = await safeExecute<bool>(() async {
      // 確認ダイアログ表示
      final shouldLogout = await UiService.showConfirmDialog(
        context,
        title: 'ログアウト',
        content: 'ログアウトしますか？',
        confirmText: 'ログアウト',
        cancelText: 'キャンセル',
      );

      if (!shouldLogout) return false;

      // ローディング表示
      if (context.mounted) {
        UiService.showLoadingDialog(context, 'ログアウト中...');
      }

      try {
        // セキュアストレージの認証情報のみ削除 (ログアウト処理)
        await SecureStorageService.logout();

        if (context.mounted) {
          UiService.hideLoadingDialog(context);
          UiService.showSuccess(context, 'ログアウトしました');
          context.go('/login');
        }

        return true;
      } catch (error) {
        if (context.mounted) {
          UiService.hideLoadingDialog(context);
          UiService.showError(context, 'ログアウト中にエラーが発生しました');
        }
        handleError(error);
        return false;
      }
    }, errorMessage: 'ログアウト処理');

    return result ?? false;
  }

  /// ペット追加画面へ遷移
  ///
  /// [context] - ナビゲーション用のBuildContext
  Future<void> navigateToPetRegistration(BuildContext context) async {
    if (!context.mounted) return;

    // Daily Health 스타일 펫 등록 화면으로 이동
    await context.push(RouteConstants.dailyPetRegistrationRoute);
    // 네비게이션 완료 후 drawer 자동으로 닫힘
  }

  /// プロフィール編集画面へ遷移
  ///
  /// [context] - ナビゲーション用のBuildContext
  void navigateToProfileEdit(BuildContext context) {
    if (!context.mounted) return;

    // ドロワーを閉じる
    Navigator.of(context).pop();

    // プロフィール編集画面へ遷移
    context.push(RouteConstants.profileEditRoute);
  }

  /// ペット詳細画面へ遷移
  ///
  /// [context] - ナビゲーション用のBuildContext
  /// [petId] - ペットID
  void navigateToPetDetail(BuildContext context, String petId) {
    if (!context.mounted) return;

    // ドロワーを閉じる
    Navigator.of(context).pop();

    // ペット詳細画面へ遷移
    context.push('/pet-profile/$petId');
  }
}

/// DrawerController Provider
final drawerControllerProvider = Provider.autoDispose<DrawerController>(
  (ref) => DrawerController(ref as WidgetRef),
);

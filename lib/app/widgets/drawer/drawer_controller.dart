import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/app/providers/app_initialization_provider.dart';
import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    try {
      LoggerService.debug('🔓 ログアウト処理開始');

      // 1. 認証トークンとセッションのみクリア (プロフィールデータは保持)
      try {
        await _clearAuthDataOnly();
        LoggerService.debug('✅ 認証データクリア完了');
      } catch (e) {
        LoggerService.debug('⚠️ 認証データクリア失敗: $e');
      }

      // 2. アプリ初期化状態をリセット (認証状態のみ)
      try {
        ref.read(appInitializationProvider.notifier).reset();
        LoggerService.debug('✅ アプリ状態リセット完了');
      } catch (e) {
        LoggerService.debug('⚠️ アプリ状態リセット失敗: $e');
      }

      LoggerService.debug('🎉 ログアウト処理完了');

      // 3. ログイン画面へ遷移
      if (context.mounted) {
        context.go(RouteConstants.loginRoute);

        // 성공 메시지 표示
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ログアウトしました'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      return true;
    } catch (error) {
      LoggerService.debug('❌ ログアウトエラー: $error');

      // エラーメッセージ表示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ログアウトに失敗しました: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return false;
    }
  }

  /// 認証関連データのみクリア (プロフィール、ペット、履歴は保持)
  Future<void> _clearAuthDataOnly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const secureStorage = FlutterSecureStorage();

      // 認証トークンのみ削除
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('token_expiry_time');
      await prefs.remove('last_data_sync');
      await prefs.remove('user_session');

      // SecureStorageの認証データ削除
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      await secureStorage.delete(key: 'auth_token');

      LoggerService.debug('✅ 認証トークンとセッションを削除しました');
      LoggerService.debug('ℹ️ ユーザープロフィールとペットデータは保持されます');
    } catch (e) {
      LoggerService.debug('❌ 認証データクリア失敗: $e');
      rethrow;
    }
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

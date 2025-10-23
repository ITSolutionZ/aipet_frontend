import 'package:firebase_auth/firebase_auth.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎯 Firebase Login State Provider
final firebaseLoginProvider =
    NotifierProvider<FirebaseLoginController, FirebaseLoginState>(
      FirebaseLoginController.new,
    );

class FirebaseLoginController extends Notifier<FirebaseLoginState> {
  @override
  FirebaseLoginState build() {
    _checkCurrentUser();
    _listenToAuthChanges();
    return const FirebaseLoginState();
  }

  void _checkCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    state = state.copyWith(currentUser: user);
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      state = state.copyWith(currentUser: user);
    });
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  Future<void> signInAnonymously({
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    if (state.isLoading) return;

    setLoading(true);

    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();

      if (credential.user != null) {
        LoggerService.debug('✅ Firebase 익명 로그인 성공: ${credential.user!.uid}');
        onSuccess?.call();
      }
    } catch (e) {
      LoggerService.debug('❌ Firebase 로그인 실패: $e');
      onError?.call(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      LoggerService.debug('✅ Firebase 로그아웃 성공');
    } catch (e) {
      LoggerService.debug('❌ Firebase 로그아웃 실패: $e');
    }
  }
}

class FirebaseLoginState {
  final bool isLoading;
  final User? currentUser;

  const FirebaseLoginState({this.isLoading = false, this.currentUser});

  FirebaseLoginState copyWith({bool? isLoading, User? currentUser}) {
    return FirebaseLoginState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

/// 실제 Firebase Auth 로그인 버튼
///
/// Google 로그인을 통해 Firebase 인증을 수행합니다.
class FirebaseLoginButton extends ConsumerWidget {
  final VoidCallback? onLoginSuccess;
  final Function(String)? onLoginError;

  const FirebaseLoginButton({
    super.key,
    this.onLoginSuccess,
    this.onLoginError,
  });

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(firebaseLoginProvider);

    if (authState.currentUser != null) {
      // 로그인된 상태
      return Card(
        color: Colors.green.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Firebase 로그인 완료',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UID: ${authState.currentUser!.uid}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(firebaseLoginProvider.notifier).signOut();
                    _showSnackBar(context, 'ログアウトしました', Colors.green);
                  },
                  child: const Text('로그아웃'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 로그인되지 않은 상태
    return Card(
      color: Colors.blue.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.login, color: Colors.blue, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Firebase 로그인 필요',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '먼저 Firebase에 로그인해주세요',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        ref
                            .read(firebaseLoginProvider.notifier)
                            .signInAnonymously(
                              onSuccess: onLoginSuccess,
                              onError: (error) {
                                onLoginError?.call(error);
                                _showSnackBar(
                                  context,
                                  'ログイン失敗: $error',
                                  Colors.red,
                                );
                              },
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Firebase 익명 로그인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

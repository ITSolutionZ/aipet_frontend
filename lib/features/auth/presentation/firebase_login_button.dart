import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// 실제 Firebase Auth 로그인 버튼
///
/// Google 로그인을 통해 Firebase 인증을 수행합니다.
class FirebaseLoginButton extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final Function(String)? onLoginError;

  const FirebaseLoginButton({
    super.key,
    this.onLoginSuccess,
    this.onLoginError,
  });

  @override
  State<FirebaseLoginButton> createState() => _FirebaseLoginButtonState();
}

class _FirebaseLoginButtonState extends State<FirebaseLoginButton> {
  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();

    // 인증 상태 변화 감지
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  void _checkCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _signInAnonymously() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 익명 로그인 (데모용)
      final credential = await FirebaseAuth.instance.signInAnonymously();

      if (credential.user != null) {
        debugPrint('✅ Firebase 익명 로그인 성공: ${credential.user!.uid}');
        widget.onLoginSuccess?.call();
      }
    } catch (e) {
      debugPrint('❌ Firebase 로그인 실패: $e');
      widget.onLoginError?.call(e.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      debugPrint('✅ Firebase 로그아웃 성공');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃 되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Firebase 로그아웃 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser != null) {
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
                          'UID: ${_currentUser!.uid}',
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
                  onPressed: _signOut,
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
                onPressed: _isLoading ? null : _signInAnonymously,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
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

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/shared.dart';

/// 앱 잠금 해제 다이얼로그 (PIN 또는 생체인증)
class AppLockDialog extends StatefulWidget {
  final bool enableBiometric;
  final bool enablePin;
  final VoidCallback onSuccess;

  const AppLockDialog({
    super.key,
    this.enableBiometric = false,
    this.enablePin = false,
    required this.onSuccess,
  });

  @override
  State<AppLockDialog> createState() => _AppLockDialogState();
}

class _AppLockDialogState extends State<AppLockDialog> {
  late BiometricAuthService _biometricService;
  final TextEditingController _pinController = TextEditingController();
  String _biometricType = '指紋';
  bool _isAttemptingBiometric = false;
  bool _showPinInput = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _biometricService = BiometricAuthService.instance;
    _initializeBiometric();
  }

  Future<void> _initializeBiometric() async {
    if (!widget.enableBiometric) return;

    final biometrics = await _biometricService.getAvailableBiometrics();
    String type = '生体認証';

    if (biometrics.contains(BiometricType.fingerprint)) {
      type = '指紋';
    } else if (biometrics.contains(BiometricType.face)) {
      type = '顔';
    } else if (biometrics.contains(BiometricType.iris)) {
      type = '虹彩';
    }

    setState(() {
      _biometricType = type;
    });

    // 자동으로 생체인증 시작
    if (mounted) {
      await _attemptBiometric();
    }
  }

  Future<void> _attemptBiometric() async {
    if (_isAttemptingBiometric) return;

    setState(() {
      _isAttemptingBiometric = true;
      _errorMessage = '';
    });

    try {
      final isAuthenticated = await _biometricService.authenticate();

      if (isAuthenticated && mounted) {
        widget.onSuccess();
        Navigator.of(context).pop();
      } else if (mounted) {
        setState(() {
          _errorMessage = '$_biometricType認証に失敗しました';
          _isAttemptingBiometric = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '$_biometricType認証エラー: $e';
          _isAttemptingBiometric = false;
        });
      }
    }
  }

  Future<void> _verifyPin() async {
    if (_pinController.text.isEmpty) {
      setState(() {
        _errorMessage = 'PIN番号を入力してください';
      });
      return;
    }

    // SharedPreferences에서 저장된 PIN과 비교
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('user_pin') ?? '';

    if (_pinController.text == savedPin && savedPin.isNotEmpty) {
      widget.onSuccess();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _errorMessage = 'PINが正しくありません';
        _pinController.clear();
      });
    }
  }

  /// PIN 삭제
  Future<void> _deletePin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PIN削除'),
        content: const Text('PINを削除しますか？\n次回からPIN認証なしでログインできます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_pin');
        await prefs.remove('pin_enabled');

        if (mounted) {
          widget.onSuccess();
          Navigator.of(context).pop();

          // 성공 메시지
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ PINを削除しました'),
              backgroundColor: AppColors.pointGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'PIN削除に失敗しました: $e';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 뒤로가기 버튼 비활성화
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목
              Text(
                'アプリをロック解除',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 생체인증 또는 PIN 입력
              if (widget.enableBiometric && !_showPinInput)
                Column(
                  children: [
                    // 생체인증 아이콘
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.toneOffWhite,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _biometricType == '顔' ? Icons.face : Icons.fingerprint,
                        size: 40,
                        color: AppColors.pointDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '$_biometricType認証してください',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 로딩 또는 에러 메시지
                    if (_isAttemptingBiometric)
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (_errorMessage.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ElevatedButton.icon(
                            onPressed: _attemptBiometric,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('再試行'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pointBrown,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),

                    // PIN으로 인증 버튼
                    if (widget.enablePin)
                      Column(
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showPinInput = true;
                                _errorMessage = '';
                              });
                            },
                            child: const Text('PIN码で認証'),
                          ),
                        ],
                      ),
                  ],
                )
              else
                // PIN 입력
                Column(
                  children: [
                    Text(
                      'PIN码を入力',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        // 생체인증으로 돌아가기
                        if (widget.enableBiometric)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _showPinInput = false;
                                  _pinController.clear();
                                  _errorMessage = '';
                                });
                                _attemptBiometric();
                              },
                              child: const Text('戻る'),
                            ),
                          ),
                        if (widget.enableBiometric)
                          const SizedBox(width: AppSpacing.md),
                        // 확인 버튼
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _verifyPin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pointBrown,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('確認'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // PIN 삭제 버튼
                    TextButton.icon(
                      onPressed: _deletePin,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('PIN削除'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}

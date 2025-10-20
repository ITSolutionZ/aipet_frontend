import 'package:aipet_frontend/shared/design/design.dart';
import 'package:aipet_frontend/shared/services/biometric_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String _biometricType = '지문';
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
    String type = '생체인증';

    if (biometrics.contains(BiometricType.fingerprint)) {
      type = '지문';
    } else if (biometrics.contains(BiometricType.face)) {
      type = '얼굴';
    } else if (biometrics.contains(BiometricType.iris)) {
      type = '홍채';
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
          _errorMessage = '$_biometricType 인증 실패';
          _isAttemptingBiometric = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '$_biometricType 인증 오류: $e';
          _isAttemptingBiometric = false;
        });
      }
    }
  }

  Future<void> _verifyPin() async {
    if (_pinController.text.isEmpty) {
      setState(() {
        _errorMessage = 'PIN을 입력하세요';
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
        _errorMessage = 'PIN이 올바르지 않습니다';
        _pinController.clear();
      });
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
                        _biometricType == '얼굴' ? Icons.face : Icons.fingerprint,
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
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
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

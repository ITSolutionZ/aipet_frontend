import 'package:aipet_frontend/shared/services/biometric_auth_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

class BiometricSecurityScreen extends ConsumerStatefulWidget {
  const BiometricSecurityScreen({super.key});

  @override
  ConsumerState<BiometricSecurityScreen> createState() =>
      _BiometricSecurityScreenState();
}

class _BiometricSecurityScreenState
    extends ConsumerState<BiometricSecurityScreen> {
  late BiometricAuthService _biometricService;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isPinEnabled = false;
  bool _isBiometricEnabled = false;

  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _biometricService = BiometricAuthService.instance;
    _initializeBiometric();
    _loadSettings();
  }

  Future<void> _initializeBiometric() async {
    final canAuth = await _biometricService.canAuthenticateWithBiometrics();
    final biometrics = await _biometricService.getAvailableBiometrics();

    setState(() {
      _isBiometricAvailable = canAuth;
      _availableBiometrics = biometrics;
    });
  }

  Future<void> _loadSettings() async {
    // ✅ SecureStorageService 사용
    final pinEnabled =
        await SecureStorageService.getBool('pin_enabled') ?? false;
    final biometricEnabled =
        await SecureStorageService.getBool('biometric_enabled') ?? false;

    setState(() {
      _isPinEnabled = pinEnabled;
      _isBiometricEnabled = biometricEnabled;
    });
  }

  Future<void> _savePIN() async {
    if (_pinController.text != _confirmPinController.text) {
      SnackBarService.showError(context, 'PINが一致しません');
      return;
    }

    if (_pinController.text.length < 4) {
      SnackBarService.showError(context, 'PINは最低4桁以上である必要があります');
      return;
    }

    // ✅ SecureStorageService 사용
    await SecureStorageService.setString('user_pin', _pinController.text);
    await SecureStorageService.setBool('pin_enabled', true);

    setState(() {
      _isPinEnabled = true;
    });

    if (mounted) {
      SnackBarService.showSuccess(context, 'PINが設定されました');
    }
  }

  Future<void> _testBiometric() async {
    final isAuthenticated = await _biometricService.authenticate();

    if (isAuthenticated) {
      // ✅ SecureStorageService 사용
      await SecureStorageService.setBool('biometric_enabled', true);

      if (mounted) {
        setState(() {
          _isBiometricEnabled = true;
        });
        SnackBarService.showSuccess(context, '生体認証が活性化されました');
      }
    } else {
      if (mounted) {
        SnackBarService.showError(context, '生体認証に失敗しました');
      }
    }
  }

  Future<void> _disableBiometric() async {
    // ✅ SecureStorageService 사용
    await SecureStorageService.setBool('biometric_enabled', false);
    if (mounted) {
      setState(() {
        _isBiometricEnabled = false;
      });
      SnackBarService.showSuccess(context, '生体認証が無効化されました');
    }
  }

  Future<void> _disablePin() async {
    // ✅ SecureStorageService 사용
    await SecureStorageService.setBool('pin_enabled', false);
    if (mounted) {
      setState(() {
        _isPinEnabled = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN码が無効化されました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientAppBar(title: ''),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // PIN 설정 섹션
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.xl),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PIN码設定',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Switch(
                      value: _isPinEnabled,
                      onChanged: (value) {
                        if (value) {
                          _showPinDialog();
                        } else {
                          _disablePin();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _isPinEnabled ? 'PIN码がアクティブです' : 'PIN码でアプリをロックできます',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 생체인증 섹션
          if (_isBiometricAvailable)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getBiometricLabel(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _getBiometricDescription(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isBiometricEnabled,
                        onChanged: (value) async {
                          if (value) {
                            await _testBiometric();
                          } else {
                            await _disableBiometric();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: const Text(
                'このデバイスは生体認証に対応していません',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  void _showPinDialog() {
    _pinController.clear();
    _confirmPinController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PIN码を設定'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'PIN码を入力',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'PIN码を再入力',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              _savePIN();
              Navigator.pop(context);
            },
            child: const Text('設定'),
          ),
        ],
      ),
    );
  }

  String _getBiometricLabel() {
    if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return '指紋認証';
    } else if (_availableBiometrics.contains(BiometricType.face)) {
      return '顔認証';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return '虹彩認証';
    }
    return '生体認証';
  }

  String _getBiometricDescription() {
    if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return '指紋でアプリをロック';
    } else if (_availableBiometrics.contains(BiometricType.face)) {
      return '顔認証でアプリをロック';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return '虹彩認証でアプリをロック';
    }
    return '生体認証でアプリをロック';
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }
}

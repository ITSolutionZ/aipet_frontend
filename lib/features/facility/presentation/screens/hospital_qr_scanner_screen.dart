import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HospitalQrScannerScreen extends ConsumerStatefulWidget {
  const HospitalQrScannerScreen({super.key});

  @override
  ConsumerState<HospitalQrScannerScreen> createState() =>
      _HospitalQrScannerScreenState();
}

class _HospitalQrScannerScreenState
    extends ConsumerState<HospitalQrScannerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'QR受付',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // 카메라 뷰 대신 모의 스캐너 화면
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 스캐너 프레임
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // 모서리 장식
                      Positioned(
                        top: -2,
                        left: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.green, width: 4),
                              left: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.green, width: 4),
                              right: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        left: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.green, width: 4),
                              left: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.green, width: 4),
                              right: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                      // 스캔 라인 애니메이션
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 2,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.green,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'QR 코드를 프레임 안에 맞춰주세요',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.xl),
                // 테스트용 버튼
                ElevatedButton(
                  onPressed: () => _simulateQrScan(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: const Text('テストスキャン（開発用）'),
                ),
              ],
            ),
          ),
          // 플래시 버튼
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              onPressed: () {
                // 플래시 토글 기능 (모의)
                SnackBarService.showInfo(
                  context,
                  'フラッシュ機能（開発中）',
                  duration: const Duration(seconds: 1),
                );
              },
              icon: const Icon(Icons.flash_off, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateQrScan() {
    // 모의 QR 스캔 결과
    final mockScanResult = {
      'hospitalName': '119동물병원(대구)',
      'name': '119동물병원(대구)',
      'queueNumber':
          'A-${DateTime.now().millisecond.toString().padLeft(3, '0')}',
      'reservationTime':
          '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      'waitingCount': 3,
    };

    // 스캔 성공 효과
    _showScanSuccessEffect();

    // 1초 후 결과 반환
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pop(mockScanResult);
      }
    });
  }

  void _showScanSuccessEffect() {
    // 성공 효과 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              SizedBox(height: AppSpacing.md),
              Text(
                'QR 코드 스캔 성공!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 1초 후 다이얼로그 닫기
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.pop();
      }
    });
  }
}

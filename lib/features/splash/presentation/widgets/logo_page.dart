import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';

class LogoPage extends ConsumerStatefulWidget {
  const LogoPage({super.key});

  @override
  ConsumerState<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends ConsumerState<LogoPage> {
  @override
  void initState() {
    super.initState();
    _initializeLogo();
  }

  Future<void> _initializeLogo() async {
    // 위젯 빌드 완료 후 ITZ 로고만 3초간 표시
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ITZ 로고를 3초간 표시
      await Future.delayed(const Duration(seconds: 3));
      // 3초 후 splash 화면으로 이동
      if (mounted) {
        context.go(AppRouter.splashRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ITZ 로고만 표시 (196x130 크기, 흰색 배경)
        Container(
          width: 196,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/icons/itz.png', fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }
}

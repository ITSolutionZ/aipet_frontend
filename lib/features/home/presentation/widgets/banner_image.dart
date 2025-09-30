import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// 배너 이미지
/// 3개의 배너 이미지가 자동으로 순환하며 표시
class BannerImage extends StatefulWidget {
  const BannerImage({super.key});

  @override
  State<BannerImage> createState() => _BannerImageState();
}

class _BannerImageState extends State<BannerImage> {
  Timer? _timer;
  int _currentBannerIndex = 0;

  static const List<String> _bannerImages = [
    'assets/images/home_banner/banner1.png',
    'assets/images/home_banner/banner2.png',
    'assets/images/home_banner/banner3.png',
  ];

  @override
  void initState() {
    super.initState();
    // 초기 배너를 랜덤으로 선택
    _currentBannerIndex = Random().nextInt(_bannerImages.length);
    // 5초마다 배너 변경
    _startBannerRotation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startBannerRotation() {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        setState(() {
          _currentBannerIndex =
              (_currentBannerIndex + 1) % _bannerImages.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Image.asset(
        _bannerImages[_currentBannerIndex],
        key: ValueKey(_currentBannerIndex),
        width: double.infinity,
        fit: BoxFit.fitWidth, // 너비에 맞추고 높이는 이미지 비율 유지
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';

import 'package:aipet_frontend/features/home/data/banner_assets.dart';
import 'package:flutter/material.dart';

/// 홈 콘텐츠 배너 이미지
/// home_banners 폴더의 모든 배너 이미지가 자동으로 순환하며 표시
class BannerImage extends StatefulWidget {
  const BannerImage({super.key});

  @override
  State<BannerImage> createState() => _BannerImageState();
}

class _BannerImageState extends State<BannerImage> {
  Timer? _timer;
  int _currentBannerIndex = 0;

  // 홈 콘텐츠 배너 이미지 목록을 BannerAssets에서 가져옴
  List<String> get _bannerImages => BannerAssets.homeBannerImages;

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

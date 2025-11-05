import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/data.dart';



/// 앱바용 배너 이미지
/// appbar_banners 폴더의 모든 배너 이미지가 자동으로 순환하며 표시
class AppbarBannerImage extends StatefulWidget {
  const AppbarBannerImage({super.key});

  @override
  State<AppbarBannerImage> createState() => _AppbarBannerImageState();
}

class _AppbarBannerImageState extends State<AppbarBannerImage> {
  Timer? _timer;
  int _currentBannerIndex = 0;

  // 앱바 배너 이미지 목록을 BannerAssets에서 가져옴
  List<String> get _bannerImages => BannerAssets.appbarBannerImages;

  @override
  void initState() {
    super.initState();
    // 초기 배너를 랜덤으로 선택
    _currentBannerIndex = Random().nextInt(_bannerImages.length);
    // 10초마다 배너 변경 (앱바는 조금 더 빠르게)
    _startBannerRotation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startBannerRotation() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
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
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Image.asset(
        _bannerImages[_currentBannerIndex],
        key: ValueKey(_currentBannerIndex),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.centerLeft, // 이미지를 왼쪽 중앙에 정렬
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image, size: 40, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}

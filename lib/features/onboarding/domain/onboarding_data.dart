import 'package:flutter/material.dart';

import 'entities/entities.dart';

/// 온보딩 데이터
class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      imagePath: 'assets/images/onboarding/onboarding1.png',
      title: 'Welcome',
      subtitle: '毎日の記録、愛に繋ぐ',
      description: '記録から残る愛の痕跡',
      imageAlignment: Alignment.bottomCenter, // 손바닥 위의 강아지 발 (하단 중앙)
      imageFit: BoxFit.cover, // 전체 화면을 덮되 하단 부분이 보이도록
      useCustomImageDisplay: true, // 커스텀 표시 사용
    ),
    OnboardingPage(
      imagePath: 'assets/images/onboarding/onboarding2.png',
      title: 'Together',
      subtitle: '笑顔溢れる散歩時間\n一緒なら楽しい思い出',
      description: '朝も夜もいつでも楽しい\nあなたと一緒なら空も綺麗',
      imageAlignment: Alignment.topCenter, // 산책하는 강아지와 사람 (상단 중앙)
      imageFit: BoxFit.cover, // 전체 화면을 덮되 상단 부분이 보이도록
      useCustomImageDisplay: true, // 커스텀 표시 사용
    ),
    OnboardingPage(
      imagePath: 'assets/images/onboarding/onboarding3.png',
      title: 'Intelligent',
      subtitle: '賢い体調管理の始まり',
      description: '状況によるアドバイスで\n賢い健康管理',
      imageAlignment: Alignment.center, // 골든 리트리버 강아지 얼굴 (중앙)
      imageFit: BoxFit.cover, // 전체 화면을 덮되 중앙 부분이 보이도록
      useCustomImageDisplay: true, // 커스텀 표시 사용
    ),
    OnboardingPage(
      imagePath: 'assets/images/onboarding/onboarding4.png',
      title: 'Reservations',
      subtitle: 'アプリ一つで簡単に\nトリミングから病院まで',
      description: '幅広い予約完了\nアプリだけで登録なしで素早く',
      imageAlignment: Alignment.center, // 포메라니안 강아지 얼굴 (중앙)
      imageFit: BoxFit.cover, // 전체 화면을 덮되 중앙 부분이 보이도록
      useCustomImageDisplay: true, // 커스텀 표시 사용
    ),
  ];
}

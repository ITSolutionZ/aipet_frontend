class OnboardingPage {
  final String imagePath;
  final String title;
  final String subtitle;
  final String description;

  const OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}

class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      imagePath: 'assets/images/onboarding/onboarding1.png',
      title: 'Welcome',
      subtitle: '毎日の記録、愛に繋ぐ',
      description: '記録から残る愛の痕跡',
    ),
    OnboardingPage(
      imagePath: 'assets/images/onboarding/onboarding2.png',
      title: 'Together',
      subtitle: '笑顔溢れる散歩時間\n一緒なら楽しい思い出',
      description: '朝も夜もいつでも楽しい\nあなたと一緒なら空も綺麗',
    ),
    OnboardingPage(
      imagePath: 'assets/images/onboarding/onboarding3.png',
      title: 'Intelligent',
      subtitle: '賢い体調管理の始まり',
      description: '状況によるアドバイスで\n賢い健康管理',
    ),
    OnboardingPage(
      imagePath: 'assets/images/onboarding/onboarding4.png',
      title: 'Reservations',
      subtitle: 'アプリ一つで簡単に\nトリミングから病院まで',
      description: '幅広い予約完了\nアプリだけで登録なしで素早く',
    ),
  ];
}

/// 드로워 로컬 데이터 소스
/// 드로워 화면에 표시되는 사용자 통계 및 정보를 제공
class DrawerLocalDatasource {
  /// 사용자 통계 데이터
  static const Map<String, int> userStats = {
    'subscriptions': 0,
    'posts': 0,
    'comments': 0,
  };

  /// 사용자 프로필 정보
  static const Map<String, dynamic> userProfile = {
    'name': 'ユーザー',
    'email': 'user@example.com',
    'imagePath': null, // 사용자 이미지 경로 (null이면 기본 로고 사용)
    'joinDate': '2024-01-01',
  };


  /// 서비스 문의 섹션 데이터
  static const Map<String, dynamic> serviceInquiry = {
    'title': 'サービスお問い合わせ',
    'description': 'ご質問やサポートが必要な場合はお気軽にお問い合わせください',
    'contactEmail': 'support@aipet.com',
    'isEnabled': true,
  };

  /// 사용자 통계 가져오기
  static Map<String, int> getUserStats() {
    return Map.from(userStats);
  }

  /// 사용자 프로필 가져오기
  static Map<String, dynamic> getUserProfile() {
    return Map.from(userProfile);
  }


  /// 서비스 문의 데이터 가져오기
  static Map<String, dynamic> getServiceInquiry() {
    return Map.from(serviceInquiry);
  }

  /// 통계 업데이트 (시뮬레이션)
  static void updateStats({int? subscriptions, int? posts, int? comments}) {
    if (subscriptions != null) {
      userStats['subscriptions'] = subscriptions;
    }
    if (posts != null) {
      userStats['posts'] = posts;
    }
    if (comments != null) {
      userStats['comments'] = comments;
    }
  }

  /// 프로필 업데이트 (시뮬레이션)
  static void updateProfile({String? name, String? email, String? imagePath}) {
    if (name != null) {
      userProfile['name'] = name;
    }
    if (email != null) {
      userProfile['email'] = email;
    }
    if (imagePath != null) {
      userProfile['imagePath'] = imagePath;
    }
  }
}

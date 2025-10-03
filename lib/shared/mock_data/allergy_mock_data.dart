import 'package:aipet_frontend/features/allergy/domain/entities/allergy_post_entity.dart';

/// 알레르기 커뮤니티 Mock 데이터
class AllergyMockData {
  /// 알레르기 발생 게시글 목록
  static final List<AllergyPostEntity> allergyPosts = [
    AllergyPostEntity(
      id: '1',
      authorId: 'user1',
      authorNickname: 'YILPKZZF',
      allergyType: AllergyType.skinDisease,
      hasAllergy: true,
      title: 'シロ犬チュスン ぶた犬とります。シワ ほえ物 まれま犬そ つとぎべ\nつ犬たと',
      content:
          '큼연했었던 먹거리의 원료를 분석하여,\n종붙되는 원료를 찾아내고\n이를 분석하여 알러지 의심 원료를 찾아드립니다.',
      imageUrls: [],
      viewCount: 1556,
      commentCount: 1,
      createdAt: DateTime(2025, 6, 10),
    ),
    AllergyPostEntity(
      id: '2',
      authorId: 'user2',
      authorNickname: 'luejCSJm',
      allergyType: AllergyType.skinDisease,
      hasAllergy: true,
      title: '강아지 피부',
      content: '강아지 피부 알레르기가 심해요. 어떻게 관리하면 좋을까요?',
      imageUrls: ['https://example.com/skin1.jpg'],
      viewCount: 2413,
      commentCount: 7,
      createdAt: DateTime(2025, 3, 27),
    ),
    AllergyPostEntity(
      id: '3',
      authorId: 'user3',
      authorNickname: 'bNdVl65C',
      allergyType: AllergyType.skinDisease,
      hasAllergy: true,
      title: '피부병',
      content: '피부병 치료 경험 공유합니다.',
      imageUrls: ['https://example.com/skin2.jpg'],
      viewCount: 2555,
      commentCount: 2,
      createdAt: DateTime(2025, 1, 25),
    ),
  ];

  /// 알레르기 미발생 게시글 목록
  static final List<AllergyPostEntity> nonAllergyPosts = [
    AllergyPostEntity(
      id: '4',
      authorId: 'user4',
      authorNickname: 'HappyPet',
      allergyType: AllergyType.skinDisease,
      hasAllergy: false,
      title: '알레르기 없는 사료 추천',
      content: '저희 강아지는 알레르기가 없어서 이 사료를 먹고 있어요.',
      imageUrls: [],
      viewCount: 892,
      commentCount: 5,
      createdAt: DateTime(2025, 5, 15),
    ),
    AllergyPostEntity(
      id: '5',
      authorId: 'user5',
      authorNickname: 'HealthyDog',
      allergyType: AllergyType.skinDisease,
      hasAllergy: false,
      title: '건강한 피부 관리법',
      content: '알레르기 예방을 위한 피부 관리 팁을 공유합니다.',
      imageUrls: ['https://example.com/healthy1.jpg'],
      viewCount: 1234,
      commentCount: 3,
      createdAt: DateTime(2025, 4, 20),
    ),
  ];

  /// 필터별 게시글 가져오기
  static List<AllergyPostEntity> getPostsByFilter({
    AllergyType? type,
    bool? hasAllergy,
  }) {
    final allPosts = [...allergyPosts, ...nonAllergyPosts];

    return allPosts.where((post) {
      if (type != null && post.allergyType != type) {
        return false;
      }
      if (hasAllergy != null && post.hasAllergy != hasAllergy) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 알레르기 타입별 게시글 수 가져오기
  static Map<AllergyType, int> getPostCountByType({bool? hasAllergy}) {
    final posts = getPostsByFilter(hasAllergy: hasAllergy);
    final Map<AllergyType, int> countMap = {};

    for (final type in AllergyType.values) {
      countMap[type] = posts.where((p) => p.allergyType == type).length;
    }

    return countMap;
  }
}

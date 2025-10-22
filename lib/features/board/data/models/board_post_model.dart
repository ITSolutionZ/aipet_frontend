/// 掲示板投稿モデル
class BoardPost {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String? authorProfileImage;
  final String category;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> imageUrls;
  final List<String> tags;

  const BoardPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    this.authorProfileImage,
    required this.category,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrls = const [],
    this.tags = const [],
  });

  /// JSONからBoardPostを作成
  factory BoardPost.fromJson(Map<String, dynamic> json) {
    return BoardPost(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? '',
      authorProfileImage: json['authorProfileImage']?.toString(),
      category: json['category']?.toString() ?? '',
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      tags:
          json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorName': authorName,
      'authorProfileImage': authorProfileImage,
      'category': category,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrls': imageUrls,
      'tags': tags,
    };
  }

  /// 相対時間表示 (例: 5分前、2時間前)
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}ヶ月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoardPost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 掲示板カテゴリ
enum BoardCategory {
  all('全て'),
  question('質問'),
  tip('情報共有'),
  review('レビュー'),
  daily('日常'),
  medical('健康・医療'),
  training('しつけ・訓練');

  final String label;
  const BoardCategory(this.label);
}

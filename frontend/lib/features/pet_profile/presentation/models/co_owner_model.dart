/// 共同養育者データモデル
class CoOwner {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String relationship; // 関係 (家族、友人、パートナーなど)
  final DateTime addedDate;

  CoOwner({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.relationship,
    required this.addedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'relationship': relationship,
      'addedDate': addedDate.toIso8601String(),
    };
  }

  factory CoOwner.fromMap(Map<String, dynamic> map) {
    return CoOwner(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      relationship: map['relationship'] as String,
      addedDate: DateTime.parse(map['addedDate'] as String),
    );
  }
}


enum FacilityType {
  grooming,
  hospital,
}

class Facility {
  final String id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String email;
  final FacilityType type;
  final double rating;
  final int reviewCount;
  final String imagePath;
  final bool isFavorite;
  final bool hasHistory;
  final DateTime? lastVisit;

  const Facility({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    required this.type,
    required this.rating,
    required this.reviewCount,
    required this.imagePath,
    this.isFavorite = false,
    this.hasHistory = false,
    this.lastVisit,
  });

  Facility copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
    FacilityType? type,
    double? rating,
    int? reviewCount,
    String? imagePath,
    bool? isFavorite,
    bool? hasHistory,
    DateTime? lastVisit,
  }) {
    return Facility(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      hasHistory: hasHistory ?? this.hasHistory,
      lastVisit: lastVisit ?? this.lastVisit,
    );
  }
}

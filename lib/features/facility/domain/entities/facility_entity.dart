import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

enum FacilityType {
  hospital, // 동물병원
  grooming, // 트리밍샵
  petShop, // 펫샵
  dogRun, // 도그런
  park, // 공원
  cafe, // 펫카페
  hotel, // 펫호텔
  training, // 훈련소
}

class Facility {
  final String id;
  final String name;
  final FacilityType type;
  final String address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? phone; // 추가
  final String? email; // 추가
  final String? website;
  final String? description;
  final String? imagePath; // 추가
  final bool isFavorite; // 추가
  final bool hasHistory; // 추가
  final DateTime? lastVisit; // 추가
  final double rating;
  final int reviewCount;
  final List<String> images;
  final Map<String, dynamic>? operatingHours;
  final List<String>? services;
  final double? distance; // km
  final bool isOpen;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.phone,
    this.email,
    this.website,
    this.description,
    this.imagePath,
    this.isFavorite = false,
    this.hasHistory = false,
    this.lastVisit,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.images = const [],
    this.operatingHours,
    this.services,
    this.distance,
    this.isOpen = true,
    this.createdAt,
    this.updatedAt,
  });

  Facility copyWith({
    String? id,
    String? name,
    FacilityType? type,
    String? address,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? phone,
    String? email,
    String? website,
    String? description,
    String? imagePath,
    bool? isFavorite,
    bool? hasHistory,
    DateTime? lastVisit,
    double? rating,
    int? reviewCount,
    List<String>? images,
    Map<String, dynamic>? operatingHours,
    List<String>? services,
    double? distance,
    bool? isOpen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Facility(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      hasHistory: hasHistory ?? this.hasHistory,
      lastVisit: lastVisit ?? this.lastVisit,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      images: images ?? this.images,
      operatingHours: operatingHours ?? this.operatingHours,
      services: services ?? this.services,
      distance: distance ?? this.distance,
      isOpen: isOpen ?? this.isOpen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 시설 타입에 따른 아이콘 반환
  IconData get icon {
    switch (type) {
      case FacilityType.hospital:
        return Icons.medical_services;
      case FacilityType.grooming:
        return Icons.content_cut;
      case FacilityType.petShop:
        return Icons.shopping_bag;
      case FacilityType.dogRun:
        return Icons.directions_run;
      case FacilityType.park:
        return Icons.park;
      case FacilityType.cafe:
        return Icons.local_cafe;
      case FacilityType.hotel:
        return Icons.hotel;
      case FacilityType.training:
        return Icons.school;
    }
  }

  /// 시설 타입에 따른 색상 반환
  Color get color {
    switch (type) {
      case FacilityType.hospital:
        return Colors.red;
      case FacilityType.grooming:
        return Colors.purple;
      case FacilityType.petShop:
        return Colors.orange;
      case FacilityType.dogRun:
        return Colors.green;
      case FacilityType.park:
        return Colors.lightGreen;
      case FacilityType.cafe:
        return Colors.brown;
      case FacilityType.hotel:
        return Colors.blue;
      case FacilityType.training:
        return Colors.indigo;
    }
  }

  /// 시설 타입에 따른 한글 이름 반환
  String get typeName {
    switch (type) {
      case FacilityType.hospital:
        return '動物病院';
      case FacilityType.grooming:
        return 'トリミング';
      case FacilityType.petShop:
        return 'ペットショップ';
      case FacilityType.dogRun:
        return 'ドッグラン';
      case FacilityType.park:
        return '公園';
      case FacilityType.cafe:
        return 'ペットカフェ';
      case FacilityType.hotel:
        return 'ペットホテル';
      case FacilityType.training:
        return 'ホームトレーニング';
    }
  }

  /// 거리 포맷팅
  String get formattedDistance {
    if (distance == null) return '距離情報がありません';
    if (distance! < 1) {
      return '${(distance! * 1000).round()}m';
    } else {
      return '${distance!.toStringAsFixed(1)}km';
    }
  }

  /// 평점 포맷팅
  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  /// 영업 상태 텍스트
  String get openStatusText {
    return isOpen ? 'OPEN' : 'CLOSED';
  }

  /// 영업 상태 색상
  Color get openStatusColor {
    return isOpen ? AppColors.pointGreen : AppColors.pointGray;
  }
}

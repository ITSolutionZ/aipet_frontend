import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

enum FacilityType {
  hospital, // 동물병원
  veterinary, // 수의사 (동물병원과 유사)
  grooming, // 트리밍샵
  petShop, // 펫샵
  petStore, // 펫 상점
  dogRun, // 도그런
  park, // 공원
  petPark, // 반려동물 공원
  cafe, // 펫카페
  hotel, // 펫호텔
  petFriendlyAccommodation, // 반려동물 친화 숙박
  training, // 훈련소
  other, // 기타
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
      case FacilityType.veterinary:
        return Icons.medical_services;
      case FacilityType.grooming:
        return Icons.content_cut;
      case FacilityType.petShop:
        return Icons.shopping_bag;
      case FacilityType.petStore:
        return Icons.store;
      case FacilityType.dogRun:
        return Icons.directions_run;
      case FacilityType.park:
        return Icons.park;
      case FacilityType.petPark:
        return Icons.pets;
      case FacilityType.cafe:
        return Icons.local_cafe;
      case FacilityType.hotel:
        return Icons.hotel;
      case FacilityType.petFriendlyAccommodation:
        return Icons.home;
      case FacilityType.training:
        return Icons.school;
      case FacilityType.other:
        return Icons.place;
    }
  }

  /// 시설 타입에 따른 색상 반환
  Color get color {
    switch (type) {
      case FacilityType.hospital:
        return Colors.red;
      case FacilityType.veterinary:
        return Colors.red;
      case FacilityType.grooming:
        return Colors.purple;
      case FacilityType.petShop:
        return Colors.orange;
      case FacilityType.petStore:
        return Colors.orange;
      case FacilityType.dogRun:
        return Colors.green;
      case FacilityType.park:
        return Colors.lightGreen;
      case FacilityType.petPark:
        return Colors.lightGreen;
      case FacilityType.cafe:
        return Colors.brown;
      case FacilityType.hotel:
        return Colors.blue;
      case FacilityType.petFriendlyAccommodation:
        return Colors.blue;
      case FacilityType.training:
        return Colors.indigo;
      case FacilityType.other:
        return Colors.grey;
    }
  }

  /// 시설 타입에 따른 한글 이름 반환
  String get typeName {
    switch (type) {
      case FacilityType.hospital:
        return '動物病院';
      case FacilityType.veterinary:
        return '獣医院';
      case FacilityType.grooming:
        return 'トリミング';
      case FacilityType.petShop:
        return 'ペットショップ';
      case FacilityType.petStore:
        return 'ペット用品店';
      case FacilityType.dogRun:
        return 'ドッグラン';
      case FacilityType.park:
        return '公園';
      case FacilityType.petPark:
        return 'ペット公園';
      case FacilityType.cafe:
        return 'ペットカフェ';
      case FacilityType.hotel:
        return 'ペットホテル';
      case FacilityType.petFriendlyAccommodation:
        return 'ペット可宿泊施設';
      case FacilityType.training:
        return 'ホームトレーニング';
      case FacilityType.other:
        return 'その他';
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

  /// 시설 타입별 뱃지 텍스트
  String get badgeText {
    switch (type) {
      case FacilityType.hospital:
      case FacilityType.veterinary:
        return '24時間';
      case FacilityType.grooming:
        return '予約可';
      case FacilityType.petShop:
      case FacilityType.petStore:
        return 'SALE';
      case FacilityType.dogRun:
      case FacilityType.park:
      case FacilityType.petPark:
        return '無料';
      case FacilityType.cafe:
        return 'ペットOK';
      case FacilityType.hotel:
      case FacilityType.petFriendlyAccommodation:
        return '宿泊可';
      case FacilityType.training:
        return '体験可';
      case FacilityType.other:
        return '';
    }
  }

  /// 시설 타입별 뱃지 색상
  Color get badgeColor {
    switch (type) {
      case FacilityType.hospital:
      case FacilityType.veterinary:
        return const Color(0xFFE53935); // Red
      case FacilityType.grooming:
        return const Color(0xFF8E24AA); // Purple
      case FacilityType.petShop:
      case FacilityType.petStore:
        return const Color(0xFFFF6D00); // Orange
      case FacilityType.dogRun:
      case FacilityType.park:
      case FacilityType.petPark:
        return const Color(0xFF43A047); // Green
      case FacilityType.cafe:
        return const Color(0xFF6D4C41); // Brown
      case FacilityType.hotel:
      case FacilityType.petFriendlyAccommodation:
        return const Color(0xFF1E88E5); // Blue
      case FacilityType.training:
        return const Color(0xFF3949AB); // Indigo
      case FacilityType.other:
        return const Color(0xFF757575); // Grey
    }
  }

  /// 시설 타입별 뱃지 아이콘
  IconData get badgeIcon {
    switch (type) {
      case FacilityType.hospital:
      case FacilityType.veterinary:
        return Icons.emergency;
      case FacilityType.grooming:
        return Icons.schedule;
      case FacilityType.petShop:
      case FacilityType.petStore:
        return Icons.local_offer;
      case FacilityType.dogRun:
      case FacilityType.park:
      case FacilityType.petPark:
        return Icons.nature_people;
      case FacilityType.cafe:
        return Icons.pets;
      case FacilityType.hotel:
      case FacilityType.petFriendlyAccommodation:
        return Icons.king_bed;
      case FacilityType.training:
        return Icons.sports;
      case FacilityType.other:
        return Icons.info;
    }
  }

  /// 시설 타입별 서브 뱃지 (추가 정보)
  String? get subBadgeText {
    switch (type) {
      case FacilityType.hospital:
      case FacilityType.veterinary:
        return '応急処置';
      case FacilityType.grooming:
        return 'カット';
      case FacilityType.petShop:
      case FacilityType.petStore:
        return '用品';
      case FacilityType.dogRun:
        return 'ドッグラン';
      case FacilityType.park:
      case FacilityType.petPark:
        return '公園';
      case FacilityType.cafe:
        return 'カフェ';
      case FacilityType.hotel:
      case FacilityType.petFriendlyAccommodation:
        return 'ホテル';
      case FacilityType.training:
        return 'しつけ';
      case FacilityType.other:
        return null;
    }
  }
}

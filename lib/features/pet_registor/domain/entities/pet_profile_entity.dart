import 'package:flutter/material.dart';

/// 펫 프로필 엔티티
class PetProfileEntity {
  final String id;
  final String name;
  final String type; // 'dog', 'cat', 'bird', 'hamster', 'rabbit', 'turtle'
  final String? breed;
  final DateTime birthDate;
  final String? imagePath;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? additionalInfo;

  const PetProfileEntity({
    required this.id,
    required this.name,
    required this.type,
    this.breed,
    required this.birthDate,
    this.imagePath,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.additionalInfo,
  });

  PetProfileEntity copyWith({
    String? id,
    String? name,
    String? type,
    String? breed,
    DateTime? birthDate,
    String? imagePath,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? additionalInfo,
  }) {
    return PetProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      imagePath: imagePath ?? this.imagePath,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  /// 펫 나이 계산
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// 펫 타입에 따른 아이콘
  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'bird':
        return Icons.flutter_dash;
      case 'hamster':
        return Icons.pets;
      case 'rabbit':
        return Icons.pets;
      case 'turtle':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  /// 펫 타입 한글명
  String get typeName {
    switch (type.toLowerCase()) {
      case 'dog':
        return '강아지';
      case 'cat':
        return '고양이';
      case 'bird':
        return '새';
      case 'hamster':
        return '햄스터';
      case 'rabbit':
        return '토끼';
      case 'turtle':
        return '거북이';
      default:
        return '펫';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetProfileEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PetProfileEntity(id: $id, name: $name, type: $type, breed: $breed)';
  }
}

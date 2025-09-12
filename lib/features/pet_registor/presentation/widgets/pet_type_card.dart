import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 펫 타입 선택 카드 위젯
///
/// const 생성자를 활용하여 성능을 최적화하고 재사용성을 높입니다.
class PetTypeCard extends StatelessWidget {
  final String imagePath;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final String? petType; // 추가: 펫 타입 정보
  final String? title; // 추가: 제목
  final String? subtitle; // 추가: 부제목

  const PetTypeCard({
    super.key,
    required this.imagePath,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.petType,
    this.title,
    this.subtitle,
  });

  // 펫 타입별 이름 가져오기
  String _getPetTypeName(String? type) {
    switch (type) {
      case 'dog':
        return '犬';
      case 'cat':
        return '猫';
      case 'rabbit':
        return 'うさぎ';
      case 'hamster':
        return 'ハムスター';
      case 'bird':
        return '鳥';
      case 'turtle':
        return '亀';
      default:
        return 'ペット';
    }
  }

  // 펫 타입별 설명 가져오기
  String _getPetTypeDescription(String? type) {
    switch (type) {
      case 'dog':
        return '忠実で愛情深いパートナー';
      case 'cat':
        return '独立心があり愛らしい家族';
      case 'rabbit':
        return '静かで愛らしい小動物';
      case 'hamster':
        return '小さくて可愛い仲間';
      case 'bird':
        return 'カラフルで賢い友達';
      case 'turtle':
        return 'のんびり屋の長寿な友達';
      default:
        return 'あなたの大切な家族';
    }
  }

  // 개와 고양이인지 확인
  bool _isSpecialPet() {
    return petType == 'dog' || petType == 'cat';
  }

  @override
  Widget build(BuildContext context) {
    final isSpecial = _isSpecialPet();
    final petName = title ?? _getPetTypeName(petType);
    final petDescription = subtitle ?? _getPetTypeDescription(petType);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: AppColors.pureWhite, // 배경색은 항상 흰색
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isSelected
                ? color
                : AppColors.pointGray.withValues(alpha: 0.3),
            width: isSelected ? 3.0 : 1, // 선택 시 더 굵은 보더
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.pointDark.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: isSpecial
            ? _buildSpecialCard(petName, petDescription)
            : _buildRegularCard(),
      ),
    );
  }

  // 개와 고양이용 특별한 카드 (이미지만 표시)
  Widget _buildSpecialCard(String petName, String petDescription) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Image.asset(
          imagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain, // 이미지가 카드 안에 완전히 들어가도록
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.pointGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(
                Icons.pets,
                size: 60,
                color: color,
              ),
            );
          },
        ),
      ),
    );
  }

  // 기본 카드 (다른 동물들 - 이미지만 표시)
  Widget _buildRegularCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Image.asset(
          imagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain, // 이미지가 카드 안에 완전히 들어가도록
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.pointGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(
                Icons.pets,
                size: 40,
                color: color,
              ),
            );
          },
        ),
      ),
    );
  }
}

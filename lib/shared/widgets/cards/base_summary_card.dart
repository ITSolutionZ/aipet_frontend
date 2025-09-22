import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/components/app_card.dart';

/// 🎯 Summary Card의 공통 베이스 위젯
///
/// 모든 summary card들이 공통으로 사용하는 패턴을 제공
/// - AppCard.summary를 직접 사용하여 deprecated API 회피
/// - 일관된 데이터 처리 로직
/// - DRY 원칙 적용
class BaseSummaryCard extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final String? value;
  final String? unit;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final String? semanticLabel;
  final String? tooltip;

  const BaseSummaryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.unit,
    this.icon,
    this.iconColor,
    this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.semanticLabel,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard.summary(
      title: title,
      subtitle: subtitle,
      value: value,
      unit: unit,
      icon: icon != null ? Icon(icon, color: iconColor) : null,
      iconColor: iconColor,
      onTap: onTap,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      semanticLabel: semanticLabel,
      tooltip: tooltip,
    );
  }
}

/// 🏠 Home Summary Card 전용 베이스 클래스
///
/// Home 화면의 summary card들이 공통으로 사용하는 패턴
abstract class HomeSummaryCardBase extends ConsumerWidget {
  const HomeSummaryCardBase({super.key});

  /// 카드 제목 반환
  String get cardTitle;

  /// 카드 아이콘 반환
  IconData get cardIcon;

  /// 카드 아이콘 색상 반환
  Color get cardIconColor;

  /// 라우트 경로 반환
  String get routePath;

  /// 데이터 로딩 상태 반환
  bool get isLoading => false;

  /// 카드 클릭 시 실행할 추가 로직
  void onCardTap(BuildContext context, WidgetRef ref) {
    if (routePath.isNotEmpty) {
      context.go(routePath);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseSummaryCard(
      title: cardTitle,
      subtitle: getSubtitle(context, ref),
      value: getValue(context, ref),
      unit: getUnit(context, ref),
      icon: cardIcon,
      iconColor: cardIconColor,
      onTap: () => onCardTap(context, ref),
      isLoading: isLoading,
      semanticLabel: getSemanticLabel(context, ref),
    );
  }

  /// 부제목 반환 (하위 클래스에서 구현)
  String? getSubtitle(BuildContext context, WidgetRef ref) => null;

  /// 메인 값 반환 (하위 클래스에서 구현)
  String? getValue(BuildContext context, WidgetRef ref) => null;

  /// 단위 반환 (하위 클래스에서 구현)
  String? getUnit(BuildContext context, WidgetRef ref) => null;

  /// 접근성 라벨 반환 (하위 클래스에서 구현)
  String? getSemanticLabel(BuildContext context, WidgetRef ref) => null;
}

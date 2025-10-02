import 'package:aipet_frontend/shared/widgets/layout/card.dart'; // GlassCard
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AccordionItem: 단일 아코디언 항목 정의
class AccordionItem {
  final String title;
  final Widget content;
  final Widget? leading; // optional icon/avatar
  final bool initiallyOpen;

  const AccordionItem({
    required this.title,
    required this.content,
    this.leading,
    this.initiallyOpen = false,
  });
}

/// 🎯 Glass Accordion State Provider
final glassAccordionProvider =
    StateNotifierProvider.family<GlassAccordionController, List<bool>, String>(
      (ref, accordionId) => GlassAccordionController(),
    );

class GlassAccordionController extends StateNotifier<List<bool>> {
  GlassAccordionController() : super([]);

  void initialize(List<AccordionItem> items) {
    state = items.map((e) => e.initiallyOpen).toList();
  }

  void toggle(int index, bool multiOpen) {
    final newState = List<bool>.from(state);

    if (multiOpen) {
      newState[index] = !newState[index];
    } else {
      for (int i = 0; i < newState.length; i++) {
        newState[i] = i == index ? !newState[i] : false;
      }
    }

    state = newState;
  }
}

/// 재사용 가능한 글라스 아코디언
/// - FAQ에 최적화: 키보드 접근/애니메이션/다중 오픈 지원
/// - GlassCard 스타일을 감싸서 일관된 룩 앤드 필 유지
class GlassAccordion extends ConsumerWidget {
  final List<AccordionItem> items;
  final bool multiOpen; // 여러 개 동시 오픈
  final EdgeInsetsGeometry itemMargin;
  final Duration animationDuration;
  final Curve animationCurve;
  final double borderRadius;
  final double dividerOpacity; // 아이템 사이 얇은 디바이더 느낌
  final String? accordionId; // 각 아코디언을 구분하는 ID

  const GlassAccordion({
    super.key,
    required this.items,
    this.multiOpen = true,
    this.itemMargin = const EdgeInsets.symmetric(vertical: 6),
    this.animationDuration = const Duration(milliseconds: 180),
    this.animationCurve = Curves.easeOutCubic,
    this.borderRadius = 14,
    this.dividerOpacity = 0.08,
    this.accordionId,
  });

  /// FAQ용 간단 생성자 (Q/A 문자열)
  factory GlassAccordion.faq({
    Key? key,
    required List<MapEntry<String, String>> qa,
    bool multiOpen = true,
    String? accordionId,
  }) {
    final items = qa
        .map(
          (e) => AccordionItem(
            title: e.key,
            content: Text(e.value, style: const TextStyle(height: 1.4)),
          ),
        )
        .toList();
    return GlassAccordion(key: key, items: items, multiOpen: multiOpen, accordionId: accordionId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveId = accordionId ?? 'default_accordion';
    final openStates = ref.watch(glassAccordionProvider(effectiveId));

    // Initialize the accordion state if it's empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (openStates.isEmpty && items.isNotEmpty) {
        ref.read(glassAccordionProvider(effectiveId).notifier).initialize(items);
      }
    });

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _AccordionItemCard(
            item: items[i],
            isOpen: i < openStates.length ? openStates[i] : false,
            onToggle: () =>
                ref.read(glassAccordionProvider(effectiveId).notifier).toggle(i, multiOpen),
            duration: animationDuration,
            curve: animationCurve,
            borderRadius: borderRadius,
          ),
          if (i != items.length - 1)
            Opacity(opacity: dividerOpacity, child: const Divider(height: 12)),
        ],
      ],
    );
  }
}

class _AccordionItemCard extends StatelessWidget {
  final AccordionItem item;
  final bool isOpen;
  final VoidCallback onToggle;
  final Duration duration;
  final Curve curve;
  final double borderRadius;

  const _AccordionItemCard({
    required this.item,
    required this.isOpen,
    required this.onToggle,
    required this.duration,
    required this.curve,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.white);
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9), height: 1.5);

    return GlassCard(
      margin: const EdgeInsets.symmetric(vertical: 6),
      borderRadius: borderRadius,
      padding: EdgeInsets.zero, // 헤더/본문 패딩을 각각 관리
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            highlightColor: Colors.white12,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  if (item.leading != null) ...[item.leading!, const SizedBox(width: 10)],
                  Expanded(child: Text(item.title, style: titleStyle)),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0.0,
                    duration: duration,
                    curve: curve,
                    child: const Icon(Icons.expand_more, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Body
          AnimatedCrossFade(
            duration: duration,
            crossFadeState: isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: DefaultTextStyle.merge(style: bodyStyle, child: item.content),
            ),
            secondChild: const SizedBox.shrink(),
            sizeCurve: curve,
          ),
        ],
      ),
    );
  }
}

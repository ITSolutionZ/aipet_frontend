import 'package:flutter/material.dart';

/// SelectionItem: 단일 선택 항목 정의
class SelectionItem<T> {
  final T value;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;

  const SelectionItem({
    required this.value,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.enabled = true,
  });
}

/// 선택 가능한 카드 리스트 (라디오 버튼 스타일)
class SelectionCardList<T> extends StatelessWidget {
  final List<SelectionItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T?>? onChanged;
  final EdgeInsetsGeometry itemMargin;
  final double borderRadius;
  final String? title;

  const SelectionCardList({
    super.key,
    required this.items,
    this.selectedValue,
    this.onChanged,
    this.itemMargin = const EdgeInsets.symmetric(vertical: 4),
    this.borderRadius = 12,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...items.map(
          (item) => _SelectionCard<T>(
            item: item,
            isSelected: selectedValue == item.value,
            onTap: item.enabled && onChanged != null
                ? () => onChanged!(item.value)
                : null,
            margin: itemMargin,
            borderRadius: borderRadius,
          ),
        ),
      ],
    );
  }
}

class _SelectionCard<T> extends StatelessWidget {
  final SelectionItem<T> item;
  final bool isSelected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final double borderRadius;

  const _SelectionCard({
    required this.item,
    required this.isSelected,
    this.onTap,
    required this.margin,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.primaryColor.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isSelected ? theme.primaryColor : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // 라디오 버튼
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: isSelected ? theme.primaryColor : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.circle, size: 8, color: Colors.white)
                      : null,
                ),

                const SizedBox(width: 12),

                // Leading widget (optional)
                if (item.leading != null) ...[
                  item.leading!,
                  const SizedBox(width: 12),
                ],

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: item.enabled
                                    ? Colors.black87
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                          if (isSelected && item.title == 'クレジットカード払い')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'おすすめ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: item.enabled
                                ? Colors.grey[600]
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing widget (optional)
                if (item.trailing != null) ...[
                  const SizedBox(width: 12),
                  item.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 정보 표시용 카드 리스트 (클릭 불가능)
class InfoCardList extends StatelessWidget {
  final List<InfoCardItem> items;
  final EdgeInsetsGeometry itemMargin;
  final double borderRadius;
  final String? title;

  const InfoCardList({
    super.key,
    required this.items,
    this.itemMargin = const EdgeInsets.symmetric(vertical: 4),
    this.borderRadius = 12,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...items.map(
          (item) => _InfoCard(
            item: item,
            margin: itemMargin,
            borderRadius: borderRadius,
          ),
        ),
      ],
    );
  }
}

class InfoCardItem {
  final String title;
  final String? subtitle;
  final String? trailingText;
  final Widget? leading;
  final VoidCallback? onTap;

  const InfoCardItem({
    required this.title,
    this.subtitle,
    this.trailingText,
    this.leading,
    this.onTap,
  });
}

class _InfoCard extends StatelessWidget {
  final InfoCardItem item;
  final EdgeInsetsGeometry margin;
  final double borderRadius;

  const _InfoCard({
    required this.item,
    required this.margin,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Row(
              children: [
                // Leading widget (optional)
                if (item.leading != null) ...[
                  item.leading!,
                  const SizedBox(width: 12),
                ],

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing text (optional)
                if (item.trailingText != null)
                  Text(
                    item.trailingText!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

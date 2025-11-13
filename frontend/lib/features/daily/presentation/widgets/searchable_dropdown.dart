import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 검색 가능한 드롭다운 위젯
class SearchableDropdown extends StatefulWidget {
  final String title;
  final String selectedValue;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final String hintText;

  const SearchableDropdown({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    required this.icon,
    required this.hintText,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredOptions = [];
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterOptions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = widget.options;
      } else {
        _filteredOptions = widget.options
            .where(
              (option) => option.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _searchController.clear();
        _filteredOptions = widget.options;
      }
    });
  }

  void _selectOption(String option) {
    widget.onChanged(option);
    setState(() {
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목
        Row(
          children: [
            Icon(widget.icon, color: AppColors.pointBrown, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              widget.title,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // 선택된 값 표시 또는 드롭다운 토글
        GestureDetector(
          onTap: _toggleExpanded,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: AppColors.pointGray.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.selectedValue.isEmpty
                        ? widget.hintText
                        : widget.selectedValue,
                    style: AppFonts.bodyMedium.copyWith(
                      color: widget.selectedValue.isEmpty
                          ? AppColors.pointGray
                          : AppColors.pointDark,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.pointGray,
                ),
              ],
            ),
          ),
        ),

        // 드롭다운 옵션들
        if (_isExpanded) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: AppColors.pointGray.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 검색 입력 필드
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '検索...',
                      hintStyle: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        borderSide: BorderSide(
                          color: AppColors.pointGray.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        borderSide: const BorderSide(
                          color: AppColors.pointBrown,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.pointGray,
                        size: 20,
                      ),
                    ),
                    onChanged: _filterOptions,
                  ),
                ),

                // 옵션 리스트
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredOptions.length,
                    itemBuilder: (context, index) {
                      final option = _filteredOptions[index];
                      final isSelected = option == widget.selectedValue;

                      return GestureDetector(
                        onTap: () => _selectOption(option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.pointBrown.withValues(alpha: 0.1)
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.pointGray.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: AppFonts.bodyMedium.copyWith(
                                    color: isSelected
                                        ? AppColors.pointBrown
                                        : AppColors.pointDark,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: AppColors.pointBrown,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';

/// 검색 가능한 드롭다운 위젯
class SearchableDropdown extends StatefulWidget {
  final String title;
  final String selectedValue;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final String hintText;
  final bool allowCustomEntry;

  const SearchableDropdown({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    required this.icon,
    this.hintText = '選択してください',
    this.allowCustomEntry = true,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  late TextEditingController _searchController;
  late List<String> _filteredOptions;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredOptions = List.from(widget.options);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterOptions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = List.from(widget.options);
      } else {
        _filteredOptions = widget.options
            .where((option) =>
                option.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showSearchDialog() {
    _searchController.clear();
    _filteredOptions = List.from(widget.options);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.6,
          expand: false,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    Icon(widget.icon, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppFonts.base(
                          fontSize: AppFonts.xl,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // 검색 필드
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '商品を検索...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setModalState(() {
                                _filterOptions('');
                              });
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      borderSide: BorderSide(
                        color: AppColors.borderGray.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundGray.withValues(alpha: 0.3),
                  ),
                  onChanged: (value) {
                    setModalState(() {
                      _filterOptions(value);
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // 사용자 정의 입력 옵션 (검색어가 있고 결과가 없을 때)
                if (widget.allowCustomEntry &&
                    _searchController.text.isNotEmpty &&
                    _filteredOptions.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '新しい商品を追加',
                              style: AppFonts.base(
                                fontSize: AppFonts.baseSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '"${_searchController.text}" を追加',
                          style: AppFonts.base(
                            fontSize: AppFonts.sm,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () {
                      widget.onChanged(_searchController.text);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('追加'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                const Divider(),
                const SizedBox(height: AppSpacing.md),

                // 결과 텍스트
                Text(
                  _filteredOptions.isEmpty
                      ? '検索結果がありません'
                      : '${_filteredOptions.length}件の商品',
                  style: AppFonts.base(
                    fontSize: AppFonts.sm,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // 선택 목록
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _filteredOptions.length,
                    itemBuilder: (context, index) {
                      final option = _filteredOptions[index];
                      final isSelected = widget.selectedValue == option;

                      return ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        title: Text(
                          option,
                          style: AppFonts.base(
                            fontSize: AppFonts.baseSize,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          widget.onChanged(option);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: AppFonts.base(
            fontSize: AppFonts.lg,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: _showSearchDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(
                color: AppColors.borderGray.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.selectedValue.isEmpty
                        ? widget.hintText
                        : widget.selectedValue,
                    style: AppFonts.base(
                      fontSize: AppFonts.baseSize,
                      color: widget.selectedValue.isEmpty
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      widget.selectedValue.isEmpty
                          ? Icons.keyboard_arrow_down
                          : Icons.check_circle,
                      color: widget.selectedValue.isEmpty
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
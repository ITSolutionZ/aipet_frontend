import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '페이지 인디케이터, 총 $totalPages페이지 중 ${currentPage + 1}페이지',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalPages,
          (index) => Semantics(
            label: '${index + 1}페이지${index == currentPage ? ', 현재 페이지' : ''}',
            button: true,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Icon(
                index == currentPage ? Icons.pets : Icons.pets_outlined,
                size: 20,
                color: index == currentPage
                    ? AppColors.pointBrown
                    : AppColors.pointGray.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

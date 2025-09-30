import 'package:aipet_frontend/features/home/presentation/widgets/banner_image.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/home_search_bar_widget.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';

/// 배너와 검색바 섹션
class BannerSection extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final ValueChanged<String>? onSearchChanged;

  const BannerSection({super.key, this.onSearchTap, this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // 배너 영역 밖으로 검색바가 나갈 수 있도록 허용
      children: [
        // 배너 이미지
        const BannerImage(),

        // 검색바 (배너 끝부분을 덮도록 배치)
        Positioned(
          bottom: -30, // 배너 하단에서 위로 10px 위치
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          child: HomeSearchBarWidget(onTap: onSearchTap, onChanged: onSearchChanged),
        ),
      ],
    );
  }
}

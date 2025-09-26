import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MeteoconsIcon extends ConsumerWidget {
  const MeteoconsIcon({super.key, required this.name, this.size = 32});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'assets/meteocons/design/fill/animation-ready/$name.svg',
        width: size,
        height: size,
        fit: BoxFit.contain,
        // 애니메이션 SVG를 위한 설정
        allowDrawingOutsideViewBox: true,
        // 에러 발생 시 폴백 아이콘 표시
        placeholderBuilder: (context) => _buildFallbackIcon(),
      ),
    );
  }

  /// 폴백 아이콘 위젯
  Widget _buildFallbackIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.toneOffWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.cloud, size: size * 0.6, color: AppColors.pointBlue),
    );
  }
}

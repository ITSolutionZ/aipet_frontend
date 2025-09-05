import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/shared.dart';

class MeteoconsIcon extends ConsumerStatefulWidget {
  const MeteoconsIcon({super.key, required this.name, this.size = 32});

  final String name;
  final double size;

  @override
  ConsumerState<MeteoconsIcon> createState() => _MeteoconsIconState();
}

class _MeteoconsIconState extends ConsumerState<MeteoconsIcon> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: SvgPicture.asset(
        'assets/meteocons/design/fill/animation-ready/${widget.name}.svg',
        width: widget.size,
        height: widget.size,
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
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: AppColors.toneOffWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.cloud,
        size: widget.size * 0.6,
        color: AppColors.pointBlue,
      ),
    );
  }
}

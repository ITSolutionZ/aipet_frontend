import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../data/data.dart';

/// 날씨 아이콘 위젯 (정적 SVG)
class WeatherIconWidget extends StatelessWidget {
  final int weatherId;
  final String iconCode;

  const WeatherIconWidget({
    super.key,
    required this.weatherId,
    required this.iconCode,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = OpenWeatherMapService.getDetailedMeteoconIcon(
      weatherId,
      iconCode,
    );

    return SizedBox(
      width: 90,
      height: 90,
      child: SvgPicture.asset(
        'assets/meteocons/design/fill/animation-ready/$fileName.svg',
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Container(
          color: Colors.grey[100],
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.pointBrown),
            ),
          ),
        ),
      ),
    );
  }
}

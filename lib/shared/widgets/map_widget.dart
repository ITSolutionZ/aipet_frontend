import 'package:flutter/material.dart';

/// 범용 지도 위젯
class MapWidget extends StatelessWidget {
  final double? height;
  final VoidCallback? onTap;

  const MapWidget({super.key, this.height = 200, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('지도 위젯', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';

class HealthSectionWidget extends StatelessWidget {
  const HealthSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Health 헤더
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Health',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Health 메뉴들
        ListTile(
          leading: const Icon(Icons.restaurant, color: Colors.white, size: 20),
          title: const Text(
            '食事&給水',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onTap: () {
            Navigator.of(context).pop(); // 드로어 닫기
            // 식사&급수 메인 페이지로 이동
            context.push(AppRouter.feedingMainRoute);
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.directions_walk,
            color: Colors.white,
            size: 20,
          ),
          title: const Text(
            '散歩',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onTap: () {
            Navigator.of(context).pop(); // 드로어 닫기
            context.go(AppRouter.homeRoute); // 홈 페이지로 이동
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.local_hospital,
            color: Colors.white,
            size: 20,
          ),
          title: const Text(
            '病院予約',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onTap: () {
            Navigator.of(context).pop(); // 드로어 닫기
            context.push(AppRouter.hospitalReservationRoute); // 병원 예약 페이지로 이동
          },
        ),
        ListTile(
          leading: const Icon(Icons.content_cut, color: Colors.white, size: 20),
          title: const Text(
            'トリミング予約',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onTap: () {
            Navigator.of(context).pop(); // 드로어 닫기
            context.push(AppRouter.groomingReservationRoute); // 트리밍 예약 페이지로 이동
          },
        ),
        const SizedBox(height: 16),
        // 구분선
        Container(
          height: 1,
          color: Colors.white.withAlpha(20),
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }
}

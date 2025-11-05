import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import 'drawer_local_datasource.dart';


class ServiceSectionWidget extends StatelessWidget {
  const ServiceSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 로컬 데이터에서 서비스 문의 데이터 가져오기
    final serviceInquiry = DrawerLocalDatasource.getServiceInquiry();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.settings, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                serviceInquiry['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // 서비스 설명
        if (serviceInquiry['description'] != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              serviceInquiry['description'],
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ),
        // Service 메뉴들
        ListTile(
          leading: const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
          title: const Text(
            'コミュニティー',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onTap: () {
            Navigator.of(context).pop(); // 드로어 닫기
            context.go(AppRouter.homeRoute); // 홈 페이지로 이동 (메인 페이지는 go 유지)
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.notifications,
            color: Colors.white,
            size: 20,
          ),
          title: const Text(
            'アラーム',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onTap: () async {
            // 먼저 네비게이션 실행
            await context.push(AppRouter.pushNotificationRoute);
            // 네비게이션 완료 후 drawer 자동으로 닫힘
          },
        ),
        ListTile(
          leading: const Icon(Icons.person, color: Colors.white, size: 20),
          title: const Text(
            'アカウント',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onTap: () async {
            // 먼저 네비게이션 실행
            await context.push(AppRouter.profileEditRoute);
            // 네비게이션 완료 후 drawer 자동으로 닫힘
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings, color: Colors.white, size: 20),
          title: const Text(
            '設定',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onTap: () async {
            // 먼저 네비게이션 실행
            await context.push(AppRouter.settingsRoute);
            // 네비게이션 완료 후 drawer 자동으로 닫힘
          },
        ),
        const SizedBox(height: 16),
        // 구분선
        Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.2),
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }
}

import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'home_menu_widget.dart';
// import 'qr_code_bottom_sheet.dart';

/// 홈 메뉴 아이템 정의
class HomeMenuItems {
  static List<MenuItem> getMenuItems(BuildContext context) {
    return [
      // 첫 번째 줄 (4개): 데일리케어 / 펫관리 / 알레르기 / 예약기록
      MenuItem(
        title: '毎日ケア',
        iconPath: 'assets/icons/home_menu/daily.png',
        onTap: () {
          context.go('/home/daily');
        },
      ),
      MenuItem(
        title: 'ペット管理',
        iconPath: 'assets/icons/home_menu/note.png',
        onTap: () {
          // 펫 관리 화면으로 이동 (펫 목록 또는 펫 등록)
          context.push(RouteConstants.petManagementRoute);
        },
      ),
      MenuItem(
        title: 'アレルギー',
        iconPath: 'assets/icons/home_menu/alregic.png',
        onTap: () {
          context.go(RouteConstants.allergyRoute);
        },
      ),
      MenuItem(
        title: '予約記録',
        iconPath: 'assets/icons/home_menu/booking.png',
        onTap: () {
          context.go('/home/daily/reservation-status');
        },
      ),
      // 두 번째 줄 (4개): 산책 / 게시판 / 카트 / QR코드
      // MenuItem(
      //   title: 'お散歩',
      //   iconPath: 'assets/icons/home_menu/place.png',
      //   onTap: () {
      //     context.go(RouteConstants.walkRoute);
      //   },
      // ),
      // MenuItem(
      //   title: '掲示板',
      //   iconPath: 'assets/icons/home_menu/community.png',
      //   onTap: () {
      //     context.push(RouteConstants.boardListRoute);
      //   },
      // ),
      MenuItem(
        title: 'カート',
        iconPath: 'assets/icons/home_menu/shopping.png',
        onTap: () {
          context.push(RouteConstants.petSearchRoute);
        },
      ),
      // MenuItem(
      //   title: 'QRコード',
      //   iconPath: 'assets/icons/home_menu/qr.png',
      //   onTap: () {
      //     QRCodeBottomSheet.show(context);
      //   },
      // ),
      // Pet Activities 메뉴 - 개발 중으로 인해 임시 숨김
      // MenuItem(
      //   title: 'トリック',
      //   iconPath: 'assets/icons/home_menu/place.png',
      //   onTap: () {
      //     context.push(RouteConstants.allTricksRoute);
      //   },
      // ),
    ];
  }
}

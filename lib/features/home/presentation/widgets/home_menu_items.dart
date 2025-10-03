import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/home_menu_widget.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/qr_code_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 홈 메뉴 아이템 정의
class HomeMenuItems {
  static List<MenuItem> getMenuItems(BuildContext context) {
    return [
      MenuItem(
        title: '予約記録',
        iconPath: 'assets/icons/home_menu/booking.png',
        onTap: () {
          // TODO: 예약 화면으로 이동
        },
      ),
      MenuItem(
        title: 'お散歩',
        iconPath: 'assets/icons/home_menu/place.png',
        onTap: () {
          context.go(RouteConstants.walkRoute);
        },
      ),
      MenuItem(
        title: '毎日ケア',
        iconPath: 'assets/icons/home_menu/daily.png',
        onTap: () {
          context.go('/home/daily');
        },
      ),
      MenuItem(
        title: 'ペット手帳',
        iconPath: 'assets/icons/home_menu/note.png',
        onTap: () {
          // TODO: 노트 화면으로 이동
        },
      ),
      MenuItem(
        title: '病院記録',
        iconPath: 'assets/icons/home_menu/pharmacy.png',
        onTap: () {
          // TODO: 병원 찾기 화면으로 이동
        },
      ),
      MenuItem(
        title: '掲示板',
        iconPath: 'assets/icons/home_menu/community.png',
        onTap: () {
          // TODO: 커뮤니티 화면으로 이동
        },
      ),
      MenuItem(
        title: '家族探し',
        iconPath: 'assets/icons/home_menu/adopt.png',
        onTap: () {
          // TODO: 입양 화면으로 이동
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
        title: 'QRコード',
        iconPath: 'assets/icons/home_menu/qr.png',
        onTap: () {
          QRCodeBottomSheet.show(context);
        },
      ),
      MenuItem(
        title: 'カート',
        iconPath: 'assets/icons/home_menu/shopping.png',
        onTap: () {
          // TODO: 쇼핑 화면으로 이동
        },
      ),
    ];
  }
}

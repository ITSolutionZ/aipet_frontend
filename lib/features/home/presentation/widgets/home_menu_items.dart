import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/home_menu_widget.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/qr_code_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 홈 메뉴 아이템 정의
class HomeMenuItems {
  static List<MenuItem> getMenuItems(BuildContext context) {
    return [
      // 첫 번째 줄 (5개): 데일리케어 / QR코드 / 알레르기 / 펫수첩 / 병원기록
      MenuItem(
        title: '毎日ケア',
        iconPath: 'assets/icons/home_menu/daily.png',
        onTap: () {
          context.go('/home/daily');
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
        title: 'アレルギー',
        iconPath: 'assets/icons/home_menu/alregic.png',
        onTap: () {
          context.go(RouteConstants.allergyRoute);
        },
      ),
      MenuItem(
        title: 'ペット手帳',
        iconPath: 'assets/icons/home_menu/note.png',
        onTap: () {
          // ペットプロフィール画面へ移動
          context.push('${RouteConstants.petProfileRoute}?petId=default');
        },
      ),
      MenuItem(
        title: '病院記録',
        iconPath: 'assets/icons/home_menu/pharmacy.png',
        onTap: () {
          context.push('/facility-type-selection');
        },
      ),
      // 두 번째 줄 (5개): 나머지 메뉴들
      MenuItem(
        title: '予約記録',
        iconPath: 'assets/icons/home_menu/booking.png',
        onTap: () {
          context.go('/home/daily/reservation-status');
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
        title: '掲示板',
        iconPath: 'assets/icons/home_menu/community.png',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('掲示板機能は準備中です'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
      MenuItem(
        title: 'カート',
        iconPath: 'assets/icons/home_menu/shopping.png',
        onTap: () {
          context.push(RouteConstants.petSearchRoute);
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

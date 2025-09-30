import 'package:aipet_frontend/features/home/presentation/widgets/home_menu_widget.dart';

/// 홈 메뉴 아이템 정의
class HomeMenuItems {
  static List<MenuItem> getMenuItems() {
    return [
      MenuItem(
        title: '予約',
        iconPath: 'assets/icons/home_menu/booking.png',
        onTap: () {
          // TODO: 예약 화면으로 이동
        },
      ),
      MenuItem(
        title: '場所',
        iconPath: 'assets/icons/home_menu/place.png',
        onTap: () {
          // TODO: 장소 검색 화면으로 이동
        },
      ),
      MenuItem(
        title: 'デイリー',
        iconPath: 'assets/icons/home_menu/daily.png',
        onTap: () {
          // TODO: 일상 기록 화면으로 이동
        },
      ),
      MenuItem(
        title: '育ちノート',
        iconPath: 'assets/icons/home_menu/note.png',
        onTap: () {
          // TODO: 노트 화면으로 이동
        },
      ),
      MenuItem(
        title: '処方',
        iconPath: 'assets/icons/home_menu/pharmacy.png',
        onTap: () {
          // TODO: 약국 찾기 화면으로 이동
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
          // TODO: 알레르기 화면으로 이동
        },
      ),
      MenuItem(
        title: 'QRコード',
        iconPath: 'assets/icons/home_menu/qr.png',
        onTap: () {
          // TODO: QR 코드 화면으로 이동
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

import 'package:aipet_frontend/features/daily/daily.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'hospital_qr_scanner_screen.dart';

class HospitalDetailScreen extends ConsumerStatefulWidget {
  final String hospitalId;

  const HospitalDetailScreen({super.key, required this.hospitalId});

  @override
  ConsumerState<HospitalDetailScreen> createState() =>
      _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends ConsumerState<HospitalDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _introKey = GlobalKey();
  final GlobalKey _noticeKey = GlobalKey();
  final GlobalKey _hoursKey = GlobalKey();
  final GlobalKey _medicalKey = GlobalKey();
  bool _isDescriptionExpanded = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 실제 hospitalId를 기반으로 데이터 가져오기
    final hospitalData = _getHospitalData(widget.hospitalId);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 병원 이미지가 포함된 SliverAppBar (스크롤 시 접힘, AppBar는 고정)
          SliverAppBar(
            expandedHeight: 200,
            pinned: true, // AppBar 상단 고정
            floating: false,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text(
              hospitalData['name'] as String,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            actions: [
              Consumer(
                builder: (context, ref, child) {
                  final hospitalsAsync = ref.watch(registeredHospitalsProvider);
                  final isFavorite = hospitalsAsync.maybeWhen(
                    data: (hospitals) =>
                        hospitals.any((h) => h.id == widget.hospitalId),
                    orElse: () => false,
                  );

                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => _toggleFavorite(hospitalData, isFavorite),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // 共有機能
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(top: 56), // AppBar 높이
                color: Colors.grey[200],
                child: Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.local_hospital,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          // 나머지 스크롤 가능한 콘텐츠
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 病院基本情報
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 병원 필터 칩들 (병원명 위에 표시)
                      _buildHospitalFilterChips(hospitalData),
                      const SizedBox(height: AppSpacing.sm),

                      // 病院名
                      Text(
                        hospitalData['name'] as String,
                        style: AppFonts.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // 住所
                      Text(
                        hospitalData['address'] as String,
                        style: AppFonts.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // 営業時間と現在の状態
                      _buildOperatingHoursStatus(hospitalData),
                      const SizedBox(height: AppSpacing.sm),

                      // アクションボタン
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.call, size: 16),
                              label: const Text('電話'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.directions, size: 16),
                              label: const Text('経路'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showQrCodeScreen(context, ref),
                              icon: const Icon(Icons.qr_code, size: 16),
                              label: const Text('受付'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // 예약 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final hospitalName = hospitalData['name'] as String;
                            context.push(
                              '/hospital-booking/${widget.hospitalId}?hospitalName=${Uri.encodeComponent(hospitalName)}',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'オンライン予約',
                                style: AppFonts.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // 예약 내역 확인 버튼 추가
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            context.push('/calendar/hospital-reservation');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.list_alt, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '予約履歴確認',
                                style: AppFonts.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 탭 메뉴 (고정)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          label: '病院紹介',
                          onPressed: () => _scrollToSection(_introKey),
                        ),
                      ),
                      Expanded(
                        child: _TabButton(
                          label: 'お知らせ',
                          onPressed: () => _scrollToSection(_noticeKey),
                        ),
                      ),
                      Expanded(
                        child: _TabButton(
                          label: '営業時間',
                          onPressed: () => _scrollToSection(_hoursKey),
                        ),
                      ),
                      Expanded(
                        child: _TabButton(
                          label: '診療情報',
                          onPressed: () => _scrollToSection(_medicalKey),
                        ),
                      ),
                    ],
                  ),
                  Container(height: 1, color: Colors.grey[200]),
                ],
              ),
            ),
          ),

          // 스크롤 가능한 콘텐츠
          SliverList(
            delegate: SliverChildListDelegate([
              // 病院紹介セクション
              Container(
                key: _introKey,
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('病院紹介'),
                    const SizedBox(height: AppSpacing.md),
                    _buildExpandableDescription(),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '病院便利施設',
                      style: AppFonts.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildHospitalFacilities(),
                  ],
                ),
              ),

              // お知らせセクション
              Container(
                key: _noticeKey,
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('お知らせ'),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '登録されたお知らせがありません。',
                      style: AppFonts.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // 営業時間セクション
              Container(
                key: _hoursKey,
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('営業時間'),
                    const SizedBox(height: AppSpacing.md),
                    _buildTimeSlot('月', '10:00-19:00', '火', '10:00-19:00'),
                    _buildTimeSlot('水', '10:00-19:00', '木', '10:00-19:00'),
                    _buildTimeSlot('金', '10:00-19:00', '土', '09:30-15:00'),
                    _buildTimeSlot('日', '休診', '祝日', '09:30-15:00'),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Text(
                          '昼休み: ',
                          style: AppFonts.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('12:00-14:00', style: AppFonts.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          '夜間診療: ',
                          style: AppFonts.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('情報未提供', style: AppFonts.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),

              // 診療情報セクション
              Container(
                key: _medicalKey,
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('診療情報'),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '診療科目',
                      style: AppFonts.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _buildMedicalChip('内科'),
                        _buildMedicalChip('外科'),
                        _buildMedicalChip('整形外科'),
                        _buildMedicalChip('神経外科'),
                        _buildMedicalChip('歯科'),
                        _buildMedicalChip('眼科'),
                        _buildMedicalChip('診療科'),
                        _buildMedicalChip('入院施設'),
                        _buildMedicalChip('放射線科'),
                        _buildMedicalChip('予防医学科'),
                        _buildMedicalChip('麻酔科'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'その他情報',
                      style: AppFonts.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '登録された情報がありません。',
                      style: AppFonts.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '企業情報提供',
                      style: AppFonts.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        '病院情報の正確な更新のために情報提供を受けます',
                        style: AppFonts.bodySmall.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 下部ボタン
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.go('/calendar/hospital-reservation');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: Text(
                          '予約履歴',
                          style: AppFonts.bodyMedium.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final hospitalName = hospitalData['name'] as String;
                          context.push(
                            '/hospital-booking/${widget.hospitalId}?hospitalName=${Uri.encodeComponent(hospitalName)}',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'オンライン予約',
                          style: AppFonts.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppFonts.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  // 병원에 적용되는 필터 칩들을 표시하는 위젯
  Widget _buildHospitalFilterChips(Map<String, dynamic> hospitalData) {
    final filterTags = hospitalData['filterTags'] as List<String>? ?? [];

    if (filterTags.isEmpty) {
      return const SizedBox.shrink(); // 필터 태그가 없으면 아무것도 표시하지 않음
    }

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: filterTags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _getFilterChipColor(tag),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getFilterChipBorderColor(tag)),
          ),
          child: Text(
            tag,
            style: AppFonts.bodySmall.copyWith(
              color: _getFilterChipTextColor(tag),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  // 필터 칩의 배경색을 결정하는 함수
  Color _getFilterChipColor(String tag) {
    switch (tag) {
      case 'QR受付':
        return Colors.purple[50]!;
      case 'モバイル予約':
        return Colors.blue[50]!;
      case '24時間運営':
        return Colors.orange[50]!;
      case '内科診療':
        return Colors.green[50]!;
      case '救急室':
        return Colors.red[50]!;
      case '外科手術':
        return Colors.indigo[50]!;
      case '健康診断':
        return Colors.teal[50]!;
      case '予防接種':
        return Colors.cyan[50]!;
      case '美容':
        return Colors.pink[50]!;
      case 'ペンション施設':
        return Colors.lime[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  // 필터 칩의 테두리색을 결정하는 함수
  Color _getFilterChipBorderColor(String tag) {
    switch (tag) {
      case 'QR受付':
        return Colors.purple[200]!;
      case 'モバイル予約':
        return Colors.blue[200]!;
      case '24時間運営':
        return Colors.orange[200]!;
      case '内科診療':
        return Colors.green[200]!;
      case '救急室':
        return Colors.red[200]!;
      case '外科手術':
        return Colors.indigo[200]!;
      case '健康診断':
        return Colors.teal[200]!;
      case '予防接種':
        return Colors.cyan[200]!;
      case '美容':
        return Colors.pink[200]!;
      case 'ペンション施設':
        return Colors.lime[200]!;
      default:
        return Colors.grey[200]!;
    }
  }

  // 필터 칩의 텍스트 색상을 결정하는 함수
  Color _getFilterChipTextColor(String tag) {
    switch (tag) {
      case 'QR受付':
        return Colors.purple[700]!;
      case 'モバイル予約':
        return Colors.blue[700]!;
      case '24時間運営':
        return Colors.orange[700]!;
      case '内科診療':
        return Colors.green[700]!;
      case '救急室':
        return Colors.red[700]!;
      case '外科手術':
        return Colors.indigo[700]!;
      case '健康診断':
        return Colors.teal[700]!;
      case '予防接種':
        return Colors.cyan[700]!;
      case '美容':
        return Colors.pink[700]!;
      case 'ペンション施設':
        return Colors.lime[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  // 운영시간과 현재 상태를 표시하는 위젯
  Widget _buildOperatingHoursStatus(Map<String, dynamic> hospitalData) {
    final isOpen = _isHospitalOpen(hospitalData);
    final operatingHours = _getTodayOperatingHours(hospitalData);
    final statusText = _getOperatingStatusText(hospitalData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: isOpen ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              operatingHours,
              style: AppFonts.bodyMedium.copyWith(
                color: isOpen ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (statusText.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isOpen ? Colors.green[50] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: AppFonts.bodySmall.copyWith(
                color: isOpen ? Colors.green[700] : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // 병원이 현재 운영 중인지 확인하는 함수
  bool _isHospitalOpen(Map<String, dynamic> hospitalData) {
    final now = DateTime.now();
    final currentDay = now.weekday; // 1: 월요일, 7: 일요일
    final currentTime = now.hour * 60 + now.minute; // 분 단위로 변환

    // 24시간 운영 병원인지 확인
    final filterTags = hospitalData['filterTags'] as List<String>? ?? [];
    if (filterTags.contains('24시')) {
      return true;
    }

    // 요일별 운영시간 확인
    final operatingHours = _getOperatingHoursForDay(currentDay);
    if (operatingHours == null) return false;

    final openTime = _timeToMinutes(operatingHours['open']!);
    final closeTime = _timeToMinutes(operatingHours['close']!);

    // 점심시간 확인 (12:00-14:00)
    const lunchStart = 12 * 60; // 12:00
    const lunchEnd = 14 * 60; // 14:00

    if (currentTime >= lunchStart && currentTime < lunchEnd) {
      return false; // 점심시간은 휴무
    }

    return currentTime >= openTime && currentTime < closeTime;
  }

  // 오늘의 운영시간을 가져오는 함수
  String _getTodayOperatingHours(Map<String, dynamic> hospitalData) {
    final now = DateTime.now();
    final currentDay = now.weekday;

    // 24시간 운영 병원인지 확인
    final filterTags = hospitalData['filterTags'] as List<String>? ?? [];
    if (filterTags.contains('24時') || filterTags.contains('24시')) {
      return '24時間営業';
    }

    final operatingHours = _getOperatingHoursForDay(currentDay);
    if (operatingHours == null) {
      return '休業';
    }

    return '${operatingHours['open']} - ${operatingHours['close']}';
  }

  // 운영 상태 텍스트를 가져오는 함수
  String _getOperatingStatusText(Map<String, dynamic> hospitalData) {
    final isOpen = _isHospitalOpen(hospitalData);
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    // 24時間営業病院かどうか確認
    final filterTags = hospitalData['filterTags'] as List<String>? ?? [];
    if (filterTags.contains('24時') || filterTags.contains('24시')) {
      return '24時間営業中';
    }

    if (!isOpen) {
      // 昼休み時間かどうか確認
      const lunchStart = 12 * 60;
      const lunchEnd = 14 * 60;
      if (currentTime >= lunchStart && currentTime < lunchEnd) {
        return '昼休み（14:00に再開）';
      }
      return '現在休業';
    }

    // 운영 중일 때 남은 시간 계산
    final currentDay = now.weekday;
    final operatingHours = _getOperatingHoursForDay(currentDay);
    if (operatingHours != null) {
      final closeTime = _timeToMinutes(operatingHours['close']!);
      final remainingMinutes = closeTime - currentTime;

      if (remainingMinutes <= 60) {
        // 1時間以内に閉店
        final hours = remainingMinutes ~/ 60;
        final minutes = remainingMinutes % 60;
        if (hours > 0) {
          return '営業中（$hours時間$minutes分後に閉店）';
        } else {
          return '営業中（$minutes分後に閉店）';
        }
      }
    }

    return '営業中';
  }

  // 曜日別営業時間を取得する関数
  Map<String, String>? _getOperatingHoursForDay(int weekday) {
    switch (weekday) {
      case 1: // 月曜日
      case 2: // 火曜日
      case 3: // 水曜日
      case 4: // 木曜日
      case 5: // 金曜日
        return {'open': '10:00', 'close': '19:00'};
      case 6: // 土曜日
        return {'open': '09:30', 'close': '15:00'};
      case 7: // 日曜日
        return null; // 休業
      default:
        return null;
    }
  }

  // 시간 문자열을 분 단위로 변환하는 함수
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  // 특정 섹션으로 스크롤하는 함수
  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 즐겨찾기 토글
  void _toggleFavorite(
    Map<String, dynamic> hospitalData,
    bool isFavorite,
  ) async {
    if (isFavorite) {
      // 즐겨찾기 제거
      await ref
          .read(registeredHospitalsProvider.notifier)
          .removeHospital(widget.hospitalId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('よく行く病院から削除されました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // 즐겨찾기 추가
      final hospital = RegisteredHospital(
        id: widget.hospitalId,
        name: hospitalData['name'] as String,
        address: hospitalData['address'] as String,
        phoneNumber: hospitalData['phone'] as String,
        registeredAt: DateTime.now(),
      );
      await ref
          .read(registeredHospitalsProvider.notifier)
          .addHospital(hospital);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('よく行く病院に登録されました'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// QR 스캐너 화면 표시
  void _showQrCodeScreen(BuildContext context, WidgetRef ref) async {
    // QR 스캐너 화면으로 이동
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (context) => const HospitalQrScannerScreen()),
    );

    // 스캔 결과 처리
    if (result != null && mounted) {
      // 스캔 성공 시 처리
      _handleScannedData(context, result);
    }
  }

  /// 스캔된 데이터 처리
  void _handleScannedData(BuildContext context, Map<String, dynamic> data) {
    // 병원 정보 추출
    final hospitalName = data['hospitalName'] ?? data['name'] ?? '病院';

    // 접수 완료 다이얼로그 표시
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('受付完了'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$hospitalNameで受付が完了しました'),
            const SizedBox(height: AppSpacing.md),
            if (data.containsKey('queueNumber'))
              Text(
                '待ち番号: ${data['queueNumber']}',
                style: AppFonts.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('確認')),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String day1, String time1, String day2, String time2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Text(
                    day1,
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getDayColor(day1),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  time1,
                  style: AppFonts.bodyMedium.copyWith(
                    color: _getTimeColor(time1),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Text(
                    day2,
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getDayColor(day2),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  time2,
                  style: AppFonts.bodyMedium.copyWith(
                    color: _getTimeColor(time2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 曜日別色を決定する関数
  Color _getDayColor(String day) {
    switch (day) {
      case '토':
      case '土':
        return Colors.blue; // 土曜日は青色
      case '일':
      case '日':
      case '공휴일':
      case '祝日':
        return Colors.red; // 日曜日と祝日は赤色
      default:
        return Colors.black; // 平日は黒色
    }
  }

  // 時間テキスト色を決定する関数
  Color _getTimeColor(String time) {
    if (time == '휴진' || time == '休診') {
      return Colors.red; // 休診日は赤色
    }
    return Colors.black; // 一般時間は黒色
  }

  // 확장 가능한 병원 설명 위젯
  Widget _buildExpandableDescription() {
    final hospitalData = _getHospitalData(widget.hospitalId);
    final fullDescription = hospitalData['description'] as String;

    // 첫 번째 줄바꿈까지 또는 100자까지를 짧은 설명으로 사용
    final sentences = fullDescription.split('\n\n');
    final shortDescription = sentences.length > 1
        ? '${sentences[0]}\n\n${sentences[1]}...'
        : fullDescription.length > 100
        ? '${fullDescription.substring(0, 100)}...'
        : fullDescription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isDescriptionExpanded ? fullDescription : shortDescription,
          style: AppFonts.bodyMedium.copyWith(height: 1.5),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () {
            setState(() {
              _isDescriptionExpanded = !_isDescriptionExpanded;
            });
          },
          child: Row(
            children: [
              Text(
                _isDescriptionExpanded ? '折りたたむ' : '詳細を見る',
                style: AppFonts.bodySmall.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                _isDescriptionExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 16,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFacilityChip(String facility) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        facility,
        style: AppFonts.bodySmall.copyWith(color: Colors.blue[700]),
      ),
    );
  }

  Widget _buildMedicalChip(String medical) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Text(
        medical,
        style: AppFonts.bodySmall.copyWith(color: Colors.green[700]),
      ),
    );
  }

  Map<String, dynamic> _getHospitalData(String hospitalId) {
    // TODO: Google Places API getPlaceDetails를 사용하여 실제 데이터 가져오기
    // 현재는 기본 데이터만 반환
    final defaultData = {
      '0': {
        'name': 'アニマルクリニック銀座',
        'address': '東京都中央区銀座3-10-5',
        'phone': '03-1234-5678',
        'rating': '4.5',
        'reviewCount': '248',
        'tags': ['QR受付', 'モバイル予約', '24時間運営'],
        'filterTags': ['QR受付', 'モバイル予約', '24時間運営'],
        'description':
            'こんにちは。東京都中央区銀座3-10-5に位置するアニマルクリニック銀座です。\n\n当院はペットの健康と幸せを最優先に考え、最新の医療機器と専門的な獣医学知識を基に最高の診療サービスを提供しています。\n\n24時間救急診療システムを運営しており、内科、外科、歯科、眼科など多様な診療科目を通じてペットの総合的な健康管理を支援します。\n\nまた、便利な駐車施設と現代的な施設を備えており、飼い主様とペットの両方が快適に診療を受けられる環境を提供します。',
        'facilities': ['駐車施設', 'ペットホテル', 'グルーミング'],
      },
      '1': {
        'name': '渋谷ペット総合病院',
        'address': '東京都渋谷区渋谷2-16-8',
        'phone': '03-2345-6789',
        'rating': '4.2',
        'reviewCount': '156',
        'tags': ['救急室', '外科手術', '健康診断'],
        'filterTags': ['救急室', '外科手術', '健康診断'],
        'description':
            '東京都渋谷区で20年以上の歴史を誇る渋谷ペット総合病院です。\n\n最先端の医療機器と熟練した医療陣を通じて高品質の医療サービスを提供しており、特に外科手術分野で優れた実力を認められています。\n\n救急室運営により24時間救急患者の診療が可能で、定期健康診断プログラムを通じて予防中心の医療サービスを提供します。',
        'facilities': ['駐車施設', '救急室'],
      },
      '2': {
        'name': 'ペットケアクリニック新宿',
        'address': '東京都新宿区新宿3-25-12',
        'phone': '03-3456-7890',
        'rating': '4.7',
        'reviewCount': '324',
        'tags': ['モバイル予約', '健康診断', '予防接種', '美容'],
        'filterTags': ['モバイル予約', '健康診断', '予防接種'],
        'description':
            '東京都新宿区に位置するペットケアクリニック新宿は、ペットの専門的な医療サービスとケアを提供します。\n\n最新の医療機器を備えた診療室と快適な入院室、そして専門美容室まで備えた総合ペットケアセンターです。\n\n特に予防医学に重点を置き、定期健康診断とカスタマイズされた予防接種スケジュールを提供し、ペットの生涯健康管理パートナーとなります。',
        'facilities': ['駐車施設', '美容室', '入院室'],
      },
      '3': {
        'name': '品川動物メディカルセンター',
        'address': '東京都品川区北品川5-9-15',
        'phone': '03-4567-8901',
        'rating': '4.8',
        'reviewCount': '487',
        'tags': ['24時間運営', 'QR受付', '救急室', '外科手術'],
        'filterTags': ['24時間運営', 'QR受付', '救急室'],
        'description':
            '東京都品川区に位置する品川動物メディカルセンターは最高水準の動物医療サービスを提供する大型総合動物病院です。\n\n大学病院水準の医療陣と最先端の医療機器を保有しており、24時間救急診療システムでいつでも緊急状況に対応できます。\n\nQRコードによる簡単受付システムとリアルタイム待機状況確認サービスで便利な病院利用が可能です。\n\n内科、外科、歯科、眼科、皮膚科など専門科目別の診療が可能で、精密検査のためのCT、MRIなどの機器も完備されています。',
        'facilities': ['駐車施設', '救急室', 'CT室', 'MRI室', '手術室'],
      },
      '4': {
        'name': 'みなとみらい動物病院',
        'address': '神奈川県横浜市西区みなとみらい4-6-2',
        'phone': '045-789-0123',
        'rating': '4.3',
        'reviewCount': '198',
        'tags': ['モバイル予約', '予防接種', '健康診断', '美容'],
        'filterTags': ['モバイル予約', '健康診断', '予防接種'],
        'description':
            '神奈川県横浜市で地域住民の皆様とともに歩んできたみなとみらい動物病院です。\n\n家族のような温かい診療サービスでペットと飼い主様の両方が安心を感じられる病院を作っています。\n\nモバイルアプリによる簡単予約システムと予防接種通知サービスでペットの健康管理を体系的にサポートします。',
        'facilities': ['駐車施設', '美容室'],
      },
      '5': {
        'name': '24時間どうぶつ救急センター千葉',
        'address': '千葉県千葉市中央区新町1-17',
        'phone': '043-234-5678',
        'rating': '4.6',
        'reviewCount': '276',
        'tags': ['24時間運営', '救急室', '外科手術', 'QR受付'],
        'filterTags': ['24時間運営', 'QR受付', '救急室'],
        'description':
            '千葉県千葉市に位置する24時間どうぶつ救急センター千葉は24時間いつでも救急診療が可能な動物病院です。\n\n夜間と週末、祝日にも専門獣医師が常駐し、緊急状況に即座に対応できるシステムを備えています。\n\n特に外科手術分野の専門性を認められ、他院から紹介される高難度手術も成功的に施行しています。\n\nQRコード受付システムで迅速で便利な診療受付が可能です。',
        'facilities': ['駐車施設', '救急室', '手術室', '入院室'],
      },
      '6': {
        'name': '梅田ペットクリニック',
        'address': '大阪府大阪市北区梅田2-5-25',
        'phone': '06-345-6789',
        'rating': '4.4',
        'reviewCount': '167',
        'tags': ['モバイル予約', '健康診断', '予防接種'],
        'filterTags': ['モバイル予約', '健康診断'],
        'description':
            '大阪府大阪市北区で10年以上地域住民の皆様とともに歩んできた梅田ペットクリニックです。\n\nペット家族の健康と幸せのために真心を込めた診療と細やかなケアを提供しています。\n\n定期健康診断プログラムとカスタマイズされた予防接種計画で疾病予防に重点を置いており、飼い主様教育を通じて正しいペットケア方法をご案内します。',
        'facilities': ['駐車施設'],
      },
      '7': {
        'name': '京都動物愛護病院',
        'address': '京都府京都市下京区烏丸通四条下ル',
        'phone': '075-456-7890',
        'rating': '4.5',
        'reviewCount': '203',
        'tags': ['健康診断', '予防接種', '外科手術', '内科診療'],
        'filterTags': ['健康診断', '外科手術', '内科診療'],
        'description':
            '京都府京都市に位置する京都動物愛護病院はペットへの深い愛情と専門性を基に最上の医療サービスを提供します。\n\n内科と外科診療を専門とし、各種健康診断と予防接種サービスでペットの健康的な生活を支援します。\n\n定期的な医療陣研修と最新医療技法の導入で常に発展する病院となるよう努力しています。',
        'facilities': ['駐車施設', '手術室'],
      },
    };

    // hospitalId에 해당하는 데이터가 있으면 반환, 없으면 기본 데이터 반환
    return defaultData[hospitalId] ?? defaultData['0']!;
  }

  // 병원 편의시설을 동적으로 표시하는 위젯
  Widget _buildHospitalFacilities() {
    final hospitalData = _getHospitalData(widget.hospitalId);
    final facilities = hospitalData['facilities'] as List<String>? ?? [];

    if (facilities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: facilities.map((facility) {
        return _buildFacilityChip(facility);
      }).toList(),
    );
  }
}

// 탭 버튼 위젯
class _TabButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _TabButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.blue.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppFonts.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

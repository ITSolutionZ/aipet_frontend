import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../domain/facility.dart';
import '../widgets/facility_availability_section.dart';
import '../widgets/facility_contact_section.dart';
import '../widgets/facility_detail_header.dart';
import '../widgets/facility_location_section.dart';
import '../widgets/facility_services_section.dart';

class FacilityDetailScreen extends ConsumerStatefulWidget {
  final String facilityId;

  const FacilityDetailScreen({super.key, required this.facilityId});

  @override
  ConsumerState<FacilityDetailScreen> createState() =>
      _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends ConsumerState<FacilityDetailScreen> {
  // 더미 데이터 - 실제로는 facilityId로 조회
  late Facility _facility;

  @override
  void initState() {
    super.initState();
    // 목업 데이터 서비스에서 시설 데이터 가져오기
    _facility = MockDataService.getMockFacilityDetailById(widget.facilityId);
  }

  void _addToContacts() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '연락처 추가',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('次の連絡先を追加しますか？'),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _facility.name,
                      style: AppFonts.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('電話: ${_facility.phone}'),
                    Text('メール: ${_facility.email}'),
                    Text('住所: ${_facility.address}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${_facility.name}が連絡先に追加されました。'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: CustomScrollView(
        slivers: [
          // 헤더 (배경 이미지와 시설 정보)
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.pointBrown,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              '連絡先を表示',
              style: AppFonts.fredoka(
                fontSize: AppFonts.lg,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: FacilityDetailHeader(facility: _facility),
            ),
          ),

          // 상세 정보
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 연락처 섹션
                  FacilityContactSection(facility: _facility),
                  const SizedBox(height: AppSpacing.xl),

                  // 위치 섹션
                  FacilityLocationSection(facility: _facility),
                  const SizedBox(height: AppSpacing.xl),

                  // 영업시간 섹션
                  FacilityAvailabilitySection(facility: _facility),
                  const SizedBox(height: AppSpacing.xl),

                  // 서비스 섹션
                  FacilityServicesSection(facility: _facility),
                  const SizedBox(height: AppSpacing.xl),

                  // 예약 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(
                          '${AppRouter.bookingRoute}/${_facility.id}',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                      ),
                      child: Text(
                        '日付を予約',
                        style: AppFonts.fredoka(
                          fontSize: AppFonts.lg,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 연락처 추가 버튼
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _addToContacts(),
                      icon: const Icon(Icons.add, color: Colors.grey, size: 16),
                      label: Text(
                        '+ 連絡先に追加',
                        style: AppFonts.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

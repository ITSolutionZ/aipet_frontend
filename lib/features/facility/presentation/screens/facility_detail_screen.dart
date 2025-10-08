import 'package:aipet_frontend/features/facility/presentation/screens/facility_booking_screen.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FacilityDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> facility;

  const FacilityDetailScreen({super.key, required this.facility});

  @override
  ConsumerState<FacilityDetailScreen> createState() =>
      _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends ConsumerState<FacilityDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: CustomScrollView(
        slivers: [
          // 앱바와 이미지 헤더
          _buildSliverAppBar(),
          // 콘텐츠
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFacilityInfo(),
                _buildFacilityDescription(),
                _buildServicesSection(),
                _buildReviewsSection(),
                _buildLocationSection(),
                const SizedBox(height: AppSpacing.xl * 2), // 하단 예약 버튼 공간
              ],
            ),
          ),
        ],
      ),
      // 하단 고정 예약 버튼
      bottomNavigationBar: _buildBookingButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: _getCategoryColor(widget.facility['type']),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.facility['name'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 배경 이미지 (임시로 그라데이션 사용)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _getCategoryColor(
                      widget.facility['type'],
                    ).withValues(alpha: 0.8),
                    _getCategoryColor(
                      widget.facility['type'],
                    ).withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            // 시설 아이콘
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                ),
                child: Icon(
                  _getCategoryIcon(widget.facility['type']),
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시설명과 평점
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.facility['name'],
                  style: AppFonts.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    widget.facility['type'],
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[600]),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${widget.facility['rating']}',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // 주소
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  widget.facility['address'],
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // 리뷰 수
          Text(
            '${widget.facility['reviewCount']}件のレビュー',
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityDescription() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '施設紹介',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _getFacilityDescription(widget.facility['type']),
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    final services = widget.facility['services'] as List<String>;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '提供サービス',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: services.map((service) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    widget.facility['type'],
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getCategoryColor(
                      widget.facility['type'],
                    ).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  service,
                  style: AppFonts.bodySmall.copyWith(
                    color: _getCategoryColor(widget.facility['type']),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'レビュー',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // 리뷰 더보기 페이지로 이동
                },
                child: Text(
                  'すべて見る',
                  style: AppFonts.bodySmall.copyWith(
                    color: _getCategoryColor(widget.facility['type']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 임시 리뷰 데이터
          _buildReviewItem(
            userName: '田中ペットママ',
            rating: 5,
            comment: 'とても綺麗で親切です！ワンちゃんがとても喜んでいました。',
            date: '2024-10-01',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildReviewItem(
            userName: '佐藤ドッグパパ',
            rating: 4,
            comment: '料金も手頃でサービスも満足でした。',
            date: '2024-09-28',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required String userName,
    required int rating,
    required String comment,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                userName,
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber[600],
                  );
                }),
              ),
              const Spacer(),
              Text(
                date,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            comment,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '所在地',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '地図を表示',
                    style: AppFonts.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.facility['address'],
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _navigateToBooking(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getCategoryColor(widget.facility['type']),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
            ),
            child: Text(
              '予約する',
              style: AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToBooking() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FacilityBookingScreen(
          facilityName: widget.facility['name'],
          facilityType: widget.facility['type'],
          facilityId: widget.facility['name'], // 임시로 이름을 ID로 사용
        ),
      ),
    );
  }

  Color _getCategoryColor(String type) {
    switch (type) {
      case '미용실':
        return Colors.pink;
      case '카페':
        return Colors.brown;
      case '호텔':
        return Colors.blue;
      case '놀이터':
        return Colors.green;
      case '교육센터':
        return Colors.purple;
      default:
        return AppColors.pointGreen;
    }
  }

  IconData _getCategoryIcon(String type) {
    switch (type) {
      case '미용실':
        return Icons.content_cut;
      case '카페':
        return Icons.local_cafe;
      case '호텔':
        return Icons.hotel;
      case '놀이터':
        return Icons.park;
      case '교육센터':
        return Icons.school;
      default:
        return Icons.place;
    }
  }

  String _getFacilityDescription(String type) {
    switch (type) {
      case '미용실':
        return '専門的な美容サービスとペットケアを提供する施設です。経験豊富な美容師が安全で清潔な環境で最高のサービスを提供します。';
      case '카페':
        return 'ペットと一緒に楽しめるペットフレンドリーなカフェです。様々なメニューと快適な空間でペットと貴重な時間を過ごしてください。';
      case '호텔':
        return 'ペットのための専門ホテルサービスです。24時間ケアと安全な施設でペットが快適に滞在できます。';
      case '놀이터':
        return 'ペットが自由に遊び回れる広い遊び場です。様々な遊具と安全な環境を提供します。';
      case '교육센터':
        return 'ペットの教育と訓練のための専門センターです。専門訓練士が体系的な教育プログラムを提供します。';
      default:
        return 'ペットのための様々なサービスを提供する専門施設です。';
    }
  }
}

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/services/google_places_service.dart';
import '../../domain/entities/review_entity.dart';

class FacilityDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> facility;

  const FacilityDetailScreen({super.key, required this.facility});

  @override
  ConsumerState<FacilityDetailScreen> createState() =>
      _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends ConsumerState<FacilityDetailScreen> {
  FacilityReviews? _reviews;
  bool _isLoadingReviews = false;
  String? _reviewsError;

  // Google Places API에서 가져온 전화번호
  String? _phoneNumber;
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _loadFacilityDetails();
    _loadReviews();
  }

  /// Google Places API에서 시설 상세 정보(전화번호 포함) 로드
  Future<void> _loadFacilityDetails() async {
    final placeId = widget.facility['id'] as String?;
    if (placeId == null || placeId.isEmpty) return;

    setState(() {
      _isLoadingDetails = true;
    });

    final googlePlacesService = ref.read(googlePlacesServiceProvider);
    final result = await googlePlacesService.getFacilityDetails(placeId);

    setState(() {
      _isLoadingDetails = false;
      if (result.isSuccess) {
        final facility = result.dataOrNull;
        if (facility != null && facility.phone != null) {
          _phoneNumber = facility.phone;
        }
      }
    });
  }

  Future<void> _loadReviews() async {
    final placeId = widget.facility['id'] as String?;
    if (placeId == null || placeId.isEmpty) return;

    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });

    final googlePlacesService = ref.read(googlePlacesServiceProvider);
    final result = await googlePlacesService.getFacilityReviews(placeId);

    setState(() {
      _isLoadingReviews = false;
      if (result.isSuccess) {
        _reviews = result.dataOrNull;
      } else {
        _reviewsError = result.error?.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFacilityInfo(),
                _buildFacilityDescription(),
                if (widget.facility['services'] != null) _buildServicesSection(),
                _buildReviewsSection(),
                _buildLocationSection(),
                const SizedBox(height: AppSpacing.xl * 2),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionButtons(),
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
    final rating = widget.facility['rating'] ?? 0.0;
    final reviewCount = _reviews?.totalReviews ?? widget.facility['reviewCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      (rating as num).toStringAsFixed(1),
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
          Row(
            children: [
              Text(
                '$reviewCount件のレビュー',
                style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              if (widget.facility['distance'] != null) ...[
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.straighten, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 2),
                Text(
                  _formatDistance(widget.facility['distance']),
                  style: AppFonts.bodySmall.copyWith(
                    color: _getCategoryColor(widget.facility['type']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDistance(dynamic distance) {
    if (distance == null) return '';
    final d = (distance as num).toDouble();
    if (d < 1) {
      return '${(d * 1000).round()}m';
    }
    return '${d.toStringAsFixed(1)}km';
  }

  Widget _buildFacilityDescription() {
    final description = widget.facility['description'] as String? ??
        _getFacilityDescription(widget.facility['type']);

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
            description,
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
    final services = widget.facility['services'] as List<String>?;
    if (services == null || services.isEmpty) return const SizedBox.shrink();

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
                'Googleレビュー',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_reviews != null && _reviews!.reviews.isNotEmpty)
                TextButton(
                  onPressed: () => _showAllReviews(),
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

          // 로딩 상태
          if (_isLoadingReviews)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(),
              ),
            )
          // 에러 상태
          else if (_reviewsError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.pointGray),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'レビューを読み込めませんでした',
                      style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: _loadReviews,
                      child: const Text('再試行'),
                    ),
                  ],
                ),
              ),
            )
          // 리뷰 데이터
          else if (_reviews != null) ...[
            // 평점 요약
            _buildRatingSummary(),
            const SizedBox(height: AppSpacing.lg),
            // 리뷰 목록
            if (_reviews!.reviews.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'まだレビューがありません',
                    style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ..._reviews!.reviews.take(3).map((review) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildReviewCard(review),
                );
              }),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    final rating = _reviews?.averageRating ?? (widget.facility['rating'] as num?)?.toDouble() ?? 0.0;
    final totalReviews = _reviews?.totalReviews ?? widget.facility['reviewCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // 평균 평점
          Column(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: AppFonts.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  final starRating = rating - index;
                  IconData icon;
                  if (starRating >= 1) {
                    icon = Icons.star;
                  } else if (starRating >= 0.5) {
                    icon = Icons.star_half;
                  } else {
                    icon = Icons.star_border;
                  }
                  return Icon(icon, size: 16, color: Colors.amber[600]);
                }),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$totalReviews件',
                style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          // 평점 분포
          if (_reviews != null && _reviews!.reviews.isNotEmpty)
            Expanded(
              child: Column(
                children: [5, 4, 3, 2, 1].map((star) {
                  final count = _reviews!.ratingDistribution[star] ?? 0;
                  final percentage = _reviews!.reviews.isNotEmpty
                      ? count / _reviews!.reviews.length
                      : 0.0;
                  return _buildRatingBar(star, percentage, count);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
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
              // 프로필 이미지
              CircleAvatar(
                radius: 20,
                backgroundColor: _getCategoryColor(widget.facility['type']).withValues(alpha: 0.2),
                backgroundImage: review.authorPhotoUrl != null
                    ? NetworkImage(review.authorPhotoUrl!)
                    : null,
                child: review.authorPhotoUrl == null
                    ? Text(
                        review.authorName.isNotEmpty ? review.authorName[0] : '?',
                        style: TextStyle(
                          color: _getCategoryColor(widget.facility['type']),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: Colors.amber[600],
                          );
                        }),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          review.relativeTimeDescription,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.text.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              review.text,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  void _showAllReviews() {
    if (_reviews == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // 핸들
                Container(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 제목
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Text(
                        'すべてのレビュー',
                        style: AppFonts.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_reviews!.totalReviews}件',
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // 리뷰 목록
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _reviews!.reviews.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return _buildReviewCard(_reviews!.reviews[index]);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLocationSection() {
    final lat = widget.facility['latitude'] as double?;
    final lng = widget.facility['longitude'] as double?;
    final hasCoordinates = lat != null && lng != null;

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
          GestureDetector(
            onTap: () => _openMap(),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasCoordinates
                  ? Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(lat, lng),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('facility'),
                              position: LatLng(lat, lng),
                              infoWindow: InfoWindow(
                                title: widget.facility['name'] ?? '',
                              ),
                            ),
                          },
                          zoomControlsEnabled: false,
                          scrollGesturesEnabled: false,
                          rotateGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          zoomGesturesEnabled: false,
                          myLocationEnabled: false,
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                        ),
                        // 탭 오버레이
                        Positioned.fill(
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                        // 지도 열기 힌트
                        Positioned(
                          bottom: AppSpacing.sm,
                          right: AppSpacing.sm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(AppSpacing.xs),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.open_in_new,
                                  size: 14,
                                  color: AppColors.pointBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '地図アプリで開く',
                                  style: AppFonts.bodySmall.copyWith(
                                    color: AppColors.pointBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
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
          ),
          const SizedBox(height: AppSpacing.sm),
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
                  widget.facility['address'] ?? '',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
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
        child: Row(
          children: [
            // 전화 버튼
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoadingDetails
                    ? null
                    : (_phoneNumber != null || widget.facility['phone'] != null)
                        ? () => _makePhoneCall()
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.pointGray.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                ),
                icon: _isLoadingDetails
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.phone, size: 20),
                label: Text(
                  '電話',
                  style:
                      AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // 지도 버튼
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openMap(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                ),
                icon: const Icon(Icons.map, size: 20),
                label: Text(
                  '地図を見る',
                  style:
                      AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall() async {
    // Google Places API에서 가져온 전화번호 우선 사용
    final phone = _phoneNumber ?? widget.facility['phone'] as String?;

    if (_isLoadingDetails) {
      SnackBarService.showInfo(context, '電話番号を読み込み中...');
      return;
    }

    if (phone == null || phone.isEmpty) {
      if (mounted) {
        SnackBarService.showError(context, '電話番号がありません');
      }
      return;
    }

    final phoneUri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          SnackBarService.showError(context, '電話アプリを開けません');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, '電話をかけることができません: $e');
      }
    }
  }

  Future<void> _openMap() async {
    final lat = widget.facility['latitude'] as double?;
    final lng = widget.facility['longitude'] as double?;
    final name = widget.facility['name'] as String? ?? '';
    final address = widget.facility['address'] as String? ?? '';

    Uri mapUri;
    if (lat != null && lng != null) {
      // 좌표가 있으면 좌표로 열기
      mapUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    } else if (address.isNotEmpty) {
      // 주소로 검색
      mapUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
      );
    } else if (name.isNotEmpty) {
      // 이름으로 검색
      mapUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(name)}',
      );
    } else {
      if (mounted) {
        SnackBarService.showError(context, '位置情報がありません');
      }
      return;
    }

    try {
      if (await canLaunchUrl(mapUri)) {
        await launchUrl(mapUri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          SnackBarService.showError(context, 'マップアプリを開けません');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, 'マップを開けません: $e');
      }
    }
  }

  Color _getCategoryColor(String? type) {
    switch (type) {
      case '動物病院':
      case '獣医院':
        return AppColors.pointRed;
      case 'トリミング':
        return AppColors.pointPink;
      case 'ペットショップ':
      case 'ペット用品店':
        return AppColors.pointOrange;
      case 'ドッグラン':
      case '公園':
      case 'ペット公園':
        return AppColors.pointGreen;
      case 'ペットカフェ':
      case 'カフェ':
        return AppColors.pointBrown;
      case 'ペットホテル':
      case 'ホテル':
        return AppColors.pointBlue;
      case 'ホームトレーニング':
        return AppColors.pointBlue;
      // 레거시 지원
      case '미용실':
        return AppColors.pointPink;
      case '카페':
        return AppColors.pointBrown;
      case '호텔':
        return AppColors.pointBlue;
      case '놀이터':
        return AppColors.pointGreen;
      case '교육센터':
        return AppColors.pointPink;
      default:
        return AppColors.pointBrown;
    }
  }

  IconData _getCategoryIcon(String? type) {
    switch (type) {
      case '動物病院':
      case '獣医院':
        return Icons.local_hospital;
      case 'トリミング':
        return Icons.content_cut;
      case 'ペットショップ':
      case 'ペット用品店':
        return Icons.store;
      case 'ドッグラン':
      case '公園':
      case 'ペット公園':
        return Icons.park;
      case 'ペットカフェ':
      case 'カフェ':
        return Icons.local_cafe;
      case 'ペットホテル':
      case 'ホテル':
        return Icons.hotel;
      case 'ホームトレーニング':
        return Icons.school;
      // 레거시 지원
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

  String _getFacilityDescription(String? type) {
    switch (type) {
      case '動物病院':
      case '獣医院':
        return '専門的な獣医療サービスを提供する施設です。経験豊富な獣医師が安全で清潔な環境で最高のケアを提供します。';
      case 'トリミング':
        return '専門的な美容サービスとペットケアを提供する施設です。経験豊富な美容師が安全で清潔な環境で最高のサービスを提供します。';
      case 'ペットショップ':
      case 'ペット用品店':
        return 'ペット用品を販売する専門店です。フード、おやつ、おもちゃなど様々な商品を取り揃えています。';
      case 'ドッグラン':
      case '公園':
      case 'ペット公園':
        return 'ペットが自由に遊び回れる広い遊び場です。安全なフェンスで囲まれた環境を提供します。';
      case 'ペットカフェ':
      case 'カフェ':
        return 'ペットと一緒に楽しめるペットフレンドリーなカフェです。様々なメニューと快適な空間でペットと貴重な時間を過ごしてください。';
      case 'ペットホテル':
      case 'ホテル':
        return 'ペットのための専門ホテルサービスです。24時間ケアと安全な施設でペットが快適に滞在できます。';
      case 'ホームトレーニング':
        return 'ペットの教育と訓練のための専門センターです。専門訓練士が体系的な教育プログラムを提供します。';
      default:
        return 'ペットのための様々なサービスを提供する専門施設です。';
    }
  }
}

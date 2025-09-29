import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/presentation/controllers/facility_detail_controller.dart';
import 'package:aipet_frontend/features/facility/presentation/widgets/facility_availability_section.dart';
import 'package:aipet_frontend/features/facility/presentation/widgets/facility_contact_section.dart';
import 'package:aipet_frontend/features/facility/presentation/widgets/facility_detail_header.dart';
import 'package:aipet_frontend/features/facility/presentation/widgets/facility_location_section.dart';
import 'package:aipet_frontend/features/facility/presentation/widgets/facility_services_section.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';

import 'package:aipet_frontend/shared/ui/components/cards/info_card.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/facility/facility_mock_service.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:aipet_frontend/shared/ui/components/states/empty_state.dart';
import 'package:aipet_frontend/shared/ui/components/states/loading_state.dart';
import 'package:aipet_frontend/shared/widgets/feedback/loading_widget.dart';
import 'package:aipet_frontend/shared/widgets/soft_gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FacilityDetailScreen extends ConsumerStatefulWidget {
  final String facilityId;

  const FacilityDetailScreen({super.key, required this.facilityId});

  @override
  ConsumerState<FacilityDetailScreen> createState() =>
      _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends ConsumerState<FacilityDetailScreen> {
  late FacilityDetailController _controller;
  Facility? _facility;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = FacilityDetailController(ref, context);
    _loadFacilityData();
  }

  Future<void> _loadFacilityData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final facility = await _controller.loadFacilityById(widget.facilityId);
      if (mounted) {
        setState(() {
          _facility = facility;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        appBar: SoftGradientBackAppBar(title: '連絡先を表示'),
        body: LoadingState(),
      );
    }

    if (_facility == null) {
      return Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        appBar: const SoftGradientBackAppBar(title: '連絡先を表示'),
        body: _buildErrorState(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: CustomScrollView(slivers: [_buildSliverAppBar(), _buildContent()]),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.pointBrown,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.pureWhite,
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        '連絡先を表示',
        style: AppFonts.fredoka(
          fontSize: AppFonts.lg,
          color: AppColors.pureWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            _facility!.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: AppColors.pureWhite,
          ),
          onPressed: () => _controller.handleFavoriteToggle(_facility!.id),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: FacilityDetailHeader(facility: _facility!),
      ),
    );
  }

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildLocationSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildAvailabilitySection(),
            const SizedBox(height: AppSpacing.xl),
            _buildServicesSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildActionButtons(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      elevation: 1,
      color: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: FacilityContactSection(facility: _facility!),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 1,
      color: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: FacilityLocationSection(facility: _facility!),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Card(
      elevation: 1,
      color: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: FacilityAvailabilitySection(facility: _facility!),
      ),
    );
  }

  Widget _buildServicesSection() {
    return Card(
      elevation: 1,
      color: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: FacilityServicesSection(facility: _facility!),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // 예약 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _controller.handleBooking(_facility!),
            icon: const Icon(Icons.calendar_today, color: AppColors.pureWhite),
            label: Text(
              '日付を予約',
              style: AppFonts.fredoka(
                fontSize: AppFonts.lg,
                color: AppColors.pureWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBlue,
              foregroundColor: AppColors.pureWhite,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // 연락처 추가 버튼
        Center(
          child: TextButton.icon(
            onPressed: () => _controller.handleAddToContacts(_facility!),
            icon: const Icon(Icons.add, color: AppColors.pointBrown, size: 16),
            label: Text(
              '連絡先に追加',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointBrown.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return EmptyState(
      icon: const Icon(Icons.error_outline),
      title: '施設情報を読み込めませんでした',
      subtitle: 'しばらくしてから再度試してください',
      action: ElevatedButton(
        onPressed: _loadFacilityData,
        child: const Text('再度試す'),
      ),
    );
  }
}

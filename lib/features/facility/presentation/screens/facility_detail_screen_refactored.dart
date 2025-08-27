import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../../domain/facility.dart';
import '../controllers/facility_detail_controller.dart';
import '../widgets/facility_availability_section.dart';
import '../widgets/facility_contact_section.dart';
import '../widgets/facility_detail_header.dart';
import '../widgets/facility_location_section.dart';
import '../widgets/facility_services_section.dart';

class FacilityDetailScreenRefactored extends ConsumerStatefulWidget {
  final String facilityId;

  const FacilityDetailScreenRefactored({super.key, required this.facilityId});

  @override
  ConsumerState<FacilityDetailScreenRefactored> createState() =>
      _FacilityDetailScreenRefactoredState();
}

class _FacilityDetailScreenRefactoredState extends ConsumerState<FacilityDetailScreenRefactored> {
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
      return Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        appBar: AppBar(
          backgroundColor: AppColors.pointBrown,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'View Contact',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.pointBrown),
          ),
        ),
      );
    }

    if (_facility == null) {
      return Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        appBar: AppBar(
          backgroundColor: AppColors.pointBrown,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'View Contact',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: _buildErrorState(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.pointBrown,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'View Contact',
        style: AppFonts.fredoka(
          fontSize: AppFonts.lg,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            _facility!.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
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
      color: Colors.white,
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
      color: Colors.white,
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
      color: Colors.white,
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
      color: Colors.white,
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
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            label: Text(
              'Book a date',
              style: AppFonts.fredoka(
                fontSize: AppFonts.lg,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBlue,
              foregroundColor: Colors.white,
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
            icon: const Icon(Icons.add, color: AppColors.pointDark, size: 16),
            label: Text(
              'Add to contacts',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.pointDark.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '시설 정보를 불러올 수 없습니다',
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '잠시 후 다시 시도해주세요',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadFacilityData,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
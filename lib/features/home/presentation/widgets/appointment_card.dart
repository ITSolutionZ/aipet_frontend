import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../controllers/appointment_controller.dart';

class AppointmentCard extends ConsumerStatefulWidget {
  const AppointmentCard({super.key});

  @override
  ConsumerState<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends ConsumerState<AppointmentCard> {
  late AppointmentController _controller;
  AppointmentData? _appointmentData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AppointmentController(ref);
    _loadAppointmentData();
  }

  Future<void> _loadAppointmentData() async {
    final result = await _controller.loadNextAppointment();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _appointmentData = result.data as AppointmentData?;
        }
      });
    }
  }

  void _handleAppointmentTap() {
    _controller.handleAppointmentTap().then((result) {
      if (result.isSuccess && mounted) {
        context.push('/reservation');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (_appointmentData == null) {
      return _buildNoAppointmentCard();
    }

    return GestureDetector(
      onTap: _handleAppointmentTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.pointBrown.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        child: Row(
          children: [
            // 펫 아바타
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  _appointmentData!.petImagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 25,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _appointmentData!.petName,
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.lg,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _appointmentData!.appointmentTitle,
                    style: AppFonts.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    _appointmentData!.appointmentInfo,
                    style: AppFonts.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // 위치 아이콘과 상세 버튼
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.pointBrown.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Text(
                    '詳細',
                    style: AppFonts.bodySmall.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '予約情報を読み込み中...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            child: const Icon(Icons.event_busy, color: Colors.grey, size: 25),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '予定された予約がありません',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '新しい予約を作成してください',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

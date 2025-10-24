import 'package:aipet_frontend/features/facility/presentation/screens/booking/constants/booking_constants.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';

/// サービス選択セクション
class ServiceSelectionSection extends StatelessWidget {
  final String? selectedService;
  final String facilityType;
  final ValueChanged<String?> onServiceChanged;

  const ServiceSelectionSection({
    super.key,
    required this.selectedService,
    required this.facilityType,
    required this.onServiceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final services = BookingConstants.getServicesForFacilityType(facilityType);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'サービス選択',
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: selectedService,
            decoration: InputDecoration(
              hintText: BookingConstants.hintSelectService,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                borderSide: const BorderSide(color: AppColors.pointGreen),
              ),
            ),
            items: services.map((service) {
              return DropdownMenuItem(
                value: service,
                child: Text(service),
              );
            }).toList(),
            onChanged: onServiceChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return BookingConstants.errorEmptyService;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

import 'package:aipet_frontend/features/pet_registor/data/providers/microchip_service_provider.dart';
import 'package:aipet_frontend/shared/widgets/banners/microchip_registration_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MicrochipModalHandlerWidget extends ConsumerWidget {
  final String? petType;
  final bool showModal;
  final VoidCallback onDismiss;

  const MicrochipModalHandlerWidget({
    super.key,
    required this.petType,
    required this.showModal,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!showModal) return const SizedBox.shrink();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      MicrochipRegistrationBanner.showModal(
        context,
        petType: petType,
        onRegisterTap: () async {
          try {
            final microchipService = ref.read(microchipServiceProvider);
            await microchipService.openRegistrationSite();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('URLが開けません')));
            }
          }
        },
        onDismiss: onDismiss,
      );
    });

    return const SizedBox.shrink();
  }
}

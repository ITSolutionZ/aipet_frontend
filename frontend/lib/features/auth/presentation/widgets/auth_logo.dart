import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({
    super.key,
    this.width = 120,
    this.height = 120,
    this.imagePath = 'assets/icons/logos/aipet_logo.png',
    this.backgroundColor = Colors.transparent,
  });

  final double width;
  final double height;
  final String imagePath;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imagePath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            LoggerService.debug('AuthLogo: Failed to load image: $imagePath');
            LoggerService.debug('AuthLogo: Error: $error');
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.pets, size: 80, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }
}

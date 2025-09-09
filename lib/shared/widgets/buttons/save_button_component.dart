import 'package:flutter/material.dart';
import '../../shared.dart';

class SaveButtonComponent extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SaveButtonComponent({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassButton.large(
      label: text,
      onPressed: onPressed,
      expand: true,
      leading: const Icon(Icons.check, size: 20),
      textStyle: AppFonts.fredoka(
        fontSize: AppFonts.lg,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

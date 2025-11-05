import 'package:flutter/material.dart';

/// ペットカードスワイプ背景ウィジェット
class PetSwipeBackground extends StatelessWidget {
  final bool isDelete;
  final bool isHiddenTab;

  const PetSwipeBackground({
    super.key,
    required this.isDelete,
    required this.isHiddenTab,
  });

  @override
  Widget build(BuildContext context) {
    // 非表示タブでは右スワイプが「復元」
    final isRestore = !isDelete && isHiddenTab;
    final icon = isDelete
        ? Icons.delete
        : (isRestore ? Icons.visibility : Icons.visibility_off);
    final label = isDelete ? '削除' : (isRestore ? '復元' : '非表示');
    final color = isDelete
        ? Colors.red
        : (isRestore ? Colors.green : Colors.orange);

    return Container(
      alignment: isDelete ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isDelete ? Alignment.centerLeft : Alignment.centerRight,
          end: isDelete ? Alignment.centerRight : Alignment.centerLeft,
          colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.6)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

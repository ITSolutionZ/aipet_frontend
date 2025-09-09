import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../controllers/walk_controller.dart';

class StartWalkDialog extends StatefulWidget {
  final WalkController controller;

  const StartWalkDialog({super.key, required this.controller});

  @override
  State<StartWalkDialog> createState() => _StartWalkDialogState();
}

class _StartWalkDialogState extends State<StartWalkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedPetId = 'pet1';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '새 산책 시작',
        style: AppFonts.fredoka(
          fontSize: AppFonts.lg,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '散歩のタイトル',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'タイトルを入力してください。';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _selectedPetId,
              decoration: const InputDecoration(
                labelText: 'ペット',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pet1', child: Text('Maxi')),
                DropdownMenuItem(value: 'pet2', child: Text('Luna')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPetId = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('キャンセル')),
        ElevatedButton(onPressed: _startWalk, child: const Text('はじめ')),
      ],
    );
  }

  void _startWalk() async {
    if (_formKey.currentState!.validate()) {
      final result = await widget.controller.startNewWalk(
        title: _titleController.text,
        petId: _selectedPetId,
        petName: _selectedPetId == 'pet1' ? 'Maxi' : 'Luna',
        petImage: 'assets/images/dogs/shiba.png',
      );

      if (result.isSuccess && mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.pointGreen,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.pointPink,
          ),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';

class ImageSelectionDialog extends StatelessWidget {
  final List<String> availableImages;
  final Function(String) onImageSelected;

  const ImageSelectionDialog({
    super.key,
    required this.availableImages,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('写真選択'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: availableImages
            .map(
              (imagePath) => ListTile(
                leading: CircleAvatar(backgroundImage: AssetImage(imagePath)),
                title: Text(imagePath.split('/').last.split('.').first),
                onTap: () {
                  onImageSelected(imagePath);
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}

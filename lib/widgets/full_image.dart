import 'package:flutter/material.dart';
import 'package:internusa_group/utils/constans.dart';

class FullImage extends StatelessWidget {
  final String? imageFile;

  const FullImage(this.imageFile, {super.key});

  @override
  Widget build(BuildContext context) {
    if (imageFile == null || imageFile!.isEmpty) {
      return Container(
        width: 200,
        height: 200,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
      );
    }

    final imageUrl = "$imageFile";

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 200,
          height: 200,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 200,
          height: 200,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
        );
      },
    );
  }
}

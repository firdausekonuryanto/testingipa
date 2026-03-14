import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/utils/constans.dart';

class NetworkImageWidget extends StatelessWidget {
  final String? imageFile;

  const NetworkImageWidget({super.key, this.imageFile});

  @override
  Widget build(BuildContext context) {
    if (imageFile == null || imageFile!.isEmpty) {
      return Container(
        width: 80.w,
        height: 80.h,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    final imageUrl = "${AppConfig.baseImageUrl}report/$imageFile";

    return Image.network(
      imageUrl,
      width: 80.w,
      height: 80.h,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 80.w,
          height: 80.h,
          color: Colors.grey[200],
          child: Center(
            child: SizedBox(
              width: 20.w,
              height: 20.h,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 80.w,
          height: 80.h,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }
}

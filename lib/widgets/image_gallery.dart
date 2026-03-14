import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/network_image_widget.dart';
import '../widgets/image_dialog.dart';
import '../../utils/theme.dart';

class ImageGallery extends StatelessWidget {
  final List<dynamic> images;

  const ImageGallery({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gambar Terlampir (${images.length})',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppDimens.fontBody,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textLight
                : Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 80.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => showImageDialog(context, images, index),
                child: Container(
                  margin: EdgeInsets.only(right: 8.w),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

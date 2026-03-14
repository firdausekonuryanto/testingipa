import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/models/attendance.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/screens/home/widgets/history_card.dart';

class HistorySection extends StatelessWidget {
  final VoidCallback onSeeAll;
  final List<Attendance> items;
  final bool showAll;

  const HistorySection({
    required this.onSeeAll,
    required this.items,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (items.isEmpty) {
      return const Text("Belum ada riwayat kehadiran");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Kehadiran',
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: AppDimens.fontBody),
            ),
            InkWell(
              onTap: onSeeAll,
              child: Text(
                showAll ? 'Tampilkan Sedikit' : 'Tampilkan Semua',
                style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: AppDimens.fontCaption),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final att = items[index];
            return HistoryCard(item: att);
          },
        )
      ],
    );
  }
}

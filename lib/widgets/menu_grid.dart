import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/theme.dart';

class MenuItemData {
  final IconData icon;
  final String label;
  final Color? bgIcon;
  final Color? colorIcon;
  final VoidCallback onTap;

  MenuItemData({
    required this.icon,
    required this.label,
    this.bgIcon,
    this.colorIcon,
    required this.onTap,
  });
}

class MenuGrid extends StatelessWidget {
  final List<MenuItemData> items;

  const MenuGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Color>>(
        valueListenable: AppColors.gradientNotifier,
        builder: (context, colors, _) {
          return Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 9,
                    offset: const Offset(0, 6),
                  )
                ],
                image: Theme.of(context).brightness == Brightness.dark
                    ? null
                    : const DecorationImage(
                        image: AssetImage("assets/images/bg.png"),
                        fit: BoxFit.cover,
                      ),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final it = items[index];
                  return GestureDetector(
                    onTap: it.onTap,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            // color: colors[0].withOpacity(0.08),
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? it.bgIcon
                                    : colors[0].withOpacity(0.08),
                            // color: const Color.fromARGB(255, 220, 233, 247),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconTheme(
                            data: IconThemeData(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? it.colorIcon
                                  : colors[1],
                              // color: Color.fromARGB(255, 29, 103, 172),
                              size: 28,
                              weight: 800,
                            ),
                            child: Icon(it.icon),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          it.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppDimens.fontBody,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.textLight
                                    : Color.fromARGB(255, 82, 90, 99),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ));
        });
  }
}

import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onPressed;

  const SquareButton({
    super.key,
    required this.color,
    required this.icon,
    this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}

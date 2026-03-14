import 'package:flutter/material.dart';

class MultipleInputRow extends StatelessWidget {
  final Widget dropdown;
  final bool showSerialInput;
  final ValueChanged<String>? onSerialChanged;
  final VoidCallback onAdd;
  final VoidCallback onDelete;

  const MultipleInputRow({
    super.key,
    required this.dropdown,
    required this.onAdd,
    required this.onDelete,
    this.showSerialInput = false,
    this.onSerialChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: dropdown),
        const SizedBox(width: 8),
        _squareButton(
          color: Colors.grey.shade400,
          icon: Icons.add,
          onPressed: onAdd,
        ),
        const SizedBox(width: 8),
        _squareButton(
          color: Colors.red.shade300,
          icon: Icons.delete,
          iconColor: Colors.red,
          onPressed: onDelete,
        ),
        if (showSerialInput) ...[
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "Serial Number",
                border: OutlineInputBorder(),
              ),
              onChanged: onSerialChanged,
            ),
          ),
        ],
      ],
    );
  }

  Widget _squareButton({
    required Color color,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onPressed,
  }) {
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/theme.dart';

class InputForm extends StatefulWidget {
  const InputForm(
      {super.key,
      required this.controller,
      this.hintText = "Username or Email",
      this.isPassword = false,
      this.validator,
      this.showError = false,
      this.prefixIcon});

  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final String? Function(String?)? validator;
  final bool showError;
  final IconData? prefixIcon;

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  bool _obscure = true;
  String? _error;

  @override
  void didUpdateWidget(covariant InputForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showError && widget.validator != null) {
      _error = widget.validator!(widget.controller.text);
    } else if (!widget.showError) {
      _error = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(2.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppDimens.borderRadius),
            border: Border.all(
              width: 2,
              color: _error != null
                  ? Theme.of(context).colorScheme.error
                  : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscure : false,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 14.r, horizontal: 12.r),
              hintText: widget.hintText,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: Colors.grey)
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscure = !_obscure);
                      },
                    )
                  : null,
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: EdgeInsets.only(top: 4.r, left: 8.r),
            child: Text(
              _error!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

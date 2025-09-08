import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CustomTextButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDisabled;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isDisabled = false,
    this.color,
    this.fontWeight,
    this.fontSize,
  });

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isDisabled) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (!widget.isDisabled) {
          setState(() => _isPressed = false);
          widget.onPressed();
        }
      },
      onTapCancel: () {
        if (!widget.isDisabled) {
          setState(() => _isPressed = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingS,
          vertical: AppTheme.spacingXS,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusS),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    offset: const Offset(-1, -1),
                    blurRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(-1, -1),
                    blurRadius: 2,
                  ),
                ],
        ),
        child: Text(
          widget.text,
          style: AppTheme.titleMedium.copyWith(
            color: widget.color ?? AppTheme.primaryColor,
            fontWeight: widget.fontWeight ?? FontWeight.w500,
            fontSize: widget.fontSize,
            decoration: widget.isDisabled ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}

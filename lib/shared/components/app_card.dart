import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'dart:ui';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool elevated;
  final bool glassmorphic;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8),
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
    this.elevated = false,
    this.glassmorphic = true,
  });

  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spacingM),
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
    this.glassmorphic = false,
  }) : elevated = true;

  @override
  Widget build(BuildContext context) {
    final cardBorderRadius =
        borderRadius ?? BorderRadius.circular(AppTheme.borderRadiusM);

    if (glassmorphic) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: cardBorderRadius,
          border: Border.all(
            color: AppTheme.borderColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow:
              boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -4),
                ),
              ],
        ),
        child: ClipRRect(
          borderRadius: cardBorderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: (backgroundColor ?? AppTheme.surfaceColor).withOpacity(
                0.8,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: cardBorderRadius as BorderRadius?,
                  child: Padding(padding: padding, child: child),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surfaceColor,
        borderRadius: cardBorderRadius,
        boxShadow:
            boxShadow ?? (elevated ? [AppTheme.shadowLg] : [AppTheme.shadowMd]),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardBorderRadius as BorderRadius?,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

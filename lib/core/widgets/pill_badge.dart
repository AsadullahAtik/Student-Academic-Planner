import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

/// Reusable pill/badge widget matching prototype2 `.pill-badge`
class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.label,
    this.bgColor,
    this.textColor,
    this.borderColor,
    this.fontSize = 10.0,
  });

  final String label;
  final Color? bgColor;
  final Color? textColor;
  final Color? borderColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final bg = bgColor ?? AppColors.primary.withOpacity(0.1);
    final tc = textColor ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: tc,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

/// Reusable animated progress bar matching prototype2 progress bars.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.showLabel = true,
    this.labelFontSize = 11.0,
  });

  /// 0–100
  final int progress;
  final double height;
  final bool showLabel;
  final double labelFontSize;

  Color get _barColor {
    if (progress >= 100) return AppColors.success;
    if (progress > 40) return AppColors.primary;
    return AppColors.accent;
  }

  Color get _labelColor {
    if (progress >= 100) return AppColors.success;
    if (progress > 40) return AppColors.primary;
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart_rounded, size: 11, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Completion Progress',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      color: scheme.onSurface.withOpacity(0.55),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '$progress%',
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w800,
                  color: _labelColor,
                ),
              ),
            ],
          ),
        if (showLabel) const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (progress / 100).clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(_barColor),
          ),
        ),
      ],
    );
  }
}

/// Interactive slider + preset buttons for setting progress
class ProgressEditor extends StatefulWidget {
  const ProgressEditor({
    super.key,
    required this.initialProgress,
    required this.onChanged,
  });

  final int initialProgress;
  final ValueChanged<int> onChanged;

  @override
  State<ProgressEditor> createState() => _ProgressEditorState();
}

class _ProgressEditorState extends State<ProgressEditor> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialProgress.toDouble();
  }

  @override
  void didUpdateWidget(ProgressEditor old) {
    super.didUpdateWidget(old);
    if (old.initialProgress != widget.initialProgress) {
      _value = widget.initialProgress.toDouble();
    }
  }

  void _set(int v) {
    setState(() => _value = v.toDouble());
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Set %:',
              style: TextStyle(
                fontSize: 10,
                color: scheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: scheme.surfaceContainerHighest,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withOpacity(0.15),
                ),
                child: Slider(
                  value: _value,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (v) => setState(() => _value = v),
                  onChangeEnd: (v) => widget.onChanged(v.round()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [25, 50, 75, 100].map((pct) {
            final isHundred = pct == 100;
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: GestureDetector(
                onTap: () => _set(pct),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isHundred
                        ? AppColors.success.withOpacity(0.15)
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isHundred
                          ? AppColors.success.withOpacity(0.4)
                          : scheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isHundred ? AppColors.success : scheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

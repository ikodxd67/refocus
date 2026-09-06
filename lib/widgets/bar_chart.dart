import 'package:flutter/material.dart';

import '../theme.dart';

/// One bar: a value, the label under it, and whether it should be emphasised.
class Bar {
  final double value;
  final String label;
  final bool highlight;

  const Bar({required this.value, required this.label, this.highlight = false});
}

/// A small, theme-aware bar chart.
///
/// Hand-drawn rather than pulled from a chart package so the axis, the baseline
/// and the empty state all follow the app's own palette exactly, and so the
/// scale is honest: every bar is measured against a single [maxValue] that the
/// caller can pin (e.g. 1.0 for rates).
class BarChart extends StatelessWidget {
  final List<Bar> bars;

  /// Upper bound of the scale. Defaults to the largest value present.
  final double? maxValue;

  /// Rendered at the top-right of the plot as the scale's ceiling.
  final String? maxLabel;

  final double height;

  /// Show only every n-th label, to keep dense axes readable.
  final int labelEvery;

  const BarChart({
    super.key,
    required this.bars,
    this.maxValue,
    this.maxLabel,
    this.height = 120,
    this.labelEvery = 1,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    if (bars.isEmpty || bars.every((b) => b.value == 0)) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text('Nothing here yet',
              style: TextStyle(color: p.faint, fontSize: 12)),
        ),
      );
    }

    final ceiling = maxValue ??
        bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (maxLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(maxLabel!,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: p.faint,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600)),
          ),
        SizedBox(
          height: height,
          child: CustomPaint(
            painter: _BarChartPainter(
              bars: bars,
              ceiling: ceiling <= 0 ? 1 : ceiling,
              barColor: p.teal,
              highlightColor: p.tealInk,
              trackColor: p.line,
              labelColor: p.faint,
              labelEvery: labelEvery,
            ),
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<Bar> bars;
  final double ceiling;
  final Color barColor;
  final Color highlightColor;
  final Color trackColor;
  final Color labelColor;
  final int labelEvery;

  _BarChartPainter({
    required this.bars,
    required this.ceiling,
    required this.barColor,
    required this.highlightColor,
    required this.trackColor,
    required this.labelColor,
    required this.labelEvery,
  });

  static const _labelHeight = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final plotHeight = size.height - _labelHeight;
    if (plotHeight <= 0) return;

    final slot = size.width / bars.length;
    final barWidth = (slot * 0.62).clamp(2.0, 22.0);
    final radius = Radius.circular(barWidth / 2.5);

    // baseline
    final baseline = Paint()
      ..color = trackColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, plotHeight),
      Offset(size.width, plotHeight),
      baseline,
    );

    for (var i = 0; i < bars.length; i++) {
      final b = bars[i];
      final centerX = slot * i + slot / 2;

      final ratio = (b.value / ceiling).clamp(0.0, 1.0);
      final barHeight = ratio * (plotHeight - 4);

      // faint track behind every slot, so empty days read as "zero", not "missing"
      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - barWidth / 2, 2, barWidth, plotHeight - 4),
        radius,
      );
      canvas.drawRRect(
        trackRect,
        Paint()..color = trackColor.withValues(alpha: 0.35),
      );

      if (barHeight > 0) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            centerX - barWidth / 2,
            plotHeight - barHeight,
            barWidth,
            barHeight,
          ),
          radius,
        );
        canvas.drawRRect(
          rect,
          Paint()..color = b.highlight ? highlightColor : barColor,
        );
      }

      if (i % labelEvery == 0 && b.label.isNotEmpty) {
        final tp = TextPainter(
          text: TextSpan(
            text: b.label,
            style: TextStyle(
              color: labelColor,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(centerX - tp.width / 2, plotHeight + 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.bars != bars || old.ceiling != ceiling;
}

import 'package:flutter/material.dart';

import '../theme.dart';

/// The circular 15-second countdown used on the pause screen.
class CountdownRing extends StatelessWidget {
  final int secondsLeft;
  final int total;
  final double size;

  const CountdownRing({
    super.key,
    required this.secondsLeft,
    required this.total,
    this.size = 96,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 1.0 : 1 - (secondsLeft / total);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(progress),
          ),
          Text(
            '$secondsLeft',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: NightPalette.ink,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress; // 0..1
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = NightPalette.surfaceLine;
    canvas.drawCircle(center, radius, track);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = NightPalette.teal;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // start at top
      6.2832 * progress.clamp(0.0, 1.0),
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

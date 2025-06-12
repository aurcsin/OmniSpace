// File: lib/widgets/mood_chart.dart

import 'package:flutter/material.dart';

/// Displays a simple line of mood values over time.
class MoodChart extends StatelessWidget {
  final List<int> moods;

  const MoodChart({super.key, required this.moods});

  @override
  Widget build(BuildContext context) {
    if (moods.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxMood = moods.reduce((a, b) => a > b ? a : b).toDouble();
    final points = <Offset>[];
    for (var i = 0; i < moods.length; i++) {
      points.add(Offset(i.toDouble(), moods[i].toDouble()));
    }

    return SizedBox(
      height: 120,
      child: CustomPaint(
        painter: _MoodPainter(points: points, max: maxMood),
      ),
    );
  }
}

class _MoodPainter extends CustomPainter {
  final List<Offset> points;
  final double max;

  _MoodPainter({required this.points, required this.max});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final normalized = points
        .map((p) => Offset(p.dx / (points.length - 1) * size.width,
            size.height - (p.dy / max * size.height)))
        .toList();

    final path = Path()..moveTo(normalized.first.dx, normalized.first.dy);
    for (final p in normalized.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

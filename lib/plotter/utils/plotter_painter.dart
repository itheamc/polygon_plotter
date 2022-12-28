import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:polygon_plotter/plotter/utils/extension_function.dart';

import '../models/a_point.dart';

class PlotterPainter extends CustomPainter {
  final List<APoint> points;
  final APoint? startingPoint;

  PlotterPainter(
    this.points, {
    this.startingPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint Object for Polygon
    final linePaint = Paint()
      ..color = Colors.blue[900] ?? Colors.blue
      ..strokeWidth = 2.0;

    canvas.drawPoints(
        PointMode.polygon, points.map((e) => e.position).toList(), linePaint);

    // Drawing lines
    for (final point in points) {
      if (point.lines.isNotEmpty) {
        for (int i = 0; i < point.lines.length; i++) {
          if (i == 0) continue;
          canvas.drawLine(point.lines[i].start.position,
              point.lines[i].end.position, linePaint);
        }
      }
    }

    // Paint Object for Circle
    final circlePaint = Paint()..color = Colors.blue[900] ?? Colors.blue;

    for (final node in points) {
      canvas.drawCircle(
        node.position,
        5,
        circlePaint,
      );

      final TextPainter textPainter = TextPainter(
          text: TextSpan(
              text: node.label ?? "hh",
              style: TextStyle(
                color: Colors.blue[900],
              )),
          textAlign: TextAlign.justify,
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: 24.0);
      textPainter.paint(canvas, node.position.translate(5, 1));
    }

    // Paint Object for Selected Point Circle
    final selectedPointPaint = Paint()..color = Colors.green;

    if (startingPoint != null) {
      canvas.drawCircle(
        startingPoint!.position,
        6,
        selectedPointPaint,
      );
    }

    for (final l in points.lines) {
      if (l.distance != 0.0) {
        final TextPainter textPainter = TextPainter(
            text: TextSpan(
              text: "${l.distance}",
              style: TextStyle(
                color: Colors.blue[900],
              ),
            ),
            textAlign: TextAlign.justify,
            textDirection: TextDirection.ltr)
          ..layout(maxWidth: 60.0);
        textPainter.paint(canvas, l.center.translate(7.5, 1));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

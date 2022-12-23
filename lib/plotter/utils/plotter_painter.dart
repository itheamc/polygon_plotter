import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/point_node.dart';

class PlotterPainter extends CustomPainter {
  final List<PointNode> pointNodes;
  final PointNode? startingPoint;

  PlotterPainter(
    this.pointNodes, {
    this.startingPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint Object for Polygon
    final linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;

    canvas.drawPoints(PointMode.polygon,
        pointNodes.map((e) => e.position).toList(), linePaint);

    // Drawing lines
    for (final node in pointNodes) {
      if (node.lines.isNotEmpty) {
        for (final line in node.lines) {
          canvas.drawLine(line.start.position, line.end.position, linePaint);
        }
      }
    }

    // Paint Object for Circle
    final circlePaint = Paint()..color = Colors.red;

    for (final node in pointNodes) {
      canvas.drawCircle(
        node.position,
        5,
        circlePaint,
      );

      final TextPainter textPainter = TextPainter(
          text: TextSpan(
              text: node.label ?? "hh",
              style: const TextStyle(
                color: Colors.red,
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

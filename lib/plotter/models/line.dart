import 'dart:ui';

import 'package:polygon_plotter/plotter/models/point_node.dart';

/// Line Class
class Line {
  final PointNode start;
  final PointNode end;
  final double distance;

  Offset get center {
    return Offset((start.position.dx + end.position.dx) / 2,
        (start.position.dy + end.position.dy) / 2);
  }

  Line(
    this.start,
    this.end, {
    this.distance = 0.0,
  });

  Line copy({
    PointNode? start,
    PointNode? end,
    double? distance,
  }) {
    return Line(
      start ?? this.start,
      end ?? this.end,
      distance: distance ?? this.distance,
    );
  }
}

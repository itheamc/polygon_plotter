import 'dart:ui';

import 'package:polygon_plotter/plotter/models/point.dart';

/// Line Class
class Line {
  final Point start;
  final Point end;
  final double distance;

  Offset get center {
    return Offset((start.position.dx + end.position.dx) / 2,
        (start.position.dy + end.position.dy) / 2);
  }

  /// Constructor
  Line(
    this.start,
    this.end, {
    this.distance = 0.0,
  });

  /// Method to copy the line
  Line copy({
    Point? start,
    Point? end,
    double? distance,
  }) {
    return Line(
      start ?? this.start,
      end ?? this.end,
      distance: distance ?? this.distance,
    );
  }

  /// Method to check if two line are same or not
  bool isSame(Line line) {
    return center.dx == line.center.dx && center.dy == line.center.dy;
  }
}

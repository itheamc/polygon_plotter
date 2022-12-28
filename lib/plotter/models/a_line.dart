import 'dart:ui';

import 'a_point.dart';

/// Line Class
class ALine {
  final APoint start;
  final APoint end;
  final double distance;

  Offset get center {
    return Offset((start.position.dx + end.position.dx) / 2,
        (start.position.dy + end.position.dy) / 2);
  }

  /// Constructor
  ALine(
    this.start,
    this.end, {
    this.distance = 0.0,
  });

  /// Method to copy the line
  ALine copy({
    APoint? start,
    APoint? end,
    double? distance,
  }) {
    return ALine(
      start ?? this.start,
      end ?? this.end,
      distance: distance ?? this.distance,
    );
  }

  /// Method to check if two line are same or not
  bool isSame(ALine line) {
    return this == line;
  }

  @override
  bool operator ==(Object other) =>
      other is ALine &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end &&
          center.dx == other.center.dx &&
          center.dy == other.center.dy;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

import 'dart:ui';

import 'package:polygon_plotter/plotter/utils/extension_function.dart';

import 'line.dart';

/// Point Class
class Point {
  final int index;
  final Offset position;
  final Point? next;
  final List<Line> lines;

  // Label
  String? get label => index.label;

  // Center between this and next point
  Offset? get center {
    return next != null
        ? Offset((position.dx + next!.position.dx) / 2,
            (position.dy + next!.position.dy) / 2)
        : null;
  }

  Point({
    required this.index,
    required this.position,
    this.next,
    this.lines = const [],
  });

  /// Method to copy Point
  Point copy({
    int? index,
    Offset? position,
    Point? next,
    List<Line>? lines,
  }) {
    return Point(
      index: index ?? this.index,
      position: position ?? this.position,
      next: next ?? this.next,
      lines: lines ?? this.lines,
    );
  }

  /// Method to convert Point to Json
  Map<String, dynamic> toJson() {
    return {
      "index": index,
      "label": label,
      "position": "[x: ${position.dx}, y: ${position.dy}]",
      "next": next?.toJson(),
      "lines": lines.map((e) => [e.start.toJson(), e.end.toJson()]).toList(),
    };
  }

  /// Method to remove line
  /// if index is given, line with that will index will be removed else last added
  /// line will be removed
  void removeLine({int? index}) {
    if (lines.isEmpty) return;

    if (index != null) {
      if (index >= 0 && index < lines.length) {
        lines.removeAt(index);
      }
      return;
    }

    lines.removeLast();
  }

  /// Method to check if already connected
  bool isAlreadyConnected(Point node) {
    return index == node.next?.index || next?.index == node.index;
  }

  /// Method to check if two point are same or not
  bool isSame(Point point) {
    return index == point.index;
  }
}

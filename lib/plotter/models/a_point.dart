import 'dart:ui';

import 'package:polygon_plotter/plotter/utils/extension_function.dart';

import 'a_line.dart';

/// Point Class
class APoint {
  final int index;
  final Offset position;
  APoint? next;
  final List<ALine> lines;

  // Label
  String? get label => index.label;

  // Center between this and next point
  Offset? get center {
    return next != null
        ? Offset((position.dx + next!.position.dx) / 2,
            (position.dy + next!.position.dy) / 2)
        : null;
  }

  APoint({
    required this.index,
    required this.position,
    this.next,
    this.lines = const [],
  });

  /// Method to copy Point
  APoint copy({
    int? index,
    Offset? position,
    APoint? next,
    List<ALine>? lines,
  }) {
    return APoint(
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

  /// Method to update next point of this point
  void updateNext(APoint next) {
    this.next = next;
    lines.insert(0, ALine(this, this.next!));
  }

  /// Method to check if already connected
  bool isAlreadyConnected(APoint node) {
    return index == node.next?.index || next?.index == node.index;
  }

  /// Method to check if two point are same or not
  bool isSame(APoint point) {
    return this == point;
  }

  @override
  bool operator ==(Object other) =>
      other is APoint &&
      runtimeType == other.runtimeType &&
      index == other.index &&
      position.dx == other.position.dx &&
      position.dy == other.position.dy;

  @override
  int get hashCode => index.hashCode ^ position.hashCode;
}

import 'package:flutter/cupertino.dart';

import '../models/a_line.dart';
import '../models/a_point.dart';
import '../models/a_triangle.dart';

/// -----------------------------------------------------------------------
/// Extension functions on List of Point
extension PointNodeListExt on List<APoint> {
  // Method to remove line
  void removeLine(ALine line) {
    for (final point in this) {
      for (int i = 0; i < point.lines.length; i++) {
        if (line.isSame(point.lines[i])) {
          point.lines.removeAt(i);
          return;
        }
      }
    }
  }

  // Method to add line
  void addLine(APoint point, ALine line) {
    for (final n in this) {
      if (n.index == point.index) {
        n.lines.add(line);
        return;
      }
    }
  }

  // Method to update line
  void updateLine(ALine line) {
    for (final point in this) {
      for (int i = 0; i < point.lines.length; i++) {
        if (line.isSame(point.lines[i])) {
          point.lines.removeAt(i);
          point.lines.insert(i, line);
          return;
        }
      }
    }
  }

  // Method to get point by offset
  APoint? pointByOffset(Offset position) {
    if (isEmpty) return null;

    for (final point in this) {
      if ((point.position.dx - position.dx).abs() <= 15 &&
          (point.position.dy - position.dy).abs() <= 15) {
        return point;
      }
    }

    return null;
  }

  // Method to get line by offset
  ALine? lineByOffset(Offset position) {
    final x = position.dx;
    final y = position.dy;

    for (final l in lines) {
      final x1 = l.start.position.dx;
      final y1 = l.start.position.dy;

      final x2 = l.end.position.dx;
      final y2 = l.end.position.dy;

      if ((((y - y1) / (y2 - y1)) - ((x - x1) / (x2 - x1))).abs() <= 0.0375) {
        return l;
      }
    }

    return null;
  }

  // Method to get all lines
  List<ALine> get lines {
    // creating list to contains each and every lines
    final _lines = List<ALine>.empty(growable: true);

    // adding polygons outer lines to the _lines list
    // for (int i = 0; i < length - 1; i++) {
    //   _lines.add(ALine(this[i], this[i + 1]));
    // }

    // adding lines drawn inside the polygon in the _lines list
    for (int i = 0; i < length - 1; i++) {
      _lines.addAll(this[i].lines);
    }

    return _lines;
  }

  // Method to check if the line are already drawn
  bool isLineAlreadyDrawn(ALine line) {
    for (final point in this) {
      if (point.lines.any((l) => line.isSame(l))) {
        return true;
      }
    }

    return false;
  }

  // Getter for max number of triangles that can be created
  int get maxPossibleTriangles => length - 1 - 2;

  // Boolean to check if polygon is made or not
  bool get isPolygonDrawn =>
      isNotEmpty && length > 2 && first.index == last.index;

  // Boolean to check if all triangles are made or not
  bool get isAllTrianglesAreDrawn =>
      isPolygonDrawn && lines.triangles.length == maxPossibleTriangles;

  // Method to check if point is ending point
  bool isEndingPoint(Offset position) {
    if (isEmpty || length <= 2) return false;

    return (first.position.dx - position.dx).abs() <= 7.5 &&
        (first.position.dy - position.dy).abs() <= 7.5;
  }

  // Method to check if points are too close or not
  bool isTooClose(Offset position) {
    return any((node) =>
        (node.position.dx - position.dx).abs() <= 15 &&
        (node.position.dy - position.dy).abs() <= 15);
  }
}

/// -------------------------------------------------------------------------
/// Extension functions on List of Line
extension LineListExt on List<ALine> {
  // Method to create triangles from the points and line drawn
  List<ATriangle> get triangles {
    final _triangles = List<ATriangle>.empty(growable: true);

    if (isEmpty) return _triangles;

    // list of all lines
    final _lines = this;

    // Iterating through the lines, forming triangle and adding to the list
    for (final line1 in _lines) {
      for (final line2 in _lines) {
        if (line2.isSame(line1)) continue;

        if (line1.start.isSame(line2.start) ||
            line1.start.isSame(line2.end) ||
            line1.end.isSame(line2.start) ||
            line1.end.isSame(line2.end)) {
          for (final line3 in _lines) {
            if (line3.isSame(line1) || line3.isSame(line2)) continue;

            if (line1.start.isSame(line2.start)) {
              if ((line2.end.isSame(line3.end) &&
                      line3.start.isSame(line1.end)) ||
                  (line2.end.isSame(line3.start) &&
                      line3.end.isSame(line1.end))) {
                final _triangle = ATriangle(line1, line2, line3);
                if (!_triangles.isAlreadyFormed(_triangle)) {
                  _triangles.add(_triangle);
                  break;
                }
              }
            } else if (line1.start.isSame(line2.end)) {
              if ((line3.start.isSame(line2.start) &&
                      line3.end.isSame(line1.end)) ||
                  (line3.end.isSame(line2.start) &&
                      line3.end.isSame(line1.end))) {
                final _triangle = ATriangle(line1, line2, line3);
                if (!_triangles.isAlreadyFormed(_triangle)) {
                  _triangles.add(_triangle);
                  break;
                }
              }
            } else if (line1.end.isSame(line2.start)) {
              if ((line3.end.isSame(line2.end) &&
                      line3.start.isSame(line1.start)) ||
                  (line3.start.isSame(line2.end) &&
                      line3.end.isSame(line1.start))) {
                final _triangle = ATriangle(line1, line2, line3);
                if (!_triangles.isAlreadyFormed(_triangle)) {
                  _triangles.add(_triangle);
                  break;
                }
              }
            } else if (line1.end.isSame(line2.end)) {
              if ((line3.start.isSame(line2.start) &&
                      line3.end.isSame(line1.start)) ||
                  (line3.end.isSame(line2.start) &&
                      line3.start.isSame(line1.start))) {
                final _triangle = ATriangle(line1, line2, line3);
                if (!_triangles.isAlreadyFormed(_triangle)) {
                  _triangles.add(_triangle);
                  break;
                }
              }
            } else {
              // Ignore
              continue;
            }
          }
        }
      }
    }

    return _triangles;
  }

  // Method to update line
  void updateLine(ALine line) {
    for (int i = 0; i < length; i++) {
      if (line.isSame(this[i])) {
        removeAt(i);
        insert(i, line);
        return;
      }
    }
  }
}

/// ----------------------------------------------------------------------
/// Extension functions on List of Triangle
extension TriangleListExt on List<ATriangle> {
  // Method to check if triangle already formed adn added to the list
  bool isAlreadyFormed(ATriangle triangle) {
    return any((t) => t.isSame(triangle));
  }

  // Method to calculate area of triangle
  double get cumulativeArea {
    double _area = 0;

    if (isNotEmpty) {
      for (final triangle in this) {
        _area += triangle.area;
      }
    }

    return !_area.isNaN ? double.parse(_area.toStringAsFixed(4)) : 0;
  }
}

/// ----------------------------------------------------------------------
/// Extension Function
extension InteExt on int {
  String? get label {
    switch (this) {
      case 0:
        return "A";
      case 1:
        return "B";
      case 2:
        return "C";
      case 3:
        return "D";
      case 4:
        return "E";
      case 5:
        return "F";
      case 6:
        return "G";
      case 7:
        return "H";
      case 8:
        return "I";
      case 9:
        return "J";
      case 10:
        return "K";
      case 11:
        return "L";
      case 12:
        return "M";
      case 13:
        return "N";
      case 14:
        return "O";
      case 15:
        return "P";
      case 16:
        return "Q";
      case 17:
        return "R";
      case 18:
        return "S";
      case 19:
        return "T";
      case 20:
        return "U";
      case 21:
        return "V";
      case 22:
        return "W";
      case 23:
        return "X";
      case 24:
        return "Y";
      case 25:
        return "Z";
      case 26:
        return "ZA";
      case 27:
        return "ZB";
      case 28:
        return "ZC";
      case 29:
        return "ZD";
      case 30:
        return "ZE";
      case 31:
        return "ZF";
      case 32:
        return "ZG";
      case 33:
        return "ZH";
      case 34:
        return "ZI";
      case 35:
        return "ZJ";
      case 36:
        return "ZK";
      case 37:
        return "ZL";
      default:
        return null;
    }
  }
}

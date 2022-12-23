import 'dart:math' as math;
import 'dart:ui';
import '../models/line.dart';
import '../models/point_node.dart';

/// LineUtils
class LineUtils {
  static bool isIntersected(
      PointNode start, PointNode end, List<PointNode> nodes) {
    final _line = Line(start, end);

    final _temp = List<PointNode>.from(nodes);

    bool _intersectingBoundaries = false;

    for (final n in _temp) {
      if ((n.index == start.index && n.next?.index == start.next?.index) ||
          (n.index == end.index && n.next?.index == end.next?.index) ||
          (n.next?.index == end.index) ||
          (n.next?.index == start.index)) {
        continue;
      }
      _intersectingBoundaries = _checkIntersection(_line, Line(n, n.next!));

      if (_intersectingBoundaries) break;
    }

    bool _intersectingLines = false;

    for (final n in _temp) {
      if (n.index == end.index || n.index == start.index) {
        continue;
      }
      for (final l in n.lines) {
        if (l.start.index == end.index ||
            l.end.index == end.index ||
            l.start.index == start.index ||
            l.end.index == start.index) {
          continue;
        }

        _intersectingLines = _checkIntersection(_line, l);

        if (_intersectingLines) break;
      }
      if (_intersectingLines) break;
    }

    return _intersectingBoundaries || _intersectingLines;
  }

  /// Method to check intersection
  static bool _checkIntersection(Line line1, Line line2) {
    // Calculation the orientation of four triple endpoints
    double o1 = _orientation(line1, line2.start);
    double o2 = _orientation(line1, line2.end);
    double o3 = _orientation(line2, line1.start);
    double o4 = _orientation(line2, line1.end);

    // General Case
    if (o1 != o2 && o3 != o4) return true;

    // Special Case
    // line1 two points and line2 start point are collinear
    // and line2 start point lies on segment line1
    if (o1 == 0 && _onSegment(line1, line2.start)) return true;

    // line1 two points and line2 end point are collinear
    // and line2 end point lies on segment line1
    if (o2 == 0 && _onSegment(line1, line2.end)) return true;

    // line2 two points and line1 start point are collinear
    // and line1 start point lies on segment line2
    if (o3 == 0 && _onSegment(line2, line1.start)) return true;

    // line2 two points and line1 end point are collinear
    // and line1 end point lies on segment line2
    if (o4 == 0 && _onSegment(line2, line1.end)) return true;

    return false;
  }

  /// Method to check if point lies on line segment
  static bool _onSegment(Line line, PointNode point) {
    // Extracting X1, Y1 and X2, Y2 from line
    final lX1 = line.start.position.dx;
    final lY1 = line.start.position.dy;

    final lX2 = line.end.position.dx;
    final lY2 = line.end.position.dy;

    // Extracting X and Y from point
    final pX = point.position.dx;
    final pY = point.position.dy;

    return pX <= math.max<double>(lX1, lX2) &&
        pX >= math.min<double>(lX1, lX2) &&
        pY <= math.max<double>(lY1, lY2) &&
        pY >= math.min<double>(lY1, lY2);
  }

  /// Method to check orientation of a triplet of endpoints
  static double _orientation(Line line, PointNode point) {
    // Extracting X1, Y1 and X2, Y2 from line
    final lX1 = line.start.position.dx;
    final lY1 = line.start.position.dy;
    final lX2 = line.end.position.dx;
    final lY2 = line.end.position.dy;

    // Extracting X and Y from point
    final pX = point.position.dx;
    final pY = point.position.dy;

    double _exp = ((lY2 - lY1) * (pX - lX2)) - ((lX2 - lX1) * (pY - lY2));

    return _exp == 0.0
        ? 0
        : _exp > 0
            ? 1
            : 2;
  }

  /// Method to check if line drawn is with in polygon boundary or not
  static bool isOutsidePolygon(Line line, List<PointNode> nodes) {
    int _intersectionCount = 0;

    for (final n in nodes) {
      final _intersected = _checkIntersection(
          Line(PointNode(index: -1, position: line.center),
              PointNode(index: -2, position: Offset(50000.0, line.center.dx))),
          Line(n, n.next!));

      if (_intersected) {
        _intersectionCount++;
      }
    }

    return _intersectionCount % 2 == 0 && !_isWithInPolygon(line, nodes);
  }

  /// Method to check if line is within polygon boundary
  static bool _isWithInPolygon(Line line, List<PointNode> nodes) {
    // Extracting Positions
    final _positions = nodes.map((e) => e.position).toList();

    // Extracting dx
    final listOfDx = _positions.map((e) => e.dx).toList();

    // Extracting dy
    final listOfDy = _positions.map((e) => e.dy).toList();

    final xMin = nodes.isNotEmpty
        ? listOfDx.reduce(
            (value, element) => value == 0 || element < value ? element : value)
        : 0.0;

    final xMax = nodes.isNotEmpty
        ? listOfDx.reduce((value, element) => element > value ? element : value)
        : 0.0;

    final yMin = nodes.isNotEmpty
        ? listOfDy.reduce(
            (value, element) => value == 0 || element < value ? element : value)
        : 0.0;

    final yMax = nodes.isNotEmpty
        ? listOfDy.reduce((value, element) => element > value ? element : value)
        : 0.0;

    if (line.center.dx < xMin ||
        line.center.dx > xMax ||
        line.center.dy < yMin ||
        line.center.dy > yMax) {
      return false;
    }

    bool _inside = false;

    for (int i = 0, j = nodes.length - 1; i < nodes.length; j = i++) {
      if ((nodes[i].position.dy > line.center.dy) !=
              (nodes[j].position.dy > line.center.dy) &&
          line.center.dx <
              (nodes[j].position.dx - nodes[i].position.dx) *
                      (line.center.dy - nodes[i].position.dy) /
                      (nodes[j].position.dy - nodes[i].position.dy) +
                  nodes[i].position.dx) {
        _inside = !_inside;
      }
    }

    return _inside;
  }
}

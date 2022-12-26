import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polygon_plotter/plotter/utils/extension_function.dart';

import '../models/line.dart';
import '../models/point.dart';
import '../utils/line_utils.dart';
import '../utils/user_event.dart';

class PlotterController extends GetxController {
  ///-------------------------List of User Events-------------------------
  /// For handling undo
  final _listOfUserEvents = List.empty(growable: true).obs;

  /// List Of Lines added by the user on polygon except polygon
  /// boundary lines
  final _listOfLinesDrawnOnPolygon = List<Line>.empty(growable: true);

  ///---------------------------------------------------------------------

  ///------------------------For Polygon Points---------------------------
  /// List Of Points
  final _points = List<Point>.empty(growable: true).obs;

  List<Point> get points => _points;

  ///---------------------------------------------------------------------

  ///---------List of Lines along with polygon boundary lines-------------
  /// List of all lines
  final _listOfLines = List<Line>.empty(growable: true).obs;

  List<Line> get listOfLines => _listOfLines;

  ///---------------------------------------------------------------------

  ///-----------------------For creating triangles------------------------
  /// Start Point
  final _start = _pointAsNull().obs;

  Point? get start => _start.value.index == -1 ? null : _start.value;

  /// Start Point
  final _end = _pointAsNull().obs;

  Point? get end => _end.value.index == -1 ? null : _end.value;

  ///---------------------------------------------------------------------

  /// Method to get point by position (offset)
  Point? _pointByOffset(Offset position) {
    if (_points.isEmpty) return null;
    final _tempNode = _points.firstWhereOrNull((node) =>
        (node.position.dx - position.dx).abs() <= 15 &&
        (node.position.dy - position.dy).abs() <= 15);

    return _tempNode;
  }

  /// Boolean to check if polygon is made or not
  bool get isPolygonDrawn =>
      _points.isNotEmpty &&
      _points.length > 2 &&
      _points.first.index == _points.last.index;

  bool get isAllTrianglesAreDrawn =>
      isPolygonDrawn &&
      _points.lines.triangles.length == _points.maxPossibleTriangles;

  /// Method to check if point is ending point
  bool _isEndingPoint(Offset position) {
    if (_points.isEmpty || _points.length <= 2) return false;

    return (_points.first.position.dx - position.dx).abs() <= 7.5 &&
        (_points.first.position.dy - position.dy).abs() <= 7.5;
  }

  /// Method to check if points are too close or not
  bool _isTooClose(Offset position) {
    return _points.any((node) =>
        (node.position.dx - position.dx).abs() <= 15 &&
        (node.position.dy - position.dy).abs() <= 15);
  }

  /// --------------------------Public Methods--------------------------
  /// ------------------------------------------------------------------
  /// Method to handle on undo floating button click
  void handleUndoClick() {
    /// if start is selected
    if (start != null) _start.value = _pointAsNull();

    if (_listOfUserEvents.isEmpty) return;

    if (_listOfUserEvents.last == UserEvent.appPoint) {
      if (_points.isNotEmpty) {
        _points.removeLast();
      }
    } else if (_listOfUserEvents.last == UserEvent.addLine) {
      if (_listOfLinesDrawnOnPolygon.isNotEmpty) {
        _points.removeLine(_listOfLinesDrawnOnPolygon.last);
        _listOfLinesDrawnOnPolygon.removeLast();
      }
    } else {
      if (kDebugMode) {
        print("======>[Unspecified User Event]<=======");
      }
    }
    _listOfUserEvents.removeLast();
  }

  /// Method to handle onTap Down
  Future<void> handleOnTapDown(TapDownDetails details) async {
    if (!isPolygonDrawn) {
      _handlePolygonDrawn(details);
      update();
      return;
    }

    if (isAllTrianglesAreDrawn) {
      if (_listOfLines.isEmpty) {
        _listOfLines.addAll(_points.lines);
      }
      await _handleLineDistanceUpdate(details);
      update();
      return;
    }

    // If polygon is drawn
    _listOfLines.clear();
    _handleLineDrawn(details);
    update();
  }

  /// Method to handle polygon drawn
  void _handlePolygonDrawn(TapDownDetails details) {
    if (_isEndingPoint(details.globalPosition)) {
      final _firstPoint = points.first;
      final _lastPoint = points.last;
      final _updatedLastPoint = _lastPoint.copy(
        next: _firstPoint,
      );

      _points.removeLast();
      _points.add(_updatedLastPoint);
      _points.add(_firstPoint);

      // Update last user event for undo purpose
      _listOfUserEvents.add(UserEvent.appPoint);
    } else {
      if (_isTooClose(details.globalPosition)) {
        _showSnackBar("Too Close!!");
      } else {
        // add point
        final point = Point(
          index: _points.length,
          position: details.globalPosition,
          lines: List.empty(growable: true),
        );

        if (_points.isNotEmpty) {
          final _lastNode = _points.last;
          final _updatedLastNode = _lastNode.copy(
            next: point,
          );

          _points.removeLast();
          _points.add(_updatedLastNode);
        }
        _points.add(point);

        // Update last user event for undo purpose
        _listOfUserEvents.add(UserEvent.appPoint);
      }
    }
  }

  /// Method to handle line drawn if polygon is already created
  void _handleLineDrawn(TapDownDetails details) {
    // If polygon is drawn
    if (start == null) {
      _start.value = _pointByOffset(details.globalPosition) ?? _pointAsNull();
      return;
    } else {
      _end.value = _pointByOffset(details.globalPosition) ?? _pointAsNull();

      // If startNode and endNode not equal to null
      if (start != null && end != null) {
        // if _start point and end point is same
        if (start?.index == end?.index) {
          _start.value = _pointAsNull();
          _end.value = _pointAsNull();
          return;
        }

        // If already connected
        if (start!.isAlreadyConnected(end!)) {
          _start.value = end ?? _pointAsNull();
          _end.value = _pointAsNull();
          return;
        }

        // If line already drawn
        if (_points.isLineAlreadyDrawn(Line(start!, end!))) {
          _start.value = end ?? _pointAsNull();
          _end.value = _pointAsNull();
          return;
        }

        // If line is intersecting other lines or polygon boundaries
        if (LineUtils.isIntersected(start!, end!, _points)) {
          _showSnackBar("Line is intersecting boundaries or another lines!");
          _end.value = _pointAsNull();
          return;
        }

        // If line is intersecting other lines or polygon boundaries
        if (LineUtils.isOutsidePolygon(Line(start!, end!), _points)) {
          _showSnackBar("Line is outside the polygon!");
          _end.value = _pointAsNull();
          return;
        }

        final _line = Line(start!, end!);

        _listOfLinesDrawnOnPolygon.add(_line);
        _listOfUserEvents.add(UserEvent.addLine);
        _points.addLine(start!, _line);
        _end.value = _pointAsNull();
      }
    }
  }

  /// Method to set the line distance
  Future<void> _handleLineDistanceUpdate(TapDownDetails details) async {
    final _l = listOfLines.lineByOffset(details.globalPosition);

    if (_l != null) {
      final _textController = TextEditingController();
      _textController.text = "${_l.distance}";

      await Get.bottomSheet(
        Material(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Set the length of line ${_l.start.label}${_l.end.label}",
                  style: Get.theme.textTheme.headline6,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                FractionallySizedBox(
                  widthFactor: 1.0,
                  child: SizedBox(
                    height: 52.0,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_textController.text.trim().isNotEmpty) {
                          _listOfLines.updateLine(
                            _l.copy(
                              distance: double.parse(
                                _textController.text.trim(),
                              ),
                            ),
                          );
                        }
                        Get.back();
                      },
                      child: const Text("Set"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  ///------------------------Other Utility Methods------------------------
  ///---------------------------------------------------------------------
  /// Method to set point to default that will be considered as null
  static Point _pointAsNull() {
    return Point(index: -1, position: Offset.zero);
  }

  /// Method to show snack bar
  void _showSnackBar(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        margin: const EdgeInsets.all(20.0),
        borderRadius: 8.0,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}

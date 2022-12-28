import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polygon_plotter/plotter/utils/extension_function.dart';

import '../models/a_line.dart';
import '../models/a_point.dart';
import '../utils/line_utils.dart';
import '../utils/user_event.dart';

class PlotterController extends GetxController {
  ///-------------------------List of User Events-------------------------
  /// For handling undo
  final _listOfUserEvents = List.empty(growable: true).obs;

  /// List Of Lines added by the user on polygon except polygon
  /// boundary lines
  final _listOfLinesDrawnOnPolygon = List<ALine>.empty(growable: true);

  ///---------------------------------------------------------------------

  ///------------------------For Polygon Points---------------------------
  /// List Of Points
  final _points = List<APoint>.empty(growable: true).obs;

  List<APoint> get points => _points;

  ///---------------------------------------------------------------------

  ///-----------------------For creating triangles------------------------
  /// Start Point
  final _start = _pointAsNull().obs;

  APoint? get start => _start.value.index == -1 ? null : _start.value;

  /// Start Point
  final _end = _pointAsNull().obs;

  APoint? get end => _end.value.index == -1 ? null : _end.value;

  ///---------------------------------------------------------------------

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
        if (_points.isNotEmpty) {
          _points.removeLine(_points.last.lines.first);
        }
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
    update();
  }

  /// Method to handle onTap Down
  Future<void> handleOnTapDown(TapDownDetails details) async {
    if (!_points.isPolygonDrawn) {
      _handlePolygonDrawn(details);
      update();
      return;
    }

    if (!_points.isAllTrianglesAreDrawn) {
      // If polygon is drawn but all triangles are not drawn
      _handleLineDrawn(details);
      update();
      return;
    }

    // handle distance update of line
    await _handleLineDistanceUpdate(details);
    update();
  }

  /// Method to handle polygon drawn
  void _handlePolygonDrawn(TapDownDetails details) {
    if (_points.isEndingPoint(details.localPosition)) {
      final _firstPoint = points.first;
      final _lastPoint = points.last.copy();
      _lastPoint.updateNext(_firstPoint);

      _points.removeLast();
      _points.add(_lastPoint);
      _points.add(_firstPoint);

      // Update last user event for undo purpose
      _listOfUserEvents.add(UserEvent.appPoint);
    } else {
      if (_points.isTooClose(details.localPosition)) {
        _showSnackBar("बिन्दु धेरै नजिक हुँदै छ !!");
      } else {
        // add point
        final point = APoint(
          index: _points.length,
          position: details.localPosition,
          lines: List.empty(growable: true),
        );

        if (points.isNotEmpty &&
            LineUtils.isIntersected(_points.last, point, points)) {
          _showSnackBar("बिन्दुले बहुभुज सीमालाई काट्न सक्दैन !!");
          return;
        }

        if (_points.isNotEmpty) {
          final _lastNode = _points.last.copy();
          _lastNode.updateNext(point);

          _points.removeLast();
          _points.add(_lastNode);
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
      _start.value =
          _points.pointByOffset(details.localPosition) ?? _pointAsNull();
      return;
    } else {
      _end.value =
          _points.pointByOffset(details.localPosition) ?? _pointAsNull();

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
        if (_points.isLineAlreadyDrawn(ALine(start!, end!))) {
          _start.value = end ?? _pointAsNull();
          _end.value = _pointAsNull();
          return;
        }

        // If line is intersecting other lines or polygon boundaries
        if (LineUtils.isIntersected(start!, end!, _points)) {
          _showSnackBar("यो रेखाले अर्को रेखालाई काटिरहेको छ!");
          _end.value = _pointAsNull();
          return;
        }

        // If line is intersecting other lines or polygon boundaries
        if (LineUtils.isOutsidePolygon(ALine(start!, end!), _points)) {
          _showSnackBar("तपाईं बहुभुज सीमा बाहिर रेखा कोर्न सक्नुहुन्न!");
          _end.value = _pointAsNull();
          return;
        }

        final _line = ALine(start!, end!);

        _listOfLinesDrawnOnPolygon.add(_line);
        _listOfUserEvents.add(UserEvent.addLine);
        _points.addLine(start!, _line);
        _end.value = _pointAsNull();
      }
    }
  }

  /// Method to set the line distance
  Future<void> _handleLineDistanceUpdate(TapDownDetails details) async {
    final _l = _points.lineByOffset(details.localPosition);

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
                          _points.updateLine(
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
  static APoint _pointAsNull() {
    return APoint(index: -1, position: Offset.zero);
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

  /// Method to reset all
  void resetAll({bool updateUi = false}) {
    _listOfUserEvents.clear();
    _listOfLinesDrawnOnPolygon.clear();
    _points.clear();
    _start.value = _pointAsNull();
    _end.value = _pointAsNull();

    if (updateUi) {
      update();
    }
  }
}

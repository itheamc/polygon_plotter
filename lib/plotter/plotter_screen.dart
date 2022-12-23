import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polygon_plotter/plotter/utils/extension_function.dart';
import 'package:polygon_plotter/plotter/utils/plotter_painter.dart';
import 'package:polygon_plotter/plotter/utils/user_event.dart';

import 'utils/line_utils.dart';
import 'models/line.dart';
import 'models/point_node.dart';

class PlotterScreen extends StatefulWidget {
  const PlotterScreen({Key? key}) : super(key: key);

  @override
  State<PlotterScreen> createState() => _PlotterScreenState();
}

class _PlotterScreenState extends State<PlotterScreen> {
  /// List of User Events
  /// For handling undo
  final _userEvents = List.empty(growable: true);

  /// List Of PointNodes
  final _pointNodes = List<PointNode>.empty(growable: true);

  /// List Of Lines Added
  final _lines = List<Line>.empty(growable: true);

  /// For creating triangles
  /// Start PointNode
  PointNode? _startNode;

  /// End PointNode
  PointNode? _endNode;

  /// Method to get node by position (offset)
  PointNode? _nodeByOffset(Offset position) {
    if (_pointNodes.isEmpty) return null;
    final _tempNode = _pointNodes.firstWhereOrNull((node) =>
        (node.position.dx - position.dx).abs() <= 15 &&
        (node.position.dy - position.dy).abs() <= 15);

    return _tempNode;
  }

  /// Boolean to check if polygon is made or not
  bool get _isPolygonDrawn =>
      _pointNodes.isNotEmpty &&
      _pointNodes.length > 2 &&
      _pointNodes.first.index == _pointNodes.last.index;

  /// Method to check if point is ending point
  bool _isEndingPoint(Offset position) {
    if (_pointNodes.isEmpty || _pointNodes.length <= 2) return false;

    return (_pointNodes.first.position.dx - position.dx).abs() <= 7.5 &&
        (_pointNodes.first.position.dy - position.dy).abs() <= 7.5;
  }

  /// Method to check if points are too close or not
  bool _isTooClose(Offset position) {
    return _pointNodes.any((node) =>
        (node.position.dx - position.dx).abs() <= 15 &&
        (node.position.dy - position.dy).abs() <= 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: _handleUndoClick,
        child: const Icon(Icons.undo_outlined),
      ),
      body: GestureDetector(
        onTapDown: _handleOnTapDown,
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Colors.white,
          child: CustomPaint(
            painter: PlotterPainter(
              _pointNodes,
              startingPoint: _startNode,
            ),
          ),
        ),
      ),
    );
  }

  /// Method to handle onTap Down
  void _handleOnTapDown(TapDownDetails details) {
    setState(() {
      if (!_isPolygonDrawn) {
        if (_isEndingPoint(details.globalPosition)) {
          final _firstNode = _pointNodes.first;
          final _lastNode = _pointNodes.last;
          final _updatedLastNode = _lastNode.copy(
            next: _firstNode,
          );

          _pointNodes.removeLast();
          _pointNodes.add(_updatedLastNode);
          _pointNodes.add(_firstNode);

          // Update last user event for undo purpose
          _userEvents.add(UserEvent.appPoint);
        } else {
          if (_isTooClose(details.globalPosition)) {
            _showSnackBar("Too Close!!");
          } else {
            // add point node
            final node = PointNode(
              index: _pointNodes.length,
              position: details.globalPosition,
              lines: List.empty(growable: true),
            );

            if (_pointNodes.isNotEmpty) {
              final _lastNode = _pointNodes.last;
              final _updatedLastNode = _lastNode.copy(
                next: node,
              );

              _pointNodes.removeLast();
              _pointNodes.add(_updatedLastNode);
            }
            _pointNodes.add(node);

            // Update last user event for undo purpose
            _userEvents.add(UserEvent.appPoint);
          }
        }
        return;
      }

      // If polygon is drawn
      if (_startNode == null) {
        _startNode = _nodeByOffset(details.globalPosition);
        return;
      } else {
        _endNode = _nodeByOffset(details.globalPosition);

        // If startNode and endNode not equal to null
        if (_startNode != null && _endNode != null) {
          // if _start point and end point is same
          if (_startNode?.index == _endNode?.index) {
            _startNode = null;
            _endNode = null;
            return;
          }

          // If already connected
          if (_startNode!.isAlreadyConnected(_endNode!)) {
            _startNode = _endNode;
            _endNode = null;
            return;
          }

          // If line already drawn
          if (_pointNodes.isLineAlreadyDrawn(Line(_startNode!, _endNode!))) {
            _startNode = _endNode;
            _endNode = null;
            return;
          }

          // If line is intersecting other lines or polygon boundaries
          if (LineUtils.isIntersected(_startNode!, _endNode!, _pointNodes)) {
            _showSnackBar("Line is intersecting boundaries or another lines!");
            _endNode = null;
            return;
          }

          // If line is intersecting other lines or polygon boundaries
          if (LineUtils.isOutsidePolygon(
              Line(_startNode!, _endNode!), _pointNodes)) {
            _showSnackBar("Line is outside the polygon!");
            _endNode = null;
            return;
          }

          final _line = Line(_startNode!, _endNode!);

          _pointNodes.addLine(_startNode!, _line);
          _lines.add(_line);
          _endNode = null;
          _userEvents.add(UserEvent.addLine);
        }

        return;
      }
    });
  }

  /// Method to handle on undo floating button click
  void _handleUndoClick() {
    setState(() {
      /// if _startNode is selected
      if (_startNode != null) _startNode = null;

      if (_userEvents.isEmpty) return;

      if (_userEvents.last == UserEvent.appPoint) {
        if (_pointNodes.isNotEmpty) {
          _pointNodes.removeLast();
        }
      } else if (_userEvents.last == UserEvent.addLine) {
        if (_lines.isNotEmpty) {
          _pointNodes.removeLine(_lines.last);
          _lines.removeLast();
        }
      } else {
        if (kDebugMode) {
          print(
              "======[Unspecified User Event -> ${_userEvents.last.name}]=======");
        }
      }
      _userEvents.removeLast();
    });
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

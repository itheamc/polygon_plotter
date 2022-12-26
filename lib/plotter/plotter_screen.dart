import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polygon_plotter/plotter/controller/plotter_controller.dart';
import 'package:polygon_plotter/plotter/utils/extension_function.dart';
import 'package:polygon_plotter/plotter/utils/plotter_painter.dart';

class PlotterScreen extends StatefulWidget {
  const PlotterScreen({Key? key}) : super(key: key);

  @override
  State<PlotterScreen> createState() => _PlotterScreenState();
}

class _PlotterScreenState extends State<PlotterScreen> {
  /// Plotter Controller
  final _plotterController = Get.find<PlotterController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: _plotterController.handleUndoClick,
        child: const Icon(Icons.undo_outlined),
      ),
      body: GestureDetector(
        onTapDown: _plotterController.handleOnTapDown,
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Colors.white,
          child: GetBuilder<PlotterController>(
            builder: (controller) {
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Area is ${controller.listOfLines.triangles.cumulativeArea}",
                        style: Get.theme.textTheme.headlineLarge
                            ?.copyWith(color: Colors.black26),
                      ),
                    ),
                  ),
                  if (controller.isPolygonDrawn)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "Max possible triangles are ${!controller.isPolygonDrawn ? 0 : controller.points.maxPossibleTriangles}",
                          style: Get.theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.black26),
                        ),
                      ),
                    ),
                  CustomPaint(
                    painter: PlotterPainter(
                      controller.points,
                      lines: controller.listOfLines,
                      startingPoint: controller.start,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

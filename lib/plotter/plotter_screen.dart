import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polygon_plotter/plotter/utils/extension_function.dart';
import 'package:polygon_plotter/plotter/utils/plotter_painter.dart';
import 'package:screenshot/screenshot.dart';

import 'controller/plotter_controller.dart';

class PlotterScreen extends StatefulWidget {
  const PlotterScreen({Key? key}) : super(key: key);

  @override
  State<PlotterScreen> createState() => _PlotterScreenState();
}

class _PlotterScreenState extends State<PlotterScreen> {
  /// Plotter Controller
  final _plotterController = Get.find<PlotterController>();

  /// Screenshot controller
  final _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("जग्गा नाप्नुहोस्"),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            TextButton.icon(
              icon: const Icon(Icons.undo),
              label: const Text(
                "Undo",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: _plotterController.handleUndoClick,
            ),
            TextButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text(
                "Clear",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () {
                Get.defaultDialog(
                  title: "Clear Drawings",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  titlePadding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  content: const Text("Are you sure want to clear drawings?"),
                  actions: [
                    TextButton(
                      child: const Text("Dismiss"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text("Clear"),
                      onPressed: () {
                        Navigator.pop(context);
                        _plotterController.resetAll(updateUi: true);
                      },
                    ),
                  ],
                );
              },
            ),
            TextButton.icon(
              label: const Text(
                "Save",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              icon: const Icon(Icons.save),
              onPressed: () async {
                await _screenshotController
                    .capture(delay: const Duration(milliseconds: 10))
                    .then((Uint8List? image) async {
                  if (image != null) {
                    /// Share Plugin
                    Get.defaultDialog(
                      title: 'कोरिएको बहुभुजको चित्र',
                      titlePadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                      content: Image.memory(image),
                      actions: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: TextButton(
                              child: const Text("Dismiss"),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                });
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTapDown: _plotterController.handleOnTapDown,
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Colors.white,
          child: GetBuilder<PlotterController>(
            builder: (controller) {
              return Screenshot(
                controller: _screenshotController,
                child: Stack(
                  children: [
                    if (controller.points.isPolygonDrawn) ...[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "बहुभुजको क्षेत्रफल: ${controller.points.lines.triangles.cumulativeArea}",
                            style: Get.theme.textTheme.titleLarge
                                ?.copyWith(color: Colors.green),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Text(
                            "तपाईं अधिकतम ${!controller.points.isPolygonDrawn ? 0 : controller.points.maxPossibleTriangles} त्रिकोण बनाउन सक्नुहुन्छ।",
                            style: Get.theme.textTheme.titleMedium
                                ?.copyWith(color: Colors.black26),
                          ),
                        ),
                      ),
                    ],
                    CustomPaint(
                      painter: PlotterPainter(
                        controller.points,
                        startingPoint: controller.start,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _plotterController.resetAll();
    super.dispose();
  }
}

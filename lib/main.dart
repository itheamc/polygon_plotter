import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polygon_plotter/plotter/controller/plotter_controller.dart';
import 'package:polygon_plotter/plotter/plotter_screen.dart';

void main() {
  runApp(const PlotterApp());
}

class PlotterApp extends StatelessWidget {
  const PlotterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlotterScreen(),
      initialBinding: PlotterInitialBindings(),
    );
  }
}

/// Initial Bindings
class PlotterInitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlotterController>(() => PlotterController());
  }
}

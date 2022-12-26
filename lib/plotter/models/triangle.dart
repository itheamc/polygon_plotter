import 'dart:math' as math;
import 'line.dart';

/// Triangle data model class
class Triangle {
  final Line a;
  final Line b;
  final Line c;

  // Constructor
  Triangle(this.a, this.b, this.c);

  /// Method to check if two triangle are equal
  bool isSame(Triangle triangle) {
    final _temp = [a, b, c];

    return _temp.contains(triangle.a) &&
        _temp.contains(triangle.b) &&
        _temp.contains(triangle.c);
  }

  /// Method to calculate the area of the triangle
  double get area {
    // Area of Triangle with Three Sides (Heron’s Formula)
    // A^2 = (s(s-a)(s-b)(s-c))^2
    final area = math.sqrt(semiPerimeter *
        (semiPerimeter - a.distance) *
        (semiPerimeter - b.distance) *
        (semiPerimeter - c.distance));

    return double.parse(area.toStringAsFixed(3));
  }

  /// Method to validate triangle
  bool get isValid {
    return (a.distance + b.distance) > c.distance &&
        (a.distance + c.distance) > b.distance &&
        (b.distance + c.distance) > a.distance;
  }

  /// Method to calculate semi-perimeter
  double get semiPerimeter => (a.distance + b.distance + c.distance) / 2;
}

import '../models/line.dart';
import '../models/point_node.dart';

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

extension PointNodeListExt on List<PointNode> {
  // Method to remove line
  void removeLine(Line line) {
    for (final node in this) {
      if (node.lines.any((l) =>
          l.center.dx == line.center.dx && l.center.dy == line.center.dy)) {
        node.lines.remove(line);
        break;
      }
    }
  }

  // Method to add line
  void addLine(PointNode node, Line line) {
    for (final n in this) {
      if (n.index == node.index) {
        n.lines.add(line);
        break;
      }
    }
  }

  // Method to check if the line are already drawn
  bool isLineAlreadyDrawn(Line line) {
    for (final node in this) {
      if (node.lines.any((l) =>
          l.center.dx == line.center.dx && l.center.dy == line.center.dy)) {
        return true;
      }
    }

    return false;
  }
}

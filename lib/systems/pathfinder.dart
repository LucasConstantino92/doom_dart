import 'package:doom_dart/world/maze_map.dart';

class _Node {
  final int col;
  final int row;

  double g = 0;
  double h = 0;
  double get f => g + h;

  _Node? parent;

  _Node(this.col, this.row);

  @override
  bool operator ==(Object other) =>
      other is _Node && other.col == col && other.row == row;

  @override
  int get hashCode => Object.hash(col, row);
}

class Pathfinder {
  final MazeMap map;

  const Pathfinder({required this.map});

  List<(int, int)> findPath({
    required int startCol,
    required int startRow,
    required int endCol,
    required int endRow,
  }) {
    if (startCol == endCol && startRow == endRow) return [];

    if (map.isWall(endCol, endRow)) return [];

    final openSet = <_Node>[];
    final closedSet = <_Node>{};

    final start = _Node(startCol, startRow);
    start.h = _heuristic(startCol, startRow, endCol, endRow);
    openSet.add(start);

    while (openSet.isNotEmpty) {
      openSet.sort((a, b) => a.f.compareTo(b.f));
      final current = openSet.removeAt(0);

      if (current.col == endCol && current.row == endRow) {
        return _reconstructPath(current);
      }

      closedSet.add(current);

      for (final neighbor in _getNeighbors(current)) {
        if (closedSet.contains(neighbor)) continue;

        if (map.isWall(neighbor.col, neighbor.row)) continue;

        final tentativeG = current.g + 1;

        final existing = openSet.firstWhere(
          (n) => n == neighbor,
          orElse: () => _Node(-1, -1),
        );

        if (existing.col == -1) {
          neighbor.g = tentativeG;
          neighbor.h = _heuristic(neighbor.col, neighbor.row, endCol, endRow);
          neighbor.parent = current;
          openSet.add(neighbor);
        } else if (tentativeG < existing.g) {
          existing.g = tentativeG;
          existing.parent = current;
        }
      }
    }

    return [];
  }

  double _heuristic(int col, int row, int endCol, int endRow) {
    return (col - endCol).abs().toDouble() + (row - endRow).abs().toDouble();
  }

  List<_Node> _getNeighbors(_Node node) {
    return [
      _Node(node.col, node.row - 1),
      _Node(node.col, node.row + 1),
      _Node(node.col - 1, node.row),
      _Node(node.col + 1, node.row),
    ];
  }

  List<(int, int)> _reconstructPath(_Node end) {
    final path = <(int, int)>[];
    _Node? current = end;

    while (current != null) {
      path.add((current.col, current.row));
      current = current.parent;
    }

    return path.reversed.toList();
  }
}

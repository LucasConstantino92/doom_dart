import 'dart:math';
import 'maze_map.dart';

class MazeGenerator {
  final int cols;
  final int rows;
  final Random _random;

  late List<List<int>> _grid;

  MazeGenerator({
    required this.cols,
    required this.rows,
    int? seed,
  }) : _random = Random(seed);

  MazeMap generate() {
    final gridCols = (cols * 2) + 1;
    final gridRows = (rows * 2) + 1;

    _grid = List.generate(
      gridRows,
      (_) => List.filled(gridCols, 1),
    );

    final visited = List.generate(
      rows,
      (_) => List.filled(cols, false),
    );
    _dfs(0, 0, visited);

    return MazeMap(
      grid: _grid,
      cols: gridCols,
      rows: gridRows,
    );
  }

  void _dfs(int col, int row, List<List<bool>> visited) {
    visited[row][col] = true;

    final gridCol = col * 2 + 1;
    final gridRow = row * 2 + 1;

    _grid[gridRow][gridCol] = 0;

    final neighbors = [
      [0, -1],
      [0, 1],
      [-1, 0],
      [1, 0],
    ];
    neighbors.shuffle(_random);

    for (final neighbor in neighbors) {
      final nextCol = col + neighbor[0];
      final nextRow = row + neighbor[1];

      final inBounds =
          nextCol >= 0 && nextRow >= 0 && nextCol < cols && nextRow < rows;

      if (!inBounds) continue;
      if (visited[nextRow][nextCol]) continue;

      final wallCol = gridCol + neighbor[0];
      final wallRow = gridRow + neighbor[1];
      _grid[wallRow][wallCol] = 0;
      _dfs(nextCol, nextRow, visited);
    }
  }
}

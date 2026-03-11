class MazeMap {
  final List<List<int>> grid;

  final int cols;
  final int rows;

  final double cellSize;

  const MazeMap({
    required this.grid,
    required this.cols,
    required this.rows,
    this.cellSize = 48,
  });

  bool isWall(int col, int row) {
    if (col < 0 || row < 0 || col >= cols || row >= rows) return true;
    return grid[row][col] == 1;
  }

  int pixelToCol(double x) => (x / cellSize).floor();
  int pixelToRow(double y) => (y / cellSize).floor();

  static MazeMap simple() {
    return MazeMap(
      cols: 10,
      rows: 10,
      grid: [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
        [1, 0, 1, 0, 1, 0, 1, 1, 0, 1],
        [1, 0, 1, 0, 0, 0, 0, 1, 0, 1],
        [1, 0, 1, 1, 1, 1, 0, 1, 0, 1],
        [1, 0, 0, 0, 0, 1, 0, 0, 0, 1],
        [1, 1, 1, 0, 1, 1, 1, 1, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
        [1, 0, 1, 1, 1, 1, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      ],
    );
  }
}

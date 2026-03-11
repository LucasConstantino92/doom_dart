import 'dart:ui';
import 'package:flame/components.dart';

import 'maze_map.dart';

class MapRenderer extends Component {
  final MazeMap map;

  final Paint _wallPaint = Paint()..color = const Color(0xFF444466);
  final Paint _floorPaint = Paint()..color = const Color(0xFF1a1a2e);
  final Paint _gridPaint = Paint()
    ..color = const Color(0xFF222233)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  MapRenderer({required this.map});

  @override
  void render(Canvas canvas) {
    final cs = map.cellSize;

    for (int row = 0; row < map.rows; row++) {
      for (int col = 0; col < map.cols; col++) {
        final rect = Rect.fromLTWH(
          col * cs,
          row * cs,
          cs,
          cs,
        );

        canvas.drawRect(
          rect,
          map.isWall(col, row) ? _wallPaint : _floorPaint,
        );

        canvas.drawRect(rect, _gridPaint);
      }
    }
  }
}

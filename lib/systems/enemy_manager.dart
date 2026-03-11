import 'dart:math';

import 'package:doom_dart/components/enemy.dart';
import 'package:doom_dart/components/player.dart';
import 'package:doom_dart/world/maze_map.dart';

class EnemyManager {
  final MazeMap map;
  final List<Enemy> enemies = [];
  final Random _random;

  EnemyManager({required this.map, int? seed}) : _random = Random(seed);

  void spawnEnemies({
    required int count,
    required double playerX,
    required double playerY,
  }) {
    final cs = map.cellSize;
    const minDistCells = 4.0;

    final floorCells = <(int, int)>[];
    for (int row = 0; row < map.rows; row++) {
      for (int col = 0; col < map.cols; col++) {
        if (!map.isWall(col, row)) {
          floorCells.add((col, row));
        }
      }
    }

    floorCells.shuffle(_random);

    int spawned = 0;
    for (final cell in floorCells) {
      if (spawned >= count) break;

      final (col, row) = cell;

      final cx = (col + 0.5) * cs;
      final cy = (row + 0.5) * cs;

      final dist = sqrt(
        pow((cx - playerX) / cs, 2) + pow((cy - playerY) / cs, 2),
      );

      if (dist < minDistCells) continue;

      enemies.add(Enemy(map: map, x: cx, y: cy));
      spawned++;
    }
  }

  void update(double dt, Player player) {
    for (final enemy in enemies) {
      enemy.update(dt, player);
    }
  }
}

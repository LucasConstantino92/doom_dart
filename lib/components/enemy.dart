import 'dart:math';

import 'package:doom_dart/components/player.dart';
import 'package:doom_dart/systems/pathfinder.dart';
import 'package:doom_dart/world/maze_map.dart';

enum EnemyState { idle, chase, lost }

class Enemy {
  static const double _sightRadius = 8.0;
  static const double _lostTimeout = 3.0;
  static const double _speed = 80.0;
  static const double _pathRefresh = 0.5;

  final MazeMap map;
  final Pathfinder _pathfinder;

  double x;
  double y;

  EnemyState state = EnemyState.idle;
  double _lostTimer = 0;
  double _pathTimer = 0;
  List<(int, int)> _path = [];
  int _pathIndex = 0;

  Enemy({required this.map, required this.x, required this.y})
      : _pathfinder = Pathfinder(map: map);

  void update(double dt, Player player) {
    final canSee = _hasLineOfSight(player);

    switch (state) {
      case EnemyState.idle:
        if (canSee) {
          state = EnemyState.chase;
          _recalculatePath(player);
        }

      case EnemyState.chase:
        if (!canSee) {
          state = EnemyState.lost;
          _lostTimer = 0;
        } else {
          _pathTimer += dt;
          if (_pathTimer >= _pathRefresh) {
            _pathTimer = 0;
            _recalculatePath(player);
          }
          _followPath(dt);
        }

      case EnemyState.lost:
        _lostTimer += dt;
        if (canSee) {
          state = EnemyState.chase;
          _recalculatePath(player);
        } else if (_lostTimer >= _lostTimeout) {
          state = EnemyState.idle;
          _path = [];
        }
    }
  }

  void _recalculatePath(Player player) {
    _path = _pathfinder.findPath(
      startCol: map.pixelToCol(x),
      startRow: map.pixelToRow(y),
      endCol: map.pixelToCol(player.x),
      endRow: map.pixelToRow(player.y),
    );
    _pathIndex = 0;
  }

  void _followPath(double dt) {
    if (_path.isEmpty || _pathIndex >= _path.length) return;

    final (targetCol, targetRow) = _path[_pathIndex];

    final targetX = (targetCol + 0.5) * map.cellSize;
    final targetY = (targetRow + 0.5) * map.cellSize;

    final dx = targetX - x;
    final dy = targetY - y;
    final len = sqrt(dx * dx + dy * dy);

    final threshold = map.cellSize * 0.5;
    if (len < threshold) {
      _pathIndex++;
      return;
    }

    x += (dx / len) * _speed * dt;
    y += (dy / len) * _speed * dt;
  }

  bool _hasLineOfSight(Player player) {
    final cs = map.cellSize;
    final ex = x / cs;
    final ey = y / cs;
    final px = player.x / cs;
    final py = player.y / cs;

    final dist = sqrt(pow(px - ex, 2) + pow(py - ey, 2));
    if (dist > _sightRadius) return false;

    final steps = (dist * 2).ceil().clamp(4, 64);
    for (int i = 1; i < steps; i++) {
      final t = i / steps;
      final cx = ex + (px - ex) * t;
      final cy = ey + (py - ey) * t;
      if (map.isWall(cx.floor(), cy.floor())) return false;
    }

    return true;
  }

  List<(int, int)> get debugPath => _path;
}

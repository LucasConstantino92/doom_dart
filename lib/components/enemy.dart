import 'dart:math';

import 'package:doom_dart/components/player.dart';
import 'package:doom_dart/world/maze_map.dart';

enum EnemyState { idle, chase, lost }

class Enemy {
  static const double _sightRadius = 8.0;
  static const double _lostTimeout = 3.0;
  static const double _speed = 80.0;

  final MazeMap map;

  double x;
  double y;

  EnemyState state = EnemyState.idle;

  double _lostTimer = 0;

  List<(int, int)> path = [];

  Enemy({
    required this.map,
    required this.x,
    required this.y,
  });

  void update(double dt, Player player) {
    final canSee = _hasLineOfSight(player);

    switch (state) {
      case EnemyState.idle:
        if (canSee) {
          state = EnemyState.chase;
        }

      case EnemyState.chase:
        if (!canSee) {
          state = EnemyState.lost;
          _lostTimer = 0;
        } else {
          _moveTowards(player.x, player.y, dt);
        }

      case EnemyState.lost:
        _lostTimer += dt;
        if (canSee) {
          state = EnemyState.chase;
        } else if (_lostTimer >= _lostTimeout) {
          state = EnemyState.idle;
        }
    }
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

  void _moveTowards(double targetX, double targetY, double dt) {
    final dx = targetX - x;
    final dy = targetY - y;
    final len = sqrt(dx * dx + dy * dy);

    if (len < 1) return;

    final prevX = x;
    final prevY = y;

    x += (dx / len) * _speed * dt;
    y += (dy / len) * _speed * dt;

    if (map.isWall(map.pixelToCol(x), map.pixelToRow(y))) {
      x = prevX;
      if (map.isWall(map.pixelToCol(x), map.pixelToRow(y))) {
        y = prevY;
      }
    }
  }
}

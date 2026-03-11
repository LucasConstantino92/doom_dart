import 'dart:math';

import 'package:doom_dart/components/enemy.dart';
import 'package:doom_dart/components/player.dart';
import 'package:doom_dart/world/maze_map.dart';

enum ShotResult { missed, hit }

class CombatSystem {
  final MazeMap map;

  static const double _shotRange = 12.0;
  static const double _meleeRange = 40.0;
  static const double _shotDamage = 34.0;
  static const double _meleeDamage = 10.0;

  ShotResult lastShotResult = ShotResult.missed;

  CombatSystem({required this.map});

  ShotResult shoot({
    required Player player,
    required List<Enemy> enemies,
  }) {
    final cs = map.cellSize;

    final px = player.x / cs;
    final py = player.y / cs;

    final dirX = cos(player.angle);
    final dirY = sin(player.angle);
    const stepSize = 0.1;
    final maxSteps = (_shotRange / stepSize).ceil();

    for (int i = 1; i <= maxSteps; i++) {
      final dist = i * stepSize;
      final cx = px + dirX * dist;
      final cy = py + dirY * dist;

      if (map.isWall(cx.floor(), cy.floor())) {
        lastShotResult = ShotResult.missed;
        return ShotResult.missed;
      }

      final hitRadius = cs * 0.5;
      for (final enemy in enemies) {
        final ex = enemy.x / cs;
        final ey = enemy.y / cs;
        final d = sqrt(pow(cx - ex, 2) + pow(cy - ey, 2));

        if (d < hitRadius / cs) {
          enemy.takeDamage(_shotDamage);
          lastShotResult = ShotResult.hit;
          return ShotResult.hit;
        }
      }
    }

    lastShotResult = ShotResult.missed;
    return ShotResult.missed;
  }

  void updateMelee({
    required Player player,
    required List<Enemy> enemies,
    required double dt,
  }) {
    for (final enemy in enemies) {
      if (enemy.state != EnemyState.chase) continue;

      final dx = enemy.x - player.x;
      final dy = enemy.y - player.y;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < _meleeRange) {
        player.takeDamage(_meleeDamage * dt);
      }
    }
  }
}

import 'dart:math';
import 'dart:ui';
import 'package:doom_dart/components/enemy.dart';
import 'package:doom_dart/components/player.dart';
import 'package:doom_dart/systems/enemy_manager.dart';
import 'package:doom_dart/world/maze_map.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'raycaster.dart';

class GameRenderer extends Component with HasGameReference<FlameGame> {
  final Player player;
  final Raycaster raycaster;
  final EnemyManager enemyManager;
  final MazeMap map;

  final Paint _ceilingPaint = Paint()..color = const Color(0xFF1a1a2e);
  final Paint _floorPaint = Paint()..color = const Color(0xFF16213e);
  final Paint _wallPaint = Paint()..color = const Color(0xFF4444AA);
  final Paint _wallDarkPaint = Paint()..color = const Color(0xFF2a2a66);
  final Paint _enemyActivePaint = Paint()..color = const Color(0xFFFF0000);
  final Paint _enemyIdlePaint = Paint()..color = const Color(0xFF888888);

  GameRenderer({
    required this.player,
    required this.raycaster,
    required this.enemyManager,
    required this.map,
  });

  @override
  void render(Canvas canvas) {
    final width = game.size.x;
    final height = game.size.y;
    final halfH = height / 2;

    canvas.drawRect(Rect.fromLTWH(0, 0, width, halfH), _ceilingPaint);
    canvas.drawRect(Rect.fromLTWH(0, halfH, width, halfH), _floorPaint);

    final hits = raycaster.cast(
      playerX: player.x,
      playerY: player.y,
      playerAngle: player.angle,
      screenWidth: width.toInt(),
    );

    for (int col = 0; col < hits.length; col++) {
      final hit = hits[col];
      final sliceHeight = (height * 0.8) / hit.distance;
      final top = (halfH - sliceHeight / 2).clamp(0.0, height);
      final bottom = (halfH + sliceHeight / 2).clamp(0.0, height);
      canvas.drawRect(
        Rect.fromLTWH(col.toDouble(), top, 1, bottom - top),
        hit.hitNS ? _wallDarkPaint : _wallPaint,
      );
    }

    _renderEnemies(canvas, hits, width, height, halfH);
  }

  void _renderEnemies(
    Canvas canvas,
    List<RayHit> hits,
    double width,
    double height,
    double halfH,
  ) {
    for (final enemy in enemyManager.enemies) {
      final dx = enemy.x - player.x;
      final dy = enemy.y - player.y;
      final dist = sqrt(dx * dx + dy * dy) / map.cellSize;

      if (dist < 0.1) continue;

      var angleDiff = atan2(dy, dx) - player.angle;

      while (angleDiff > pi) angleDiff -= 2 * pi;
      while (angleDiff < -pi) angleDiff += 2 * pi;

      if (angleDiff.abs() > Raycaster.fov / 2) continue;

      final screenCol = ((angleDiff / Raycaster.fov + 0.5) * width)
          .toInt()
          .clamp(0, width.toInt() - 1);

      final wallDist = hits[screenCol].distance;
      if (dist >= wallDist) continue;

      final spriteH = (height * 0.6) / dist;
      final spriteW = spriteH * 0.6;
      final top = halfH - spriteH / 2;
      final left = screenCol - spriteW / 2;

      final paint =
          enemy.state == EnemyState.idle ? _enemyIdlePaint : _enemyActivePaint;

      canvas.drawRect(Rect.fromLTWH(left, top, spriteW, spriteH), paint);
    }
  }
}

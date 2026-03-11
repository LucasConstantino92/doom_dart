import 'dart:math';
import 'dart:ui';

import 'package:doom_dart/world/maze_map.dart';

class Player {
  static const double _speed = 150.0;
  static const double _rotSpeed = 2.5;
  static const double _size = 20.0;
  static const double maxHp = 100.0;

  final MazeMap map;

  double x;
  double y;
  double angle;
  double hp = maxHp;

  bool movingForward = false;
  bool movingBackward = false;
  bool turningLeft = false;
  bool turningRight = false;

  double damageFlash = 0.0;

  double hitFlash = 0.0;

  bool get isDead => hp <= 0;

  Player({required this.map})
      : x = 1.5 * map.cellSize,
        y = 1.5 * map.cellSize,
        angle = 0;

  void takeDamage(double amount) {
    if (isDead) return;
    hp = (hp - amount).clamp(0, maxHp);
    damageFlash = 1.0;
  }

  void onHitEnemy() {
    hitFlash = 1.0;
  }

  void update(double dt) {
    if (turningLeft) angle -= _rotSpeed * dt;
    if (turningRight) angle += _rotSpeed * dt;
    angle = angle % (2 * pi);

    if (!isDead) {
      final dx = cos(angle) * _speed * dt;
      final dy = sin(angle) * _speed * dt;

      final prevX = x;
      final prevY = y;

      if (movingForward) {
        x += dx;
        y += dy;
      }
      if (movingBackward) {
        x -= dx;
        y -= dy;
      }

      if (map.isWall(map.pixelToCol(x), map.pixelToRow(y))) {
        x = prevX;
        if (map.isWall(map.pixelToCol(x), map.pixelToRow(y))) {
          y = prevY;
        }
      }
    }

    damageFlash = (damageFlash - dt * 3.0).clamp(0.0, 1.0);
    hitFlash = (hitFlash - dt * 6.0).clamp(0.0, 1.0);
  }

  void renderDebug(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFFF4400);
    canvas.drawCircle(Offset(x, y), _size / 2, paint);
    final linePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 2.5;
    canvas.drawLine(
      Offset(x, y),
      Offset(x + cos(angle) * _size, y + sin(angle) * _size),
      linePaint,
    );
  }
}

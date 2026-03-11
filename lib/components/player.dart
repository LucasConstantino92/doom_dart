import 'dart:math';
import 'dart:ui';
import 'package:doom_dart/renderer/maze_map.dart';
import 'package:flame/components.dart';

import '../game/doom_game.dart';

class Player extends PositionComponent with HasGameReference<DoomGame> {
  static const double _speed = 150.0;
  static const double _rotSpeed = 2.5;
  static const double _size = 20.0;

  final MazeMap map;

  bool movingForward = false;
  bool movingBackward = false;
  bool turningLeft = false;
  bool turningRight = false;
  double angle = 0;

  Player({required this.map})
      : super(
          anchor: Anchor.center,
          size: Vector2.all(_size),
        );

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    if (position == Vector2.zero()) {
      position = Vector2(
        1.5 * map.cellSize,
        1.5 * map.cellSize,
      );
    }
  }

  @override
  void update(double dt) {
    if (turningLeft) angle -= _rotSpeed * dt;
    if (turningRight) angle += _rotSpeed * dt;

    angle = angle % (2 * pi);

    final dx = cos(angle) * _speed * dt;
    final dy = sin(angle) * _speed * dt;

    final prevX = position.x;
    final prevY = position.y;

    if (movingForward) {
      position.x += dx;
      position.y += dy;
    }
    if (movingBackward) {
      position.x -= dx;
      position.y -= dy;
    }

    final col = map.pixelToCol(position.x);
    final row = map.pixelToRow(position.y);

    if (map.isWall(col, row)) {
      position.x = prevX;
      final col2 = map.pixelToCol(position.x);
      final row2 = map.pixelToRow(position.y);
      if (map.isWall(col2, row2)) {
        position.y = prevY;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFFF4400);
    canvas.drawCircle(
      Offset(_size / 2, _size / 2),
      _size / 2,
      paint,
    );
    final linePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 2.5;

    final center = Offset(_size / 2, _size / 2);

    final tip = Offset(
      center.dx + cos(angle) * (_size / 2),
      center.dy + sin(angle) * (_size / 2),
    );

    canvas.drawLine(center, tip, linePaint);
  }
}

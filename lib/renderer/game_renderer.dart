import 'dart:ui';
import 'package:doom_dart/components/player.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'raycaster.dart';

class GameRenderer extends Component with HasGameReference<FlameGame> {
  final Player player;
  final Raycaster raycaster;

  final Paint _ceilingPaint = Paint()..color = const Color(0xFF1a1a2e);
  final Paint _floorPaint = Paint()..color = const Color(0xFF16213e);
  final Paint _wallPaint = Paint()..color = const Color(0xFF4444AA);
  final Paint _wallDarkPaint = Paint()..color = const Color(0xFF2a2a66);

  GameRenderer({required this.player, required this.raycaster});

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
      final paint = hit.hitNS ? _wallDarkPaint : _wallPaint;

      canvas.drawRect(
        Rect.fromLTWH(col.toDouble(), top, 1, bottom - top),
        paint,
      );
    }
  }
}

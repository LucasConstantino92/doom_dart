import 'dart:math';
import '../world/maze_map.dart';

class RayHit {
  final double distance;
  final bool hitNS;

  const RayHit({required this.distance, required this.hitNS});
}

class Raycaster {
  final MazeMap map;

  static const double fov = pi / 3;

  const Raycaster({required this.map});

  List<RayHit> cast({
    required double playerX,
    required double playerY,
    required double playerAngle,
    required int screenWidth,
  }) {
    final hits = <RayHit>[];

    final posX = playerX / map.cellSize;
    final posY = playerY / map.cellSize;

    for (int col = 0; col < screenWidth; col++) {
      final rayAngle = playerAngle - (fov / 2) + (col / screenWidth) * fov;

      final rayDirX = cos(rayAngle);
      final rayDirY = sin(rayAngle);

      int mapCol = posX.floor();
      int mapRow = posY.floor();

      final deltaDistX = rayDirX.abs() < 1e-10 ? 1e10 : (1 / rayDirX).abs();
      final deltaDistY = rayDirY.abs() < 1e-10 ? 1e10 : (1 / rayDirY).abs();

      int stepCol;
      int stepRow;

      double sideDistX;
      double sideDistY;

      if (rayDirX < 0) {
        stepCol = -1;
        sideDistX = (posX - mapCol) * deltaDistX;
      } else {
        stepCol = 1;
        sideDistX = (mapCol + 1.0 - posX) * deltaDistX;
      }

      if (rayDirY < 0) {
        stepRow = -1;
        sideDistY = (posY - mapRow) * deltaDistY;
      } else {
        stepRow = 1;
        sideDistY = (mapRow + 1.0 - posY) * deltaDistY;
      }

      bool hitNS = false;
      bool hit = false;

      while (!hit) {
        if (sideDistX < sideDistY) {
          sideDistX += deltaDistX;
          mapCol += stepCol;
          hitNS = false;
        } else {
          sideDistY += deltaDistY;
          mapRow += stepRow;
          hitNS = true;
        }

        if (map.isWall(mapCol, mapRow)) hit = true;
      }

      final perpDist = hitNS ? sideDistY - deltaDistY : sideDistX - deltaDistX;

      hits.add(RayHit(
        distance: perpDist.clamp(0.01, double.infinity),
        hitNS: hitNS,
      ));
    }

    return hits;
  }
}

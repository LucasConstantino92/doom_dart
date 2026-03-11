import 'package:doom_dart/components/player.dart';
import 'package:doom_dart/renderer/game_renderer.dart';
import 'package:doom_dart/renderer/raycaster.dart';
import 'package:doom_dart/systems/enemy_manager.dart';
import 'package:doom_dart/world/maze_generator.dart';
import 'package:doom_dart/world/maze_map.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoomGame extends FlameGame with KeyboardEvents {
  late final Player player;
  late final MazeMap map;
  late final Raycaster raycaster;
  late final GameRenderer renderer;
  late final EnemyManager enemyManager;

  late final JoystickComponent _joystickLeft;
  late final JoystickComponent _joystickRight;

  bool _keyForward = false;
  bool _keyBackward = false;
  bool _keyLeft = false;
  bool _keyRight = false;

  @override
  Future<void> onLoad() async {
    map = MazeGenerator(cols: 8, rows: 8).generate();
    player = Player(map: map);

    enemyManager = EnemyManager(map: map);
    enemyManager.spawnEnemies(
      count: 5,
      playerX: player.x,
      playerY: player.y,
    );

    raycaster = Raycaster(map: map);
    renderer = GameRenderer(
      player: player,
      raycaster: raycaster,
      enemyManager: enemyManager,
      map: map,
    );

    add(renderer);
    _setupJoysticks();
  }

  void _setupJoysticks() {
    _joystickLeft = JoystickComponent(
      knob: CircleComponent(
        radius: 24,
        paint: Paint()..color = const Color(0xCCFFFFFF),
      ),
      background: CircleComponent(
        radius: 56,
        paint: Paint()..color = const Color(0x55FFFFFF),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
      anchor: Anchor.bottomLeft,
    );
    add(_joystickLeft);

    _joystickRight = JoystickComponent(
      knob: CircleComponent(
        radius: 24,
        paint: Paint()..color = const Color(0xCCFF4400),
      ),
      background: CircleComponent(
        radius: 56,
        paint: Paint()..color = const Color(0x55FF4400),
      ),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      anchor: Anchor.bottomRight,
    );
    add(_joystickRight);
  }

  @override
  void update(double dt) {
    super.update(dt);

    const deadZone = 0.2;
    final ly = _joystickLeft.relativeDelta.y;
    final rx = _joystickRight.relativeDelta.x;

    player.movingForward = _keyForward || ly < -deadZone;
    player.movingBackward = _keyBackward || ly > deadZone;
    player.turningLeft = _keyLeft || rx < -deadZone;
    player.turningRight = _keyRight || rx > deadZone;

    player.update(dt);
    enemyManager.update(dt, player);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    _keyForward = keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);
    _keyBackward = keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);
    _keyLeft = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    _keyRight = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    return KeyEventResult.handled;
  }
}

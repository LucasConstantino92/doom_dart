import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/doom_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GameWidget(game: DoomGame()));
}

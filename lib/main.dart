import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game.dart';
import 'overlays.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bloquear orientación a landscape
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const EcoNegroApp());
}

class EcoNegroApp extends StatelessWidget {
  const EcoNegroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Negro: Proyecto Casandra',
      theme: ThemeData.dark(),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final EcoNegroGame game;

  @override
  void initState() {
    super.initState();
    game = EcoNegroGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'HUD': (context, game) => HUDOverlay(game: game as EcoNegroGame),
          'Pause': (context, game) => PauseMenu(game: game as EcoNegroGame),
          'Victory': (context, game) => VictoryScreen(game: game as EcoNegroGame),
          'GameOver': (context, game) => GameOverScreen(game: game as EcoNegroGame),
          'Intro': (context, game) => IntroScreen(game: game as EcoNegroGame),
          'MainMenu': (context, game) => MainMenuScreen(game: game as EcoNegroGame),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    );
  }
}

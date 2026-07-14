import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'game/megamania_game.dart';
import 'widgets/hud.dart';
import 'widgets/game_over_overlay.dart';
import 'widgets/leaderboard_screen.dart';
import 'widgets/main_menu_overlay.dart';
import 'widgets/pause_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Constrain device configuration for high performance gameplay
  try {
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();
  } catch (e) {
    // Graceful catch for platforms that don't support landscape constraints (like standard web desktop)
  }

  // Attempt to initialize Supabase. Safe-fallback is implemented to allow
  // local offline gameplay if environment variables are not supplied.
  const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gazhrusbfzkxtwdkardn.supabase.co', // Defaults to project sandbox or user domain
  );
  const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder_key',
  );

  try {
    if (supabaseUrl != 'https://placeholder.supabase.co' && supabaseAnonKey != 'placeholder_key') {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    }
  } catch (e) {
    // If Supabase init fails, SupabaseService will fail gracefully without interrupting the game
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(const MegamaniaApp());
}

class MegamaniaApp extends StatelessWidget {
  const MegamaniaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: MaterialApp(
        title: 'Megamania Modern Remake',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const GameContainer(),
      ),
    );
  }
}

class GameContainer extends StatefulWidget {
  const GameContainer({Key? key}) : super(key: key);

  @override
  State<GameContainer> createState() => _GameContainerState();
}

class _GameContainerState extends State<GameContainer> {
  late final MegamaniaGame _game;

  @override
  void initState() {
    super.initState();
    _game = MegamaniaGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Listener(
        onPointerHover: (event) {
          if (event.kind == PointerDeviceKind.mouse) {
            _game.handleMousePosition(event.localPosition.dx);
          }
        },
        onPointerMove: (event) {
          if (event.kind == PointerDeviceKind.mouse) {
            _game.handleMousePosition(event.localPosition.dx);
          }
        },
        onPointerDown: (event) {
          if (event.kind == PointerDeviceKind.mouse) {
            _game.handleMouseClick(true);
          }
        },
        onPointerUp: (event) {
          if (event.kind == PointerDeviceKind.mouse) {
            _game.handleMouseClick(false);
          }
        },
        child: GameWidget<MegamaniaGame>(
          game: _game,
          // Start in the Main Menu overlay
          initialActiveOverlays: const ['MainMenu'],
          overlayBuilderMap: {
            'MainMenu': (context, game) => MainMenuOverlay(game: game),
            'HUD': (context, game) => HUD(game: game),
            'GameOver': (context, game) => GameOverOverlay(game: game),
            'Leaderboard': (context, game) => LeaderboardScreen(game: game),
            'Pause': (context, game) => PauseOverlay(game: game),
          },
        ),
      ),
    );
  }
}

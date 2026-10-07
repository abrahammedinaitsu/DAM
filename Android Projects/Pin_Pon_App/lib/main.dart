// main.dart
// Punto de entrada de Pin-Pon App (Flutter + Flame).
// Configura la orientacion permitida, crea el juego y monta el GameWidget
// con todos los overlays (menu, dificultad, retos, HUD, pausa y fin).
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/pon_game.dart';
import 'ui/dificultad_overlay.dart';
import 'ui/fin_overlay.dart';
import 'ui/hud_overlay.dart';
import 'ui/menu_overlay.dart';
import 'ui/pausa_overlay.dart';
import 'ui/retos_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Se permiten orientaciones de retrato y apaisado.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(PinPonApp(juego: PinPonGame()));
}

/// Widget raiz de la aplicacion.
class PinPonApp extends StatefulWidget {
  const PinPonApp({super.key, required this.juego});

  /// Instancia unica del juego (se inyecta para poder probarlo en tests).
  final PinPonGame juego;

  @override
  State<PinPonApp> createState() => _PinPonAppState();
}

class _PinPonAppState extends State<PinPonApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pin-Pon',
      debugShowCheckedModeBanner: false,
      // Tema oscuro con acento indigo.
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF0B1020),
        body: GameWidget<PinPonGame>(
          game: widget.juego,
          // Al arrancar solo se muestra el menu.
          initialActiveOverlays: const [PinPonGame.menu],
          // Cada overlay se enlaza con el juego para poder llamar sus metodos.
          overlayBuilderMap: {
            PinPonGame.menu: (_, juego) => MenuOverlay(juego: juego),
            PinPonGame.dificultad: (_, juego) =>
                DificultadOverlay(juego: juego),
            PinPonGame.retos: (_, juego) => RetosOverlay(juego: juego),
            PinPonGame.hud: (_, juego) => HudOverlay(juego: juego),
            PinPonGame.pausa: (_, juego) => PausaOverlay(juego: juego),
            PinPonGame.fin: (_, juego) => FinOverlay(juego: juego),
          },
        ),
      ),
    );
  }
}
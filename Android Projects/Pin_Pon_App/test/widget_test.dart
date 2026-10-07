// widget_test.dart
// Pruebas de widget de Pin-Pon App: arranque en el menu, navegacion a
// dificultad y partida, servicio de la pelota, pausa, fin de partida y
// apertura de retos.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pin_pon_app/game/config.dart';
import 'package:pin_pon_app/game/pon_game.dart';
import 'package:pin_pon_app/main.dart';

/// Monta la app con una instancia de juego para poder inspeccionarla.
Future<PinPonGame> _arrancar(WidgetTester tester) async {
  final juego = PinPonGame();
  await tester.pumpWidget(PinPonApp(juego: juego));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return juego;
}

/// Avanza el reloj de prueba varios frames.
Future<void> _avanzar(WidgetTester tester, int frames) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('la app arranca en el menu principal', (tester) async {
    await _arrancar(tester);

    expect(find.text('PIN-PON'), findsOneWidget);
    expect(find.text('Jugar contra la IA'), findsOneWidget);
  });

  testWidgets('navega de menu a dificultad y luego a la partida',
      (tester) async {
    final juego = await _arrancar(tester);

    await tester.tap(find.text('Jugar contra la IA'));
    await tester.pump();

    expect(find.text('ELIGE DIFICULTAD'), findsOneWidget);

    await tester.tap(find.text('Medio'));
    await tester.pump();

    expect(juego.estado, EstadoJuego.jugando);
    expect(find.textContaining('J1 0  -  0 J2'), findsOneWidget);
    expect(find.byIcon(Icons.pause_circle), findsOneWidget);
  });

  testWidgets('la pelota se pone en juego tras el servicio', (tester) async {
    final juego = await _arrancar(tester);

    await tester.tap(find.text('Jugar contra la IA'));
    await tester.pump();
    await tester.tap(find.text('Medio'));
    await tester.pump();

    // Durante el servicio la pelota no se ha movido.
    expect(juego.pelota!.x, GameConfig.inicioPelota);

    await _avanzar(tester, 30);

    // Pasado el servicio, la pelota ya avanzo.
    expect(juego.pelota!.x, isNot(GameConfig.inicioPelota));
  });

  testWidgets('la pausa detiene la partida y se puede reanudar',
      (tester) async {
    final juego = await _arrancar(tester);

    await tester.tap(find.text('Jugar contra la IA'));
    await tester.pump();
    await tester.tap(find.text('Medio'));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.pause_circle));
    await tester.pump();

    expect(juego.estado, EstadoJuego.pausa);
    expect(find.text('PAUSA'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(juego.estado, EstadoJuego.jugando);
    expect(find.text('PAUSA'), findsNothing);
  });

  testWidgets('muestra la pantalla de fin y permite repetir', (tester) async {
    final juego = await _arrancar(tester);

    await tester.tap(find.text('Jugar contra la IA'));
    await tester.pump();
    await tester.tap(find.text('Dificil'));
    await tester.pump();

    juego.terminarPartida('Victoria de la IA!  Marcador: 3 - 10');
    await tester.pump();

    expect(find.text('Victoria de la IA!  Marcador: 3 - 10'), findsOneWidget);

    await tester.tap(find.text('Jugar de nuevo'));
    await tester.pump();

    expect(juego.estado, EstadoJuego.jugando);
    expect(juego.puntos1, 0);
    expect(juego.puntos2, 0);
  });

  testWidgets('los retos se abren desde el menu y arrancan la partida',
      (tester) async {
    final juego = await _arrancar(tester);

    await tester.tap(find.text('Retos'));
    await tester.pump();

    expect(find.text('RETOS'), findsOneWidget);
    expect(find.text('Calentamiento'), findsOneWidget);

    await tester.tap(find.text('Calentamiento'));
    await tester.pump();

    expect(juego.estado, EstadoJuego.jugando);
    expect(juego.modo, ModoJuego.reto);
  });
}
// ai.dart
// Inteligencia artificial simple para el jugador 2 en modo "Vs IA" o "Retos".
// La IA solo reacciona cuando la pelota se acerca a su lado y persigue la
// posicion de la pelota con un margen de error configurable.
import 'dart:math' as math;

import 'entities.dart';
import 'game_config.dart';

/// Controlador automatico de una paleta.
class IA {
  final math.Random _azar = math.Random();

  /// Mueve [paleta] para seguir a [pelota] segun la [config] de dificultad.
  void mover(Paleta paleta, Pelota pelota, ConfigDificultad config, double dt) {
    // Solo persigue la pelota cuando viene hacia su lado.
    final umbral = GameConfig.ancho * config.umbralReaccionIA;
    if (pelota.dx <= 0 || pelota.x < umbral) {
      return;
    }

    final centro = paleta.centro;
    // A la pelota se le suma un error aleatorio para que la IA no sea perfecta.
    final objetivo = pelota.y + _desviacion(config.margenErrorIA);
    final pasos = config.velocidadIA * GameConfig.factorIA;

    if (objetivo < centro - 0.5) {
      paleta.moverArriba(pasos: pasos, dt: dt);
    } else if (objetivo > centro + 0.5) {
      paleta.moverAbajo(
        pasos: pasos,
        dt: dt,
        limiteInferior: GameConfig.alto,
      );
    }
  }

  /// Desviacion aleatoria dentro de [-margen, margen]; 0 si no hay error.
  double _desviacion(double margen) {
    if (margen <= 0) {
      return 0;
    }
    return _azar.nextDouble() * margen * 2 - margen;
  }
}
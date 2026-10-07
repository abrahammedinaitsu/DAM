// ai.dart
// Inteligencia artificial del jugador 2 en modo "Vs IA" o "Retos".
// Reacciona solo cuando la pelota se acerca a su lado y persigue su
// posicion con un margen de error configurable por dificultad.
import 'dart:math' as math;

import 'config.dart';
import 'entities.dart';

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
    // A la posicion de la pelota se le suma un error aleatorio.
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
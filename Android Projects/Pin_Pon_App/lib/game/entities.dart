// entities.dart
// Entidades del juego: la Pelota y la Paleta.
// Guardan posiciones en decimales para que el movimiento por tiempo sea suave.
import 'dart:math' as math;

import 'config.dart';

/// Representa la pelota del juego.
class Pelota {
  double x;
  double y;
  double dx;
  double dy;
  double velocidad;

  Pelota({
    required this.x,
    required this.y,
    this.dx = 1,
    this.dy = 1,
    this.velocidad = 1.0,
  });

  /// Velocidad real en el eje vertical (mas lenta que la horizontal).
  double get velocidadVertical => velocidad * GameConfig.ratioVertical;

  /// Mueve la pelota segun su velocidad y el tiempo transcurrido [dt].
  void mover(double dt) {
    x += dx * velocidad * dt;
    y += dy * velocidadVertical * dt;
  }

  /// Invierte la direccion horizontal.
  void rebotarX() => dx = -dx;

  /// Ajusta el angulo vertical segun el punto de [impacto] de la paleta.
  void ajustarAngulo(double impacto) {
    final angulo = (impacto * 1.2).clamp(-1.0, 1.0);
    const minimo = 0.35;
    dy = angulo.abs() < minimo ? (angulo < 0 ? -minimo : minimo) : angulo;
  }

  /// Centra la pelota y cambia el lado del saque.
  void reiniciar(double centroX, double centroY) {
    x = centroX;
    y = centroY;
    dx = -dx;
    dy = math.Random().nextBool() ? 0.6 : -0.6;
  }
}

/// Representa una paleta (jugador o IA).
class Paleta {
  double y;
  final int x;
  final int alto;

  Paleta({required this.x, required this.y, required this.alto});

  /// Centro vertical de la paleta para calcular el angulo de rebote.
  double get centro => y + alto / 2;

  /// Mueve la paleta hacia arriba dentro de la cancha.
  void moverArriba({required double pasos, required double dt}) {
    y = math.max(1.0, y - pasos * dt);
  }

  /// Mueve la paleta hacia abajo dentro de la cancha.
  void moverAbajo({
    required double pasos,
    required double dt,
    required int limiteInferior,
  }) {
    y = math.min(limiteInferior - 1.0 - alto, y + pasos * dt);
  }

  /// Mueve la paleta hacia un [objetivo] en pantalla (usado con el tactil):
  /// avanza el maximo posible por frame sin pasarse del objetivo.
  void moverA(double objetivo, {required double pasos, required double dt}) {
    final delta = objetivo - centro;
    final maxPaso = pasos * dt;
    final paso = delta.clamp(-maxPaso, maxPaso);
    y = (y + paso).clamp(1.0, (GameConfig.alto - 1 - alto).toDouble());
  }
}
// entities.dart
// Define los objetos del juego: la Pelota y la Paleta.
// Ambos guardan posiciones en decimales para que el movimiento por
// "tiempo transcurrido" sea suave y continuo.
import 'dart:math' as math;

import 'game_config.dart';

/// Representa la pelota del juego.
class Pelota {
  /// Posicion horizontal y vertical (en celdas, con decimales).
  double x;
  double y;

  /// Sentido de desplazamiento en cada eje: +1 o -1.
  double dx;
  double dy;

  /// Rapidez horizontal en celdas por segundo.
  double velocidad;

  Pelota({
    required this.x,
    required this.y,
    this.dx = 1,
    this.dy = 1,
    this.velocidad = 1.0,
  });

  /// Velocidad real en el eje vertical (la pelota viaja mas lenta
  /// verticalmente para que el juego sea jugable).
  double get velocidadVertical => velocidad * GameConfig.ratioVertical;

  /// Posicion entera (celda) para dibujar la pelota en pantalla.
  int get xEntero => x.round();
  int get yEntero => y.round();

  /// Mueve la pelota segun su velocidad y el [dt] (delta de tiempo).
  void mover(double dt) {
    x += dx * velocidad * dt;
    y += dy * velocidadVertical * dt;
  }

  /// Invierte la direccion horizontal.
  void rebotarX() => dx = -dx;

  /// Invierte la direccion vertical.
  void rebotarY() => dy = -dy;

  /// Ajusta el angulo vertical de salida segun el punto de [impacto]
  /// en la paleta (-1 abajo, 1 arriba). Garantiza un angulo minimo para
  /// evitar que la pelota viaje casi horizontal.
  void ajustarAngulo(double impacto) {
    final angulo = (impacto * 1.2).clamp(-1.0, 1.0);
    const minimo = 0.35;
    dy = angulo.abs() < minimo ? (angulo < 0 ? -minimo : minimo) : angulo;
  }

  /// Coloca la pelota en el centro y cambia de lado quien saca.
  void reiniciar(double centroX, double centroY) {
    x = centroX;
    y = centroY;
    dx = -dx;
    dy = math.Random().nextBool() ? 0.6 : -0.6;
  }
}

/// Representa una paleta (jugador o IA).
class Paleta {
  /// Posicion vertical (decimal) y horizontal fija.
  double y;
  final int x;

  /// Altura en celdas de la paleta.
  final int alto;

  Paleta({required this.x, required this.y, required this.alto});

  /// Centro vertical de la paleta, usado para calcular el angulo de rebote.
  double get centro => y + alto / 2;

  /// Sube limitada por el borde superior de la cancha.
  void moverArriba({required double pasos, required double dt}) {
    y = math.max(1.0, y - pasos * dt);
  }

  /// Baja limitada por el borde inferior de la cancha.
  void moverAbajo({
    required double pasos,
    required double dt,
    required int limiteInferior,
  }) {
    y = math.min(limiteInferior - 1.0 - alto, y + pasos * dt);
  }
}
// pin_pon_test.dart
// Pruebas unitarias de la logica del juego: movimiento de la pelota,
// escalado vertical, rebotes, limites de la paleta y configuracion.
import 'package:pin_pon/entities.dart';
import 'package:pin_pon/game_config.dart';
import 'package:pin_pon/pin_pon.dart';
import 'package:test/test.dart';

void main() {
  test('calculate', () {
    expect(calculate(), 42);
  });

  test('la pelota avanza segun su velocidad y el tiempo transcurrido', () {
    final pelota = Pelota(x: 10, y: 10, velocidad: 10);
    pelota.mover(0.5);
    expect(pelota.x, 15);
    expect(pelota.y, closeTo(13, 0.001));
  });

  test('la velocidad vertical es proporcional a la velocidad', () {
    expect(Pelota(x: 0, y: 0, velocidad: 10).velocidadVertical, 6);
    expect(Pelota(x: 0, y: 0, velocidad: 20).velocidadVertical, 12);
  });

  test('los rebotes invierten la direccion', () {
    final pelota = Pelota(x: 10, y: 10);
    pelota.rebotarX();
    pelota.rebotarY();
    expect(pelota.dx, -1);
    expect(pelota.dy, -1);
  });

  test('el angulo de rebote depende del punto de impacto', () {
    final pelota = Pelota(x: 10, y: 10);
    pelota.ajustarAngulo(0.8);
    expect(pelota.dy, closeTo(0.96, 0.001));
    pelota.ajustarAngulo(-0.1);
    expect(pelota.dy, -0.35);
  });

  test('la paleta no sale de los limites', () {
    final paleta = Paleta(x: 2, y: 1, alto: 4);
    paleta.moverArriba(pasos: 10, dt: 1);
    expect(paleta.y, 1);

    paleta.moverAbajo(
      pasos: 100,
      dt: 1,
      limiteInferior: GameConfig.alto,
    );
    expect(paleta.y, GameConfig.alto - 1 - paleta.alto);
  });

  test('la velocidad progresiva crece hasta el maximo', () {
    final cfg = GameConfig.dificultades[Dificultad.medio]!;
    double velocidad(int puntos) {
      final base =
          cfg.velocidadInicial + puntos * GameConfig.incrementoVelocidadPorPunto;
      return base.clamp(cfg.velocidadInicial, cfg.velocidadMaxima).toDouble();
    }

    expect(velocidad(0), cfg.velocidadInicial);
    expect(velocidad(30), cfg.velocidadMaxima);
  });

  test('las velocidades estan expresadas en celdas por segundo', () {
    final cfg = GameConfig.dificultades[Dificultad.dificil]!;
    expect(cfg.velocidadPaleta, greaterThan(10));
    expect(cfg.velocidadInicial, lessThan(cfg.velocidadMaxima));
    expect(GameConfig.frameRate.inMilliseconds, lessThanOrEqualTo(40));
  });

  test('existen retos configurables', () {
    expect(GameConfig.retos, isNotEmpty);
    expect(GameConfig.retos.first.objetivo, greaterThan(0));
    expect(GameConfig.retos.any((r) => r.tiempoSegundos > 0), isTrue);
  });
}
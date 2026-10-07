// config.dart
// Configuracion central del juego: dimensiones de la cancha, velocidades
// por dificultad, parametros de la IA, retos y textos de los modos.

/// Nivel de dificultad disponible.
enum Dificultad { facil, medio, dificil }

/// Nombre mostrado de cada dificultad.
extension DificultadInfo on Dificultad {
  String get nombre {
    switch (this) {
      case Dificultad.facil:
        return 'Facil';
      case Dificultad.medio:
        return 'Medio';
      case Dificultad.dificil:
        return 'Dificil';
    }
  }
}

/// Modos de juego ofrecidos en el menu principal.
enum ModoJuego { dosJugadores, contraIA, reto }

/// Parametros de una dificultad.
class ConfigDificultad {
  final double velocidadInicial;
  final double velocidadMaxima;
  final double velocidadPaleta;
  final double velocidadIA;
  final int tamanoPaleta;
  final double margenErrorIA;
  final double umbralReaccionIA;

  const ConfigDificultad({
    required this.velocidadInicial,
    required this.velocidadMaxima,
    required this.velocidadPaleta,
    required this.velocidadIA,
    required this.tamanoPaleta,
    required this.margenErrorIA,
    required this.umbralReaccionIA,
  });
}

/// Un reto: un objetivo de puntos o de tiempo contra la IA.
class Reto {
  final int id;
  final String nombre;
  final String descripcion;
  final Dificultad dificultad;

  /// Puntos a anotar para superarlo (0 si el reto es por tiempo).
  final int objetivo;

  /// Segundos a sobrevivir (0 si el reto es por puntos).
  final int tiempoSegundos;

  const Reto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.dificultad,
    this.objetivo = 0,
    this.tiempoSegundos = 0,
  });
}

/// Valores fijos del juego.
abstract class GameConfig {
  /// Dimensiones de la cancha (en celdas logicas).
  static const int ancho = 40;
  static const int alto = 20;

  /// Puntos necesarios para ganar una partida normal.
  static const int puntosParaGanar = 10;

  /// Posicion inicial de la pelota en el eje X y su velocidad de arranque.
  static const double inicioPelota = 20;

  /// Tope del delta de tiempo por frame.
  static const double maximoDelta = 0.05;

  /// La pelota se mueve mas lenta en vertical que en horizontal.
  static const double ratioVertical = 0.6;

  /// Cuanto acelera la pelota por cada punto.
  static const double incrementoVelocidadPorPunto = 1.0;

  /// Multiplicador de velocidad de la paleta de la IA.
  static const double factorIA = 1.2;

  /// Tiempo (segundos) entre saque y movimiento de la pelota.
  static const double segundosServicio = 0.8;

  /// Parametros por dificultad.
  static const Map<Dificultad, ConfigDificultad> dificultades = {
    Dificultad.facil: ConfigDificultad(
      velocidadInicial: 16,
      velocidadMaxima: 26,
      velocidadPaleta: 24,
      velocidadIA: 16,
      tamanoPaleta: 5,
      margenErrorIA: 2.5,
      umbralReaccionIA: 0.7,
    ),
    Dificultad.medio: ConfigDificultad(
      velocidadInicial: 20,
      velocidadMaxima: 34,
      velocidadPaleta: 28,
      velocidadIA: 20,
      tamanoPaleta: 4,
      margenErrorIA: 1.0,
      umbralReaccionIA: 0.55,
    ),
    Dificultad.dificil: ConfigDificultad(
      velocidadInicial: 26,
      velocidadMaxima: 44,
      velocidadPaleta: 32,
      velocidadIA: 26,
      tamanoPaleta: 3,
      margenErrorIA: 0.0,
      umbralReaccionIA: 0.3,
    ),
  };

  /// Lista de retos disponibles en el menu de retos.
  static const List<Reto> retos = [
    Reto(
      id: 1,
      nombre: 'Calentamiento',
      descripcion: 'Anota 3 puntos contra la IA (Facil)',
      dificultad: Dificultad.facil,
      objetivo: 3,
    ),
    Reto(
      id: 2,
      nombre: 'Ritmo',
      descripcion: 'Anota 7 puntos contra la IA (Medio)',
      dificultad: Dificultad.medio,
      objetivo: 7,
    ),
    Reto(
      id: 3,
      nombre: 'Tanque',
      descripcion: 'Gana 9 puntos contra la IA (Dificil)',
      dificultad: Dificultad.dificil,
      objetivo: 9,
    ),
    Reto(
      id: 4,
      nombre: 'Resistencia',
      descripcion: 'Sobrevive 45 segundos contra la IA (Medio)',
      dificultad: Dificultad.medio,
      tiempoSegundos: 45,
    ),
  ];
}

/// Texto corto que describe el [modo] de juego actual.
String descripcionModo(ModoJuego modo, [Reto? reto]) {
  switch (modo) {
    case ModoJuego.reto:
      return 'Reto: ${reto?.nombre ?? ''}';
    case ModoJuego.dosJugadores:
      return '2 Jugadores';
    case ModoJuego.contraIA:
      return 'Vs IA';
  }
}
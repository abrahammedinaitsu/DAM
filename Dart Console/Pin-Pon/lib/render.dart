// render.dart
// Dibuja la cancha, la pelota y las paletas usando codigos de escape ANSI.
// Cada frame se reconstruye el cuadro completo en un StringBuffer y se
// escribe de una sola vez para evitar parpadeos.
import 'dart:io';

import 'entities.dart';
import 'game_config.dart';

/// Utilidades de dibujo y color por terminal.
class Renderer {
  // Codigos de escape ANSI para colores y estilos.
  static const String _reset = '\x1B[0m';
  static const String _negrita = '\x1B[1m';
  static const String _cian = '\x1B[96m';
  static const String _verde = '\x1B[92m';
  static const String _rojo = '\x1B[91m';
  static const String _amarillo = '\x1B[93m';
  static const String _gris = '\x1B[90m';

  static void ocultarCursor() => stdout.write('\x1B[?25l');
  static void mostrarCursor() => stdout.write('\x1B[?25h');
  static void limpiarPantalla() => stdout.write('\x1B[2J\x1B[H');
  static void inicioPantalla() => stdout.write('\x1B[H');

  // Atajos para escribir texto con color y estilo.
  static String titulo(String texto) => ' $_negrita$_cian$texto$_reset';
  static String resaltar(String texto) => ' $_negrita$texto$_reset';
  static String verde(String texto) => '$_verde$texto$_reset';
  static String rojo(String texto) => '$_rojo$texto$_reset';
  static String amarillo(String texto) => '$_amarillo$texto$_reset';
  static String gris(String texto) => '$_gris$texto$_reset';

  /// Dibuja un frame completo del juego sobre toda la pantalla.
  static void dibujar({
    required Pelota pelota,
    required Paleta j1,
    required Paleta j2,
    required int p1,
    required int p2,
    required String encabezado,
  }) {
    final buffer = StringBuffer();
    buffer.write('\x1B[H'); // Cursor al inicio para redibujar encima.
    buffer
      ..write(encabezado)
      ..write('\x1B[K') // Limpia el resto de la linea del encabezado.
      ..writeln();
    buffer.writeln('+${'-' * (GameConfig.ancho - 2)}+');

    // Posicion (redondeada a celda) de la pelota.
    final px = pelota.xEntero;
    final py = pelota.yEntero;

    // Rangos de fila que ocupa cada paleta (con decimales, se suavizan).
    final inicioJ1 = j1.y.floor();
    final finJ1 = (j1.y + j1.alto).ceil();
    final inicioJ2 = j2.y.floor();
    final finJ2 = (j2.y + j2.alto).ceil();

    // Recorre cada celda de la cancha y decide que caracter pintar.
    for (int y = 0; y < GameConfig.alto; y++) {
      buffer.write('|');
      for (int x = 1; x < GameConfig.ancho - 1; x++) {
        if (x == px && y == py) {
          buffer.write('${_amarillo}O$_reset'); // Pelota.
        } else if (x == j1.x && y >= inicioJ1 && y < finJ1) {
          buffer.write('${_verde}H$_reset'); // Paleta jugador 1.
        } else if (x == j2.x && y >= inicioJ2 && y < finJ2) {
          buffer.write('${_rojo}H$_reset'); // Paleta jugador 2 / IA.
        } else if (x == GameConfig.ancho ~/ 2) {
          buffer.write(':'); // Linea central.
        } else {
          buffer.write(' ');
        }
      }
      buffer.writeln('|');
    }

    buffer.writeln('+${'-' * (GameConfig.ancho - 2)}+');
    stdout.write(buffer.toString());
  }
}
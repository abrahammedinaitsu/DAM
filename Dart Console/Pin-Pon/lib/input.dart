// input.dart
// Lectura de teclado sin "Enter" para tener control en tiempo real.
// Desactiva el modo de linea y el eco, interpreta las secuencias de escape
// de las flechas del teclado (↑/↓) y guarda el instante de cada tecla para
// saber si fue pulsada "recientemente".
import 'dart:io';

/// Lector de teclado no bloqueante para terminales.
class Teclado {
  /// Instante (ms) en que se pulso cada tecla por ultima vez.
  final Map<String, int> _ultimasTeclas = <String, int>{};

  /// Bytes recibidos que no formaron parte completa de una secuencia.
  final List<int> _pendientes = <int>[];
  bool _configurado = false;

  /// Configura el modo crudo de la terminal y escucha las pulsaciones.
  void configurar(void Function(String) alTecla) {
    if (_configurado) {
      return;
    }
    _configurado = true;
    try {
      stdin.lineMode = false;
      stdin.echoMode = false;
    } on StdinException {
      // La terminal no soporta cambiar el modo de linea
    }

    stdin.listen((List<int> codigos) {
      final ahora = DateTime.now().millisecondsSinceEpoch;
      // Une los bytes pendientes con los nuevos para completar secuencias.
      final buffer = <int>[..._pendientes, ...codigos];
      _pendientes.clear();

      final consumido = _parsear(buffer, ahora, alTecla);
      _pendientes.addAll(buffer.skip(consumido));
    });
  }

  /// Separa las secuencias de escape de las teclas normales y las registra.
  /// Devuelve cuantos bytes se consumieron (los incompletos quedan pendientes).
  int _parsear(List<int> datos, int ahora, void Function(String) alTecla) {
    int i = 0;
    while (i < datos.length) {
      final byte = datos[i];

      // Secuencia ESC [ ? (xterm/linux: ESC [ A = arriba, ESC [ B = abajo).
      if (byte == 0x1B) {
        if (i + 2 >= datos.length) {
          return i; // Secuencia incompleta, se conserva para la siguiente vez.
        }
        if (datos[i + 1] != 0x5B) {
          i += 1;
          continue;
        }
        final fin = datos[i + 2];
        if (fin == 0x41) {
          _registrar('arrowup', ahora, alTecla);
        } else if (fin == 0x42) {
          _registrar('arrowdown', ahora, alTecla);
        }
        i += 3;
        continue;
      }

      // Secuencia E0 ? (Windows: E0 H = arriba, E0 P = abajo).
      if (byte == 0xE0 || byte == 0x00) {
        if (i + 1 >= datos.length) {
          return i;
        }
        final fin = datos[i + 1];
        if (fin == 0x48) {
          _registrar('arrowup', ahora, alTecla);
        } else if (fin == 0x50) {
          _registrar('arrowdown', ahora, alTecla);
        }
        i += 2;
        continue;
      }

      // Tecla normal: se guarda su letra en minusculas.
      final tecla = String.fromCharCode(byte).toLowerCase();
      if (tecla.isNotEmpty && !tecla.contains('\x00')) {
        _registrar(tecla, ahora, alTecla);
      }
      i++;
    }
    return i;
  }

  /// Guarda la tecla y avisa al callback del juego.
  void _registrar(String tecla, int ahora, void Function(String) alTecla) {
    _ultimasTeclas[tecla] = ahora;
    alTecla(tecla);
  }

  /// Verdadero si [tecla] se pulso dentro de los ultimos [ventanaMs] ms.
  bool reciente(String tecla, int ventanaMs) {
    final instante = _ultimasTeclas[tecla];
    if (instante == null) {
      return false;
    }
    return DateTime.now().millisecondsSinceEpoch - instante < ventanaMs;
  }

  /// Verdadero si alguna de las [teclas] se pulso recientemente.
  bool recienteCualquiera(List<String> teclas, int ventanaMs) {
    for (final tecla in teclas) {
      if (reciente(tecla, ventanaMs)) {
        return true;
      }
    }
    return false;
  }

  /// Restaura el modo normal de la terminal (linea + eco).
  void restaurarModo() {
    try {
      stdin.lineMode = true;
      stdin.echoMode = true;
    } on StdinException {
      // La terminal no soporta cambiar el modo de linea
    }
  }
}
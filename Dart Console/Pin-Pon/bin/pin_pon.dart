// bin/pin_pon.dart
// Punto de entrada del juego Pin-Pon en consola.
// Gestiona el bucle principal (Timer), los estados de pantalla, la fisica
// (movimiento, rebotes y colisiones) y el control con teclado en crudo.
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:pin_pon/ai.dart';
import 'package:pin_pon/entities.dart';
import 'package:pin_pon/game_config.dart';
import 'package:pin_pon/input.dart';
import 'package:pin_pon/pin_pon.dart';
import 'package:pin_pon/render.dart';
import 'package:pin_pon/ui.dart';

/// Pantallas fuera de la partida.
enum Pantalla { inicio, dificultad, retos, finPartida }

/// Arranca el juego: saluda, configura el teclado y pinta el menu.
void main() {
  stdout.write(saludo());

  final teclado = Teclado();
  final juego = PinPonJuego(teclado);

  Renderer.ocultarCursor();
  teclado.configurar(juego.procesarTecla);
  pintarInicio();

  // Al pulsar Ctrl+C se restaura la terminal y se sale ordenadamente.
  ProcessSignal.sigint.watch().listen((_) {
    juego.detener();
    exit(0);
  });
}

/// Logica principal del juego: estados, partidas y fisica.
class PinPonJuego {
  final Teclado _teclado;
  final IA _ia = IA();

  Pantalla _pantalla = Pantalla.inicio;
  Timer? _timer;
  bool _jugando = false;
  bool _pausado = false;

  // Modo y dificultad elegidos (pendiente hasta confirmar la dificultad).
  ModoJuego? _modoPendiente;
  ModoJuego _modo = ModoJuego.dosJugadores;
  Dificultad _dificultad = Dificultad.medio;
  Reto? _reto;
  final Set<int> _retosCompletados = <int>{};

  // Estado vivo de la partida.
  Pelota? _pelota;
  Paleta? _j1;
  Paleta? _j2;
  int _p1 = 0;
  int _p2 = 0;
  int _tiempoMs = 0;
  DateTime _ultimoFrame = DateTime.now();

  // Rampa 0..1 que suaviza el arranque y el frenado de la paleta humana.
  double _impulsoJ1 = 0;

  PinPonJuego(this._teclado);

  ConfigDificultad get _config => GameConfig.dificultades[_dificultad]!;

  /// Distribuye cada tecla segun la pantalla actual.
  void procesarTecla(String tecla) {
    if (_jugando) {
      _procesarTeclaJuego(tecla);
      return;
    }

    switch (_pantalla) {
      case Pantalla.inicio:
        _procesarTeclaInicio(tecla);
        break;
      case Pantalla.dificultad:
        _procesarTeclaDificultad(tecla);
        break;
      case Pantalla.retos:
        _procesarTeclaRetos(tecla);
        break;
      case Pantalla.finPartida:
        _mostrarInicio();
        break;
    }
  }

  /// Restaura la terminal (timer, modo de teclado y cursor).
  void detener() {
    _timer?.cancel();
    _teclado.restaurarModo();
    Renderer.mostrarCursor();
  }

  /// Menu principal: 1 dos jugadores, 2 vs IA, 3 retos, 4 salir.
  void _procesarTeclaInicio(String tecla) {
    switch (tecla) {
      case '1':
        _modoPendiente = ModoJuego.dosJugadores;
        _pantalla = Pantalla.dificultad;
        pintarDificultad(descripcionModo(ModoJuego.dosJugadores));
        break;
      case '2':
        _modoPendiente = ModoJuego.contraIA;
        _pantalla = Pantalla.dificultad;
        pintarDificultad(descripcionModo(ModoJuego.contraIA));
        break;
      case '3':
        _pantalla = Pantalla.retos;
        pintarRetos(GameConfig.retos, _retosCompletados);
        break;
      case '4':
      case 'q':
        _salir();
    }
  }

  /// Eleccion de dificultad; 1 facil, 2 medio, 3 dificil, r volver, q salir.
  void _procesarTeclaDificultad(String tecla) {
    switch (tecla) {
      case 'r':
        _mostrarInicio();
        return;
      case 'q':
        _salir();
        return;
      case '1':
        _dificultad = Dificultad.facil;
        break;
      case '2':
        _dificultad = Dificultad.medio;
        break;
      case '3':
        _dificultad = Dificultad.dificil;
        break;
      default:
        return;
    }

    _modo = _modoPendiente ?? _modo;
    _iniciarPartida();
  }

  /// Pantalla de retos: numero del reto, r volver, q salir.
  void _procesarTeclaRetos(String tecla) {
    if (tecla == 'r') {
      _mostrarInicio();
      return;
    }
    if (tecla == 'q') {
      _salir();
      return;
    }

    final indice = int.tryParse(tecla);
    if (indice != null && indice >= 1 && indice <= GameConfig.retos.length) {
      final reto = GameConfig.retos[indice - 1];
      _reto = reto;
      _modo = ModoJuego.reto;
      _dificultad = reto.dificultad;
      _iniciarPartida();
    }
  }

  /// Durante la partida: q abandona y p pausa/reanuda.
  void _procesarTeclaJuego(String tecla) {
    if (tecla == 'q') {
      _terminarPartida('Partida abandonada.');
      return;
    }
    if (tecla == 'p') {
      _pausado = !_pausado;
      _dibujarPartida();
    }
  }

  /// Crea la pelota y las paletas, y arranca el bucle del juego.
  void _iniciarPartida() {
    _jugando = true;
    _pausado = false;
    _p1 = 0;
    _p2 = 0;
    _tiempoMs = 0;
    _ultimoFrame = DateTime.now();
    _impulsoJ1 = 0;

    final mitad = GameConfig.alto ~/ 2;
    _pelota = Pelota(
      x: GameConfig.ancho / 2,
      y: GameConfig.alto / 2,
      velocidad: _config.velocidadInicial,
    );
    _j1 = Paleta(
      x: 2,
      y: mitad - _config.tamanoPaleta / 2,
      alto: _config.tamanoPaleta,
    );
    _j2 = Paleta(
      x: GameConfig.ancho - 3,
      y: mitad - _config.tamanoPaleta / 2,
      alto: _config.tamanoPaleta,
    );

    Renderer.ocultarCursor();
    _timer = Timer.periodic(GameConfig.frameRate, (_) => _bucle());
    _dibujarPartida();
  }

  /// Un frame del juego: calcula el tiempo transcurrido y actualiza todo.
  void _bucle() {
    if (_pausado || !_jugando) {
      _ultimoFrame = DateTime.now();
      return;
    }

    final ahora = DateTime.now();
    final dt = math.min(
      GameConfig.maximoDelta,
      ahora.difference(_ultimoFrame).inMicroseconds / 1e6,
    );
    _ultimoFrame = ahora;

    _tiempoMs += (dt * 1000).round();

    _moverPaletas(dt);
    _pelota!.mover(dt);
    _rebotesYColisiones();
    _verificarPuntos();
    if (_jugando) {
      _dibujarPartida();
    }
  }

  /// Mueve las paletas segun las teclas recientes o la IA.
  void _moverPaletas(double dt) {
    final pasos = _config.velocidadPaleta;
    final ventana = GameConfig.msRetencionTecla;

    // Rampa de aceleracion suave de la paleta humana: sube rapido al pulsar
    // la tecla y decae al soltarla, evitando arranques y frenazos bruscos.
    final subir = _teclado.recienteCualquiera(['w', 'arrowup'], ventana);
    final bajar = _teclado.recienteCualquiera(['s', 'arrowdown'], ventana);
    if (subir || bajar) {
      _impulsoJ1 = math.min(1.0, _impulsoJ1 + dt / GameConfig.rampaAceleracion);
    } else {
      _impulsoJ1 = math.max(0.0, _impulsoJ1 - dt / GameConfig.rampaFrenado);
    }

    final velocidad = pasos * _impulsoJ1;
    if (subir) {
      _j1!.moverArriba(pasos: velocidad, dt: dt);
    }
    if (bajar) {
      _j1!.moverAbajo(
        pasos: velocidad,
        dt: dt,
        limiteInferior: GameConfig.alto,
      );
    }

    if (_modo == ModoJuego.dosJugadores) {
      if (_teclado.reciente('i', ventana)) {
        _j2!.moverArriba(pasos: pasos, dt: dt);
      }
      if (_teclado.reciente('k', ventana)) {
        _j2!.moverAbajo(
          pasos: pasos,
          dt: dt,
          limiteInferior: GameConfig.alto,
        );
      }
    } else {
      _ia.mover(_j2!, _pelota!, _config, dt);
    }
  }

  /// Rebotes contra techo, piso y paletas (el angulo depende del impacto).
  void _rebotesYColisiones() {
    final pelota = _pelota!;
    final j1 = _j1!;
    final j2 = _j2!;

    if (pelota.y <= 0) {
      pelota.y = 0;
      pelota.dy = pelota.dy.abs();
    }
    if (pelota.y >= GameConfig.alto - 1) {
      pelota.y = GameConfig.alto - 1;
      pelota.dy = -pelota.dy.abs();
    }

    if (pelota.dx < 0 && pelota.x <= j1.x + 1 && _dentroRango(pelota.y, j1)) {
      pelota.x = j1.x + 1;
      pelota.rebotarX();
      pelota.ajustarAngulo((pelota.y - j1.centro) / (j1.alto / 2));
    }
    if (pelota.dx > 0 && pelota.x >= j2.x - 1 && _dentroRango(pelota.y, j2)) {
      pelota.x = j2.x - 1;
      pelota.rebotarX();
      pelota.ajustarAngulo((pelota.y - j2.centro) / (j2.alto / 2));
    }
  }

  /// La pelota esta dentro del tramo vertical que cubre la paleta?
  bool _dentroRango(double y, Paleta paleta) =>
      y >= paleta.y && y < paleta.y + paleta.alto;

  /// Si la pelota cruzo un fondo, se suma punto al rival.
  void _verificarPuntos() {
    final pelota = _pelota!;
    final j1 = _j1!;
    final j2 = _j2!;

    if (pelota.x <= j1.x) {
      _p2++;
      _registrarPunto();
    } else if (pelota.x >= j2.x) {
      _p1++;
      _registrarPunto();
    }
  }

  /// Tras un punto: la pelota saca del otro lado, con mas velocidad.
  void _registrarPunto() {
    final puntos = _p1 + _p2;
    final base =
        _config.velocidadInicial + puntos * GameConfig.incrementoVelocidadPorPunto;
    final velocidad = math.min(_config.velocidadMaxima, base);
    _pelota!.velocidad = velocidad;
    _pelota!.reiniciar(GameConfig.ancho / 2, GameConfig.alto / 2);
    _verificarFinPartida();
  }

  /// Comprueba si se cumplio el reto o si alguien llego a los 10 puntos.
  void _verificarFinPartida() {
    if (_modo == ModoJuego.reto) {
      final reto = _reto!;
      if (reto.tiempoSegundos > 0) {
        if (_tiempoMs >= reto.tiempoSegundos * 1000) {
          _terminarPartida(
            'Reto "${reto.nombre}" completado! Sobreviviste '
            '${reto.tiempoSegundos} segundos.',
            completo: true,
          );
        }
      } else if (_p1 >= reto.objetivo) {
        _terminarPartida(
          'Reto "${reto.nombre}" completado! Anotaste $_p1 puntos.',
          completo: true,
        );
      }
      return;
    }

    if (_p1 >= GameConfig.puntosParaGanar) {
      _terminarPartida('Victoria del Jugador 1!  Marcador final: $_p1 - $_p2');
    } else if (_p2 >= GameConfig.puntosParaGanar) {
      final ganador = _modo == ModoJuego.contraIA ? 'la IA' : 'el Jugador 2';
      _terminarPartida('Victoria de $ganador!  Marcador final: $_p1 - $_p2');
    }
  }

  /// Detiene la partida y muestra el [mensaje] final.
  void _terminarPartida(String mensaje, {bool completo = false}) {
    _jugando = false;
    _timer?.cancel();
    _timer = null;

    if (completo && _reto != null) {
      _retosCompletados.add(_reto!.id);
    }

    Renderer.mostrarCursor();
    _pantalla = Pantalla.finPartida;
    pintarFin(mensaje);
    _reto = null;
    _modoPendiente = null;
  }

  /// Dibuja el frame actual de la partida y sus marcadores.
  void _dibujarPartida() {
    final encabezado =
        '  ${descripcionModo(_modo, _reto)} [${_dificultad.nombre}]'
        '  J1: $_p1  |  J2: $_p2  |  Vel ${_pelota!.velocidad.toStringAsFixed(1)} c/s';

    Renderer.dibujar(
      pelota: _pelota!,
      j1: _j1!,
      j2: _j2!,
      p1: _p1,
      p2: _p2,
      encabezado: encabezado,
    );

    if (_pausado) {
      stdout.write(Renderer.amarillo('\n  [PAUSA]  P para continuar, Q para salir'));
    }
  }

  /// Vuelve al menu principal ocultando el cursor.
  void _mostrarInicio() {
    _pantalla = Pantalla.inicio;
    Renderer.ocultarCursor();
    pintarInicio();
  }

  /// Sale del juego limpiando la pantalla.
  void _salir() {
    detener();
    Renderer.limpiarPantalla();
    stdout.writeln('Gracias por jugar Pin-Pon. Hasta pronto!');
    exit(0);
  }
}
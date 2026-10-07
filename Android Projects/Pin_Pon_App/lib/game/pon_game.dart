// pon_game.dart
// Motor del juego Pin-Pon con Flame.
// Gestiona la maquina de estados (menu, dificultad, retos, jugando, pausa,
// fin), el movimiento por teclado y tactil, la fisica de la pelota y el
// dibujado de la cancha con Canvas.
import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../platform/salida.dart';
import 'ai.dart';
import 'config.dart';
import 'entities.dart';

/// Estados posibles del juego en pantalla.
enum EstadoJuego { menu, dificultad, retos, jugando, pausa, fin }

/// Juego principal de Flame que mezcla arrastre "multi-touch" y teclado.
class PinPonGame extends FlameGame with MultiTouchDragDetector, KeyboardEvents {
  // Nombres de los overlays registrados en el GameWidget.
  static const String menu = 'menu';
  static const String dificultad = 'dificultad';
  static const String retos = 'retos';
  static const String hud = 'hud';
  static const String pausa = 'pausa';
  static const String fin = 'fin';

  // Notificadores que avisan a los overlays (HUD y fin) de los cambios.
  final ValueNotifier<String> infoHud = ValueNotifier('0 - 0');
  final ValueNotifier<String> mensajeFin = ValueNotifier('');
  final Set<int> retosCompletados = <int>{};

  EstadoJuego estado = EstadoJuego.menu;

  // Modo, dificultad y reto elegidos.
  ModoJuego modo = ModoJuego.contraIA;
  ModoJuego? _modoPendiente;
  Dificultad dificultadSeleccionada = Dificultad.medio;
  Reto? retoActivo;

  // Entidades y marcador de la partida en curso.
  final IA _ia = IA();
  Pelota? pelota;
  Paleta? jugador1;
  Paleta? jugador2;
  int puntos1 = 0;
  int puntos2 = 0;

  int _tiempoMs = 0;
  double _servicio = 0;

  // Dedos arrastrando: posicion objetivo por puntero, separados por lado.
  final Map<int, double> _dedosJ1 = <int, double>{};
  final Map<int, double> _dedosJ2 = <int, double>{};
  Set<LogicalKeyboardKey> _teclas = <LogicalKeyboardKey>{};

  ConfigDificultad get _config =>
      GameConfig.dificultades[dificultadSeleccionada]!;

  // ------------------------------------------------------------- menues

  /// Pasa al menu de dificultad guardando el modo elegido por el jugador.
  void elegirModo(ModoJuego nuevoModo) {
    _modoPendiente = nuevoModo;
    estado = EstadoJuego.dificultad;
    overlays.remove(menu);
    overlays.remove(retos);
    overlays.add(dificultad);
  }

  /// Confirma la [d]ificultad y arranca la partida.
  void elegirDificultad(Dificultad d) {
    dificultadSeleccionada = d;
    modo = _modoPendiente ?? ModoJuego.contraIA;
    _modoPendiente = null;
    retoActivo = null;
    overlays.remove(dificultad);
    iniciarPartida();
  }

  /// Abre la pantalla de retos.
  void abrirRetos() {
    estado = EstadoJuego.retos;
    overlays.remove(menu);
    overlays.add(retos);
  }

  /// Selecciona un [ret]o y arranca la partida con su configuracion.
  void elegirReto(Reto reto) {
    retoActivo = reto;
    modo = ModoJuego.reto;
    dificultadSeleccionada = reto.dificultad;
    overlays.remove(retos);
    iniciarPartida();
  }

  /// Detiene la partida y vuelve a mostrar el menu principal.
  void volverAlMenu() {
    estado = EstadoJuego.menu;
    pelota = null;
    jugador1 = null;
    jugador2 = null;
    _dedosJ1.clear();
    _dedosJ2.clear();
    overlays.remove(hud);
    overlays.remove(pausa);
    overlays.remove(fin);
    overlays.remove(dificultad);
    overlays.remove(retos);
    if (!overlays.isActive(menu)) {
      overlays.add(menu);
    }
  }

  /// Cierra la aplicacion usando la salida por plataforma.
  void salir() {
    cerrarAplicacion();
  }

  // ------------------------------------------------------------- partida

  /// Crea la pelota y las paletas, reinicia el marcador y muestra el HUD.
  void iniciarPartida() {
    puntos1 = 0;
    puntos2 = 0;
    _tiempoMs = 0;
    _dedosJ1.clear();
    _dedosJ2.clear();

    final mitad = GameConfig.alto ~/ 2;
    final altoPaleta = _config.tamanoPaleta;
    pelota = Pelota(
      x: GameConfig.ancho / 2,
      y: GameConfig.alto / 2,
      velocidad: _config.velocidadInicial,
    );
    jugador1 = Paleta(x: 2, y: mitad - altoPaleta / 2, alto: altoPaleta);
    jugador2 = Paleta(
      x: GameConfig.ancho - 3,
      y: mitad - altoPaleta / 2,
      alto: altoPaleta,
    );

    _servicio = GameConfig.segundosServicio;
    estado = EstadoJuego.jugando;
    _actualizarHud();
    if (!overlays.isActive(hud)) {
      overlays.add(hud);
    }
    overlays.remove(fin);
    overlays.remove(pausa);
  }

  /// Alterna entre jugar y pausa (y viceversa).
  void alternarPausa() {
    if (estado == EstadoJuego.jugando) {
      estado = EstadoJuego.pausa;
      if (!overlays.isActive(pausa)) {
        overlays.add(pausa);
      }
    } else if (estado == EstadoJuego.pausa) {
      estado = EstadoJuego.jugando;
      overlays.remove(pausa);
    }
  }

  /// Muestra la pantalla de fin con el [mensaje] de resultado.
  void terminarPartida(String mensaje, {bool completo = false}) {
    estado = EstadoJuego.fin;
    final reto = retoActivo;
    if (completo && reto != null) {
      retosCompletados.add(reto.id);
    }
    mensajeFin.value = mensaje;
    overlays.remove(hud);
    overlays.remove(pausa);
    if (!overlays.isActive(fin)) {
      overlays.add(fin);
    }
  }

  // ------------------------------------------------------------- fisica

  /// Actualiza el estado en cada frame (solo mientras se juega).
  @override
  void update(double dt) {
    super.update(dt);
    if (estado != EstadoJuego.jugando) {
      return;
    }

    final t = math.min(GameConfig.maximoDelta, dt);
    _tiempoMs += (t * 1000).round();

    _moverPaletas(t);

    // Durante el servicio la pelota permanece quieta.
    if (_servicio > 0) {
      _servicio -= t;
    } else {
      pelota!.mover(t);
      _rebotesYColisiones();
      _verificarPuntos();
      _verificarRetoPorTiempo();
    }

    _actualizarHud();
  }

  /// Mueve las paletas por teclado, arrastre tactil o IA.
  void _moverPaletas(double dt) {
    final pasos = _config.velocidadPaleta;
    final j1 = jugador1!;
    final j2 = jugador2!;

    // Jugador 1: W/flecha arriba sube y S/flecha abajo baja.
    final arriba =
        _teclas.contains(LogicalKeyboardKey.keyW) ||
        _teclas.contains(LogicalKeyboardKey.arrowUp);
    final abajo =
        _teclas.contains(LogicalKeyboardKey.keyS) ||
        _teclas.contains(LogicalKeyboardKey.arrowDown);

    if (arriba) {
      j1.moverArriba(pasos: pasos, dt: dt);
    } else if (abajo) {
      j1.moverAbajo(
        pasos: pasos,
        dt: dt,
        limiteInferior: GameConfig.alto,
      );
    } else if (_dedosJ1.isNotEmpty) {
      // Con tactil va hacia la posicion del ultimo dedo que arrastra.
      j1.moverA(_dedosJ1.values.last, pasos: pasos, dt: dt);
    }

    if (modo == ModoJuego.dosJugadores) {
      // Jugador 2 humano: I arriba y K abajo.
      final iArriba = _teclas.contains(LogicalKeyboardKey.keyI);
      final iAbajo = _teclas.contains(LogicalKeyboardKey.keyK);
      if (iArriba) {
        j2.moverArriba(pasos: pasos, dt: dt);
      } else if (iAbajo) {
        j2.moverAbajo(
          pasos: pasos,
          dt: dt,
          limiteInferior: GameConfig.alto,
        );
      } else if (_dedosJ2.isNotEmpty) {
        j2.moverA(_dedosJ2.values.last, pasos: pasos, dt: dt);
      }
    } else {
      _ia.mover(j2, pelota!, _config, dt);
    }
  }

  /// Rebotes contra techo, piso y paletas (angulo segun punto de impacto).
  void _rebotesYColisiones() {
    final p = pelota!;
    final j1 = jugador1!;
    final j2 = jugador2!;

    if (p.y <= 0) {
      p.y = 0;
      p.dy = p.dy.abs();
    }
    if (p.y >= GameConfig.alto - 1) {
      p.y = GameConfig.alto - 1;
      p.dy = -p.dy.abs();
    }

    if (p.dx < 0 && p.x <= j1.x + 1 && _dentroRango(p.y, j1)) {
      p.x = j1.x + 1;
      p.rebotarX();
      p.ajustarAngulo((p.y - j1.centro) / (j1.alto / 2));
    }
    if (p.dx > 0 && p.x >= j2.x - 1 && _dentroRango(p.y, j2)) {
      p.x = j2.x - 1;
      p.rebotarX();
      p.ajustarAngulo((p.y - j2.centro) / (j2.alto / 2));
    }
  }

  /// La pelota esta dentro del tramo vertical que cubre la paleta?
  bool _dentroRango(double y, Paleta paleta) =>
      y >= paleta.y && y < paleta.y + paleta.alto;

  /// Si la pelota cruzo un fondo, se suma punto al rival.
  void _verificarPuntos() {
    final p = pelota!;
    if (p.x <= jugador1!.x) {
      puntos2++;
      _registrarPunto();
    } else if (p.x >= jugador2!.x) {
      puntos1++;
      _registrarPunto();
    }
  }

  /// Tras un punto: la pelota saca del otro lado con mas velocidad.
  void _registrarPunto() {
    final puntos = puntos1 + puntos2;
    final base = _config.velocidadInicial +
        puntos * GameConfig.incrementoVelocidadPorPunto;
    pelota!.velocidad = math.min(_config.velocidadMaxima, base);
    pelota!.reiniciar(GameConfig.ancho / 2, GameConfig.alto / 2);
    _servicio = GameConfig.segundosServicio;
    _actualizarHud();
    _verificarFinPartida();
  }

  /// Si el reto activo es por tiempo, comprueba si se sobrevivio.
  void _verificarRetoPorTiempo() {
    final reto = retoActivo;
    if (modo != ModoJuego.reto || reto == null) {
      return;
    }
    if (reto.tiempoSegundos > 0 &&
        _tiempoMs >= reto.tiempoSegundos * 1000) {
      terminarPartida(
        'Reto "${reto.nombre}" completado! Sobreviviste '
        '${reto.tiempoSegundos} segundos.',
        completo: true,
      );
    }
  }

  /// Comprueba si se cumplio el reto o si alguien llego a 10 puntos.
  void _verificarFinPartida() {
    if (modo == ModoJuego.reto) {
      final reto = retoActivo!;
      if (reto.tiempoSegundos == 0 && puntos1 >= reto.objetivo) {
        terminarPartida(
          'Reto "${reto.nombre}" completado! Anotaste $puntos1 puntos.',
          completo: true,
        );
      }
      return;
    }

    if (puntos1 >= GameConfig.puntosParaGanar) {
      terminarPartida('Victoria del Jugador 1!  Marcador: $puntos1 - $puntos2');
    } else if (puntos2 >= GameConfig.puntosParaGanar) {
      final ganador =
          modo == ModoJuego.contraIA ? 'la IA' : 'el Jugador 2';
      terminarPartida('Victoria de $ganador!  Marcador: $puntos1 - $puntos2');
    }
  }

  /// Actualiza el texto del HUD con el marcador (y el tiempo en los retos).
  void _actualizarHud() {
    var texto = 'J1 $puntos1  -  $puntos2 J2';
    final reto = retoActivo;
    if (modo == ModoJuego.reto &&
        reto != null &&
        reto.tiempoSegundos > 0) {
      final restante = reto.tiempoSegundos - _tiempoMs / 1000;
      texto += '   ${restante.ceil()}s';
    }
    infoHud.value = texto;
  }

  // ------------------------------------------------------------- input

  // Al arrastrar un dedo se guarda su posicion vertical objetivo.
  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    _actualizarDedo(pointerId, info.eventPosition.widget);
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    _actualizarDedo(pointerId, info.eventPosition.widget);
  }

  // Al soltar el dedo se libera su puntero.
  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    _dedosJ1.remove(pointerId);
    _dedosJ2.remove(pointerId);
  }

  @override
  void onDragCancel(int pointerId) {
    _dedosJ1.remove(pointerId);
    _dedosJ2.remove(pointerId);
  }

  /// Convierte la posicion tactil [posicion] a una celda Y de la cancha
  /// y la asigna al lado que corresponda segun la mitad de la pantalla.
  void _actualizarDedo(int pointerId, Vector2 posicion) {
    if (estado != EstadoJuego.jugando) {
      return;
    }
    final escala = _escala;
    if (escala <= 0) {
      return;
    }
    final y = ((posicion.y - _origen.dy) / escala)
        .clamp(0.0, (GameConfig.alto - 1).toDouble());

    final tocaDerecha = posicion.x >= size.x / 2;
    if (modo == ModoJuego.dosJugadores && tocaDerecha) {
      _dedosJ2[pointerId] = y;
    } else {
      _dedosJ1[pointerId] = y;
    }
  }

  /// Maneja el teclado: p/escape pausan, q vuelve al menu y el resto de
  /// teclas de juego se consumen para que no muevan la pagina o el foco.
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    _teclas = keysPressed;
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final tecla = event.logicalKey;
    final enPartida =
        estado == EstadoJuego.jugando || estado == EstadoJuego.pausa;

    if (enPartida) {
      if (tecla == LogicalKeyboardKey.keyP ||
          tecla == LogicalKeyboardKey.escape) {
        alternarPausa();
        return KeyEventResult.handled;
      }
      if (tecla == LogicalKeyboardKey.keyQ) {
        volverAlMenu();
        return KeyEventResult.handled;
      }
      if (_esControlDeJuego(tecla)) {
        // Evita que las flechas muevan la pagina en web o roben el foco
        // en escritorio mientras se juega.
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// Es una tecla que controla alguna paleta?
  bool _esControlDeJuego(LogicalKeyboardKey tecla) {
    return tecla == LogicalKeyboardKey.keyW ||
        tecla == LogicalKeyboardKey.keyS ||
        tecla == LogicalKeyboardKey.keyI ||
        tecla == LogicalKeyboardKey.keyK ||
        tecla == LogicalKeyboardKey.arrowUp ||
        tecla == LogicalKeyboardKey.arrowDown;
  }

  // ------------------------------------------------------------- render

  /// Escala para que la cancha (40x20) quepa en pantalla dejando espacio
  /// para el HUD arriba y margenes a los lados.
  double get _escala {
    final disponibleX = size.x - 32;
    final disponibleY = size.y - 96 - 40;
    return math.min(
      disponibleX / GameConfig.ancho,
      disponibleY / GameConfig.alto,
    );
  }

  /// Origen (esquina superior izquierda) donde se dibuja la cancha.
  Offset get _origen {
    final e = _escala;
    final ancho = GameConfig.ancho * e;
    final alto = GameConfig.alto * e;
    const superior = 96.0;
    final y = superior + (size.y - superior - 40 - alto) / 2;
    return Offset((size.x - ancho) / 2, y);
  }

  /// Rectangulo en pixeles de una celda logica de la cancha.
  Rect _rectMundo(double x, double y, double ancho, double alto) {
    final e = _escala;
    final o = _origen;
    return Rect.fromLTWH(o.dx + x * e, o.dy + y * e, ancho * e, alto * e);
  }

  /// Dibuja la cancha, las paletas y la pelota.
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Fondo general de la pantalla.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFF0B1020),
    );

    final p = pelota;
    final j1 = jugador1;
    final j2 = jugador2;
    if (p == null || j1 == null || j2 == null) {
      return;
    }

    final e = _escala;

    // Fondo y borde de la cancha.
    final cancha = _rectMundo(0, 0, GameConfig.ancho.toDouble(),
        GameConfig.alto.toDouble());
    canvas.drawRect(
      cancha,
      Paint()..color = const Color(0xFF0E1B2E),
    );
    canvas.drawRect(
      cancha,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Linea punteada central.
    final linea = Paint()..color = const Color(0xFF334155);
    var y = 0.0;
    while (y < GameConfig.alto) {
      canvas.drawRect(_rectMundo(GameConfig.ancho / 2 - 0.1, y, 0.2, 0.5),
          linea);
      y += 1;
    }

    // Paletas: verde para J1 y roja para J2/IA, con esquinas redondeadas.
    final pinturaJ1 = Paint()..color = const Color(0xFF22C55E);
    final pinturaJ2 = Paint()..color = const Color(0xFFEF4444);
    final radio = Radius.circular(math.max(2, e * 0.3));

    canvas.drawRRect(
      RRect.fromRectAndRadius(_rectMundo(j1.x.toDouble(), j1.y, 1,
          j1.alto.toDouble()), radio),
      pinturaJ1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(_rectMundo(j2.x.toDouble(), j2.y, 1,
          j2.alto.toDouble()), radio),
      pinturaJ2,
    );

    // Pelota amarilla en el centro de su celda logica.
    final centroPelota = Offset(
      _origen.dx + (p.x + 0.5) * e,
      _origen.dy + (p.y + 0.5) * e,
    );
    canvas.drawCircle(
      centroPelota,
      e * 0.45,
      Paint()..color = const Color(0xFFFBBF24),
    );
  }
}
# Pin Pon App

Migración del juego de Pin-Pon de consola (Dart) a una aplicación móvil
completa hecha con **Flutter + Flame**.

## Qué hace

- Menú principal: 2 jugadores, contra IA, retos y salir.
- Selección de dificultad (Fácil / Medio / Difícil).
- Partida en tiempo real con física idéntica a la versión de consola:
  pelota a velocidad progresiva, rebote con ángulo según el punto de
  impacto y servicio de 0,8 s tras cada punto.
- Marcador, pausa (botón o tecla `P`/`Esc`) y pantalla de fin de partida.
- 4 retos desbloqueables (por puntos o por tiempo de supervivencia).

## Controles

| Entrada             | Acción                                      |
|---------------------|---------------------------------------------|
| Arrastrar el dedo   | Mueve la paleta (izquierda = J1, derecha = J2 en 2 jugadores; en vs IA cualquier toque mueve a J1) |
| W / S o flechas ↑↓  | Mueve la paleta del Jugador 1 (teclado)     |
| I / K               | Mueve la paleta del Jugador 2 (2 jugadores) |
| P o Esc             | Pausa / reanuda                             |
| Q                   | Abandona la partida y vuelve al menú        |

## Estructura

```
lib/
  main.dart                 -> punto de entrada, GameWidget y overlays
  game/
    config.dart             -> dificultades, retos y constantes (port de game_config.dart)
    entities.dart           -> Pelota y Paleta (port de entities.dart)
    ai.dart                 -> IA rival (port de ai.dart)
    pon_game.dart           -> FlameGame: física, render, input y estados
  ui/
    menu_overlay.dart       -> menú principal
    dificultad_overlay.dart -> selección de dificultad
    retos_overlay.dart      -> lista de retos
    hud_overlay.dart        -> marcador y botón de pausa
    pausa_overlay.dart      -> menú de pausa
    fin_overlay.dart        -> resultado de la partida
```

## Ejecutar

```bash
flutter run
```

## Tests y análisis

```bash
flutter analyze
flutter test
```

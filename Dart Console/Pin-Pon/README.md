# Pin-Pon

Juego de pin pon para terminal hecho en Dart. Version 1.2.0

## Caracteristicas

- Menu inicial con modos de juego
- Jugar contra otra persona (W/S o flechas, y I/K)
- Jugar contra la IA
- Sesion de Retos (4 retos desbloqueables)
- Seleccion de dificultad: Facil, Medio, Dificil
- Movimiento basado en tiempo real (delta time): suave y sin saltos
- Velocidad de la pelota progresiva segun el puntaje
- Rebote con angulo variable segun el punto de impacto
- Pausa de partida

## Controles

| Tecla              | Accion                |
|--------------------|-----------------------|
| W / S o flechas    | Mover paleta J1       |
| I / K              | Mover paleta J2       |
| P                  | Pausar partida        |
| Q                  | Salir                 |

## Ejecutar

```bash
dart run bin/pin_pon.dart
```

## Tests

```bash
dart test
```
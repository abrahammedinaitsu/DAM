# DAM — Actividades de Programación

Repositorio con las actividades de programación desarrolladas para el ITSU,
todas escritas por **Abraham Medina**.

## Actividades

| # | Actividad | Carpeta | Tecnología |
|---|-----------|---------|-----------|
| 1 | **Carculator** — Calculadora de consola | `Dart Console/Carculator` | Dart |
| 2 | **Pin-Pon** — Juego de "Pong" en consola | `Dart Console/Pin-Pon` | Dart |
| 3 | **App Basic Two Screens** — App de dos pantallas | `Android Projects/App_Basic_Two_Screens` | Flutter |
| 4 | **Pin-Pon App** — "Pong" con Flutter + Flame | `Android Projects/Pin_Pon_App` | Flutter + Flame |

## Descripción

- **1. Carculator**: calculadora interactiva en terminal que soporta
  `+`, `-`, `*` y `/`, valida la entrada y protege contra la división entre cero.
- **2. Pin-Pon (consola)**: juego de Pong jugable en la terminal con paletas,
  pelota, IA, dificultades, retos y marcador. Movimiento suave por delta de tiempo.
- **3. App Basic Two Screens**: aplicación Flutter con navegación entre dos
  pantallas mediante `MaterialPageRoute`, botones de ida y vuelta y tema Material 3.
- **4. Pin-Pon App**: versión gráfica del juego con el motor **Flame**,
  controles táctiles y por teclado, menús, retos, pausa y fin de partida.
  Compila para Android, web y Windows.

## Cómo ejecutar

### Dart (Actividades 1 y 2)

Desde cada carpeta del proyecto:

```sh
dart run bin/carculator.dart    # Actividad 1
dart run bin/pin_pon.dart       # Actividad 2
```

### Flutter (Actividades 3 y 4)

Desde cada carpeta del proyecto:

```sh
flutter run -d emulator-5554    # Actividad 3 (en un emulador Android)
flutter run -d chrome           # Actividad 4 (en el navegador)
```

## Autor

**Abraham Medina** — [GitHub](https://github.com/abrahammedinaitsu)
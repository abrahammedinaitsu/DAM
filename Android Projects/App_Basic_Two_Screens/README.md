# App Basic Two Screens

Aplicación básica de Flutter con dos pantallas.

## Qué hace

- **Pantalla 1**: muestra un mensaje de bienvenida con un botón en la parte
  inferior.
- Al pulsar el botón se realiza una transición (`MaterialPageRoute`) hacia la
  **Pantalla 2**, que muestra otro mensaje.
- La Pantalla 2 tiene un botón para volver a la Pantalla 1.

## Estructura

```
lib/
  main.dart                 -> punto de entrada y MaterialApp
  screens/
    home_screen.dart        -> Pantalla 1
    second_screen.dart      -> Pantalla 2
```

## Ejecutar

```bash
flutter run
```

## Tests

```bash
flutter test
```

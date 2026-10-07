// salida_io.dart
// Implementacion de `cerrarAplicacion()` para plataformas con dart:io
// (Android, iOS, Windows, Linux, macOS): en moviles se cierra la actividad
// y en escritorio se termina el proceso.
import 'dart:io';

import 'package:flutter/services.dart';

void cerrarAplicacion() {
  if (Platform.isAndroid || Platform.isIOS) {
    SystemNavigator.pop();
  } else {
    exit(0);
  }
}
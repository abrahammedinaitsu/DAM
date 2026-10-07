// salida.dart
// Exporta la implementacion correcta de `cerrarAplicacion()` segun la
// plataforma usando imports condicionales:
//   - dart.library.io      -> escritorio/movil (salida_io.dart)
//   - dart.library.js_interop -> navegador (salida_web.dart)
//   - sin ninguna de las dos -> stub vacio (salida_stub.dart), para tests.
export 'salida_stub.dart'
    if (dart.library.io) 'salida_io.dart'
    if (dart.library.js_interop) 'salida_web.dart';
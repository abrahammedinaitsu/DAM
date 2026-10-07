// home_screen.dart
// Pantalla 1 de la aplicacion.
// Saluda al usuario y ofrece un boton para navegar a la Pantalla 2.
import 'package:flutter/material.dart';

import 'second_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Navega a la segunda pantalla usando una ruta con animacion.
  void _abrirSegundaPantalla(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SecondScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla 1'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Contenido central: icono, titulo y descripcion.
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.waving_hand, size: 96, color: Colors.indigo),
                    SizedBox(height: 24),
                    Text(
                      '¡Hola, bienvenido a la Pantalla 1!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Pulsa el botón de abajo para pasar\na la segunda pantalla.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Boton ancho de navegacion situado en la parte inferior.
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => _abrirSegundaPantalla(context),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text(
                    'Ir a la Pantalla 2',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// second_screen.dart
// Pantalla 2 de la aplicacion.
// Confirma que la transicion funciono y permite volver a la Pantalla 1.
import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla 2'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Contenido central de la segunda pantalla.
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.celebration, size: 96, color: Colors.deepOrange),
                    SizedBox(height: 24),
                    Text(
                      '¡Llegaste a la Pantalla 2!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Este es el mensaje de la segunda pantalla.\n¡La transición funcionó!',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Boton que cierra la ruta y regresa a la Pantalla 1.
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text(
                    'Volver a la Pantalla 1',
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
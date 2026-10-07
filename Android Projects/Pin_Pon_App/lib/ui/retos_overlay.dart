// retos_overlay.dart
// Overlay de la lista de retos. Marca con un icono verde los retos ya
// completados y permite iniciar cualquiera de ellos.
import 'package:flutter/material.dart';

import '../game/config.dart';
import '../game/pon_game.dart';

class RetosOverlay extends StatelessWidget {
  const RetosOverlay({super.key, required this.juego});

  final PinPonGame juego;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xF20B1020),
      alignment: Alignment.center,
      // Lista desplazable por si la pantalla es pequeña.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'RETOS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // Un boton por cada reto configurado.
            for (final reto in GameConfig.retos)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: 320,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => juego.elegirReto(reto),
                    // Icono que indica si el reto ya fue completado.
                    icon: Icon(
                      juego.retosCompletados.contains(reto.id)
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: juego.retosCompletados.contains(reto.id)
                          ? Colors.green
                          : Colors.white38,
                    ),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reto.nombre,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          reto.descripcion,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: juego.volverAlMenu,
              child: const Text(
                'Volver al menu',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
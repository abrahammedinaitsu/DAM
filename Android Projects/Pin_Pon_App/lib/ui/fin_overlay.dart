// fin_overlay.dart
// Overlay de fin de partida: muestra el resultado y permite jugar de nuevo
// o volver al menu principal.
import 'package:flutter/material.dart';

import '../game/pon_game.dart';

class FinOverlay extends StatelessWidget {
  const FinOverlay({super.key, required this.juego});

  final PinPonGame juego;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xF20B1020),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
          const SizedBox(height: 16),
          // El mensaje final se lee del ValueNotifier del juego.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ValueListenableBuilder<String>(
              valueListenable: juego.mensajeFin,
              builder: (_, mensaje, _) {
                return Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: 260,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: juego.iniciarPartida,
              icon: const Icon(Icons.replay),
              label: const Text('Jugar de nuevo',
                  style: TextStyle(fontSize: 17)),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 260,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: juego.volverAlMenu,
              icon: const Icon(Icons.home),
              label: const Text('Menu principal',
                  style: TextStyle(fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }
}
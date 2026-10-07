// hud_overlay.dart
// Overlay con el marcador durante la partida (J1 score - score J2)
// y el boton de pausa en la esquina superior derecha.
import 'package:flutter/material.dart';

import '../game/pon_game.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.juego});

  final PinPonGame juego;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Marcador centrado; IgnorePointer deja pasar el tactil al juego.
            Expanded(
              child: IgnorePointer(
                child: ValueListenableBuilder<String>(
                  valueListenable: juego.infoHud,
                  builder: (_, valor, _) {
                    return Text(
                      valor,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    );
                  },
                ),
              ),
            ),
            IconButton(
              onPressed: juego.alternarPausa,
              icon: const Icon(
                Icons.pause_circle,
                size: 40,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
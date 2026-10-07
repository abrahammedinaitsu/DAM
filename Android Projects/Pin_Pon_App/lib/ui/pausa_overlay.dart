// pausa_overlay.dart
// Overlay de pausa: continua, reinicia o vuelve al menu principal.
import 'package:flutter/material.dart';

import '../game/pon_game.dart';

class PausaOverlay extends StatelessWidget {
  const PausaOverlay({super.key, required this.juego});

  final PinPonGame juego;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xD90B1020),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'PAUSA',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 36),
          _BotonPausa(
            texto: 'Continuar',
            icono: Icons.play_arrow,
            color: Colors.green,
            alPulsar: juego.alternarPausa,
          ),
          const SizedBox(height: 14),
          _BotonPausa(
            texto: 'Reiniciar',
            icono: Icons.replay,
            color: Colors.amber,
            alPulsar: juego.iniciarPartida,
          ),
          const SizedBox(height: 14),
          _BotonPausa(
            texto: 'Menu principal',
            icono: Icons.home,
            color: Colors.redAccent,
            alPulsar: juego.volverAlMenu,
          ),
        ],
      ),
    );
  }
}

/// Boton reutilizable de la pantalla de pausa.
class _BotonPausa extends StatelessWidget {
  const _BotonPausa({
    required this.texto,
    required this.icono,
    required this.color,
    required this.alPulsar,
  });

  final String texto;
  final IconData icono;
  final Color color;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: alPulsar,
        icon: Icon(icono),
        label: Text(texto, style: const TextStyle(fontSize: 17)),
      ),
    );
  }
}
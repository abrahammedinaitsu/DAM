// menu_overlay.dart
// Overlay del menu principal: titulo del juego y las opciones de juego
// (2 jugadores, vs IA, retos y salir).
import 'package:flutter/material.dart';

import '../game/config.dart';
import '../game/pon_game.dart';

class MenuOverlay extends StatelessWidget {
  const MenuOverlay({super.key, required this.juego});

  final PinPonGame juego;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Fondo semitransparente para que se vea la cancha detras.
      color: const Color(0xF20B1020),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sports_tennis, size: 84, color: Colors.amber),
          const SizedBox(height: 12),
          const Text(
            'PIN-PON',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Flutter + Flame',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 40),
          _BotonMenu(
            texto: 'Jugar contra otra persona',
            icono: Icons.people,
            color: Colors.green,
            alPulsar: () =>
                juego.elegirModo(ModoJuego.dosJugadores),
          ),
          const SizedBox(height: 14),
          _BotonMenu(
            texto: 'Jugar contra la IA',
            icono: Icons.smart_toy,
            color: Colors.indigo,
            alPulsar: () => juego.elegirModo(ModoJuego.contraIA),
          ),
          const SizedBox(height: 14),
          _BotonMenu(
            texto: 'Retos',
            icono: Icons.emoji_events,
            color: Colors.orange,
            alPulsar: juego.abrirRetos,
          ),
          const SizedBox(height: 14),
          _BotonMenu(
            texto: 'Salir',
            icono: Icons.exit_to_app,
            color: Colors.redAccent,
            alPulsar: juego.salir,
          ),
        ],
      ),
    );
  }
}

/// Boton reutilizable del menu.
class _BotonMenu extends StatelessWidget {
  const _BotonMenu({
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
      width: 300,
      height: 54,
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
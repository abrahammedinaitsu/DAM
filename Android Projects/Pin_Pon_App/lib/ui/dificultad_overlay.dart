// dificultad_overlay.dart
// Overlay para elegir la dificultad de la partida (facil, medio, dificil).
// Muestra ademas el modo que se va a jugar y un boton para volver al menu.
import 'package:flutter/material.dart';

import '../game/config.dart';
import '../game/pon_game.dart';

class DificultadOverlay extends StatelessWidget {
  const DificultadOverlay({super.key, required this.juego});

  final PinPonGame juego;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xF20B1020),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ELIGE DIFICULTAD',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Recuerda el modo elegido (2 jugadores o vs IA).
          Text(
            descripcionModo(juego.modo),
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 32),
          _BotonDificultad(
            texto: 'Facil',
            detalle: 'paleta grande y pelota lenta',
            color: Colors.green,
            alPulsar: () => juego.elegirDificultad(Dificultad.facil),
          ),
          const SizedBox(height: 14),
          _BotonDificultad(
            texto: 'Medio',
            detalle: 'velocidad progresiva',
            color: Colors.amber,
            alPulsar: () => juego.elegirDificultad(Dificultad.medio),
          ),
          const SizedBox(height: 14),
          _BotonDificultad(
            texto: 'Dificil',
            detalle: 'pelota rapida y paleta pequeña',
            color: Colors.redAccent,
            alPulsar: () => juego.elegirDificultad(Dificultad.dificil),
          ),
          const SizedBox(height: 28),
          TextButton(
            onPressed: juego.volverAlMenu,
            child: const Text(
              'Volver al menu',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

/// Boton reutilizable de una dificultad con su descripcion.
class _BotonDificultad extends StatelessWidget {
  const _BotonDificultad({
    required this.texto,
    required this.detalle,
    required this.color,
    required this.alPulsar,
  });

  final String texto;
  final String detalle;
  final Color color;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 64,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: alPulsar,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texto, style: const TextStyle(fontSize: 18)),
            Text(
              detalle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
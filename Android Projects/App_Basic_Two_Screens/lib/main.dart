// main.dart
// Aplicacion Flutter de dos pantallas (App Basic Two Screens).
// Define el tema de la app y muestra la Pantalla 1 como inicio.
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const AppBasicTwoScreens());

/// Raiz de la aplicacion: un MaterialApp con tema y pantalla inicial.
class AppBasicTwoScreens extends StatelessWidget {
  const AppBasicTwoScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Basic Two Screens',
      debugShowCheckedModeBanner: false,
      // Tema Material 3 con un color de semilla indigo.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
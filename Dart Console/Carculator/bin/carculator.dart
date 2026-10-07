// carculator.dart
// Calculadora de consola en Dart.
// Permite sumar, restar, multiplicar y dividir, con validacion de entrada
// y proteccion contra divisiones entre cero.
import 'dart:io';

/// Funcion principal: muestra la bienvenida y ejecuta el bucle de calculo.
void main() {
  print('=== CALCULADORA (Carculator) ===');
  print('Operaciones: +  -  *  /   |   escribe "salir" para terminar\n');

  while (true) {
    // Lee los dos numeros y la operacion; si el usuario quiere salir, termina.
    final numero1 = _leerNumero('Primer numero: ');
    if (numero1 == null) return;

    final operacion = _leerOperacion();
    if (operacion == null) return;

    final numero2 = _leerNumero('Segundo numero: ');
    if (numero2 == null) return;

    // Las matematicas no permiten dividir entre cero.
    if (operacion == '/' && numero2 == 0) {
      print('\nError: no se puede dividir entre 0.\n');
      continue;
    }

    // Calcula y muestra el resultado formateado.
    final resultado = _calcular(numero1, operacion, numero2);
    print('\nResultado: ${_formatear(numero1)} $operacion ${_formatear(numero2)}'
        ' = ${_formatear(resultado)}\n');
  }
}

/// Pide un numero por teclado hasta que el valor sea valido.
/// Devuelve [null] cuando el usuario escribe "salir" o "q".
double? _leerNumero(String mensaje) {
  while (true) {
    stdout.write(mensaje);
    final linea = stdin.readLineSync();
    if (linea == null || _esSalida(linea)) return null;
    final valor = double.tryParse(linea.trim());
    if (valor != null) return valor;
    print('Valor no valido. Intenta de nuevo.');
  }
}

/// Pide el simbolo de la operacion validandolo contra +, -, * y /.
String? _leerOperacion() {
  while (true) {
    stdout.write('Operacion (+, -, *, /): ');
    final linea = stdin.readLineSync();
    if (linea == null || _esSalida(linea)) return null;
    final op = linea.trim();
    if (op == '+' || op == '-' || op == '*' || op == '/') return op;
    print('Operacion no valida. Usa +, -, * o /.');
  }
}

/// Indica si el texto escrito corresponde a una orden de salida.
bool _esSalida(String texto) {
  final valor = texto.trim().toLowerCase();
  return valor == 'salir' || valor == 'q';
}

/// Ejecuta la operacion aritmetica indicada por [operacion].
double _calcular(double a, String operacion, double b) {
  switch (operacion) {
    case '+':
      return a + b;
    case '-':
      return a - b;
    case '*':
      return a * b;
    default:
      return a / b;
  }
}

/// Formatea el resultado: sin decimales si es entero,
/// con hasta 4 decimales en caso contrario.
String _formatear(double valor) {
  if (valor == valor.roundToDouble()) {
    return valor.round().toString();
  }
  return valor.toStringAsFixed(4);
}
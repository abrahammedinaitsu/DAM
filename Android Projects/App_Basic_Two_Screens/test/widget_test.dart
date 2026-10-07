// widget_test.dart
// Prueba de widget: verifica que se muestra la Pantalla 1, que se navega
// a la Pantalla 2 con el boton y que el boton de regreso vuelve a la 1.
import 'package:flutter_test/flutter_test.dart';

import 'package:app_basic_two_screens/main.dart';

void main() {
  testWidgets('muestra la pantalla 1 y navega a la pantalla 2',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AppBasicTwoScreens());

    // Pantalla 1 visible al arrancar.
    expect(find.text('¡Hola, bienvenido a la Pantalla 1!'), findsOneWidget);

    // Al pulsar el boton pasamos a la Pantalla 2.
    await tester.tap(find.text('Ir a la Pantalla 2'));
    await tester.pumpAndSettle();

    expect(find.text('¡Llegaste a la Pantalla 2!'), findsOneWidget);

    // Al pulsar el boton de regreso volvemos a la Pantalla 1.
    await tester.tap(find.text('Volver a la Pantalla 1'));
    await tester.pumpAndSettle();

    expect(find.text('¡Hola, bienvenido a la Pantalla 1!'), findsOneWidget);
  });
}
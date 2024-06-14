import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'Screens/CreateExpenseScreen.dart';

void main() {
  testWidgets('Pantalla de crear gasto', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: CreateExpenseScreen()));

    // Verificar que los campos de texto están presentes
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Nombre del Gasto'), findsOneWidget);
    expect(find.text('Importe'), findsOneWidget);

    // Verificar que el dropdown y el botón están presentes
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.text('Crear Gasto'), findsOneWidget);

    // Simular una entrada de texto y un clic en el botón de crear gasto
    await tester.enterText(find.byType(TextField).first, 'Gasto de Prueba');
    await tester.enterText(find.byType(TextField).last, '50');
    await tester.tap(find.text('Crear Gasto'));

    // Esperar que se procese la entrada
    await tester.pump();

  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarea7_intromovil/app.dart';
import 'package:tarea7_intromovil/ui/shared.dart';
import 'package:tarea7_intromovil/ui/pages.dart';
import 'package:tarea7_intromovil/data/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('Inicio muestra las herramientas y permite abrir Acerca de', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();
    expect(find.text('Tu caja de\nherramientas digital.'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Acerca de'), 300);
    await tester.tap(find.text('Acerca de'));
    await tester.pumpAndSettle();
    expect(find.text('Tu nombre aquí'), findsOneWidget);
    expect(
      find.text('Foto y datos de contacto pendientes de personalizar.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('El formulario evita consultas vacías', (tester) async {
    var requests = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QueryView<String>(
            inputLabel: 'Nombre',
            load: (_) async {
              requests++;
              return 'ok';
            },
            result: Text.new,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Buscar'));
    await tester.pumpAndSettle();
    expect(find.text('Este campo es obligatorio.'), findsOneWidget);
    expect(requests, 0);
  });
  testWidgets('Resultado masculino azul y femenino rosa', (tester) async {
    for (final sample in [
      ('male', const Color(0xFFDCEBFF)),
      ('female', const Color(0xFFFFE2EF)),
    ]) {
      final api = ApiService(
        client: MockClient(
          (_) async => http.Response(
            '{"name":"Nombre","gender":"${sample.$1}","probability":0.99}',
            200,
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GenderPage(api, key: UniqueKey())),
        ),
      );
      await tester.enterText(find.byType(TextFormField), 'Nombre');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();
      expect(tester.widget<Surface>(find.byType(Surface)).color, sample.$2);
      api.close();
    }
  });
}

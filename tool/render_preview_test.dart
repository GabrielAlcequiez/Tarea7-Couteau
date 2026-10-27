import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarea7_intromovil/app.dart';

void main() {
  testWidgets('Vista previa móvil de Inicio y Acerca de', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final config = jsonDecode(
        await File('.dart_tool/package_config.json').readAsString(),
      );
      final package = (config['packages'] as List).firstWhere(
        (p) => p['name'] == 'flutter',
      );
      final sdk = Directory.fromUri(Uri.parse(package['rootUri'] as String))
          .parent
          .parent
          .path;
      for (final entry in {
        'Roboto': 'roboto-regular.ttf',
        'MaterialIcons': 'materialicons-regular.otf',
      }.entries) {
        final loader = FontLoader(entry.key);
        loader.addFont(
          File('$sdk/bin/cache/artifacts/material_fonts/${entry.value}')
              .readAsBytes()
              .then(ByteData.sublistView),
        );
        await loader.load();
      }
    });
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(key: boundaryKey, child: const MainApp()),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final context = tester.element(find.byType(HomePage));
      await Future.wait([
        precacheImage(const AssetImage('assets/images/toolbox.png'), context),
        precacheImage(const AssetImage('assets/images/profile.png'), context),
      ]);
    });
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('build/preview/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture('inicio');
    await tester.scrollUntilVisible(find.text('Acerca de'), 300);
    await tester.tap(find.text('Acerca de'));
    await tester.pumpAndSettle();
    await capture('acerca');
    expect(tester.takeException(), isNull);
  });
}
